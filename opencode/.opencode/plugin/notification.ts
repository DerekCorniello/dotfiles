import type { Plugin } from "@opencode-ai/plugin";
import { readFile } from "node:fs/promises";

export const NotificationPlugin: Plugin = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  const currentPid = process.pid;
  const busySessions = new Set<string>();
  const lastAssistantTextBySession = new Map<string, string>();

  const summarizeAssistantText = (value: string, maxChars: number): string => {
    const oneLine = value.replace(/\s+/g, " ").trim();
    if (!oneLine) return "Agent finished";
    if (oneLine.length <= maxChars) return oneLine;
    return `${oneLine.slice(0, maxChars - 3)}...`;
  };

  const getParentPid = async (pid: number): Promise<number | null> => {
    try {
      const status = await readFile(`/proc/${pid}/status`, "utf8");
      const match = status.match(/^PPid:\s+(\d+)$/m);
      if (!match) return null;
      const ppid = Number.parseInt(match[1], 10);
      return Number.isNaN(ppid) ? null : ppid;
    } catch {
      return null;
    }
  };

  const isAncestor = async (
    ancestorPid: number,
    childPid: number,
  ): Promise<boolean> => {
    let cursor = childPid;
    let depth = 0;

    while (cursor > 1 && depth < 64) {
      if (cursor === ancestorPid) return true;
      const parent = await getParentPid(cursor);
      if (!parent || parent === cursor) break;
      cursor = parent;
      depth += 1;
    }

    return false;
  };

  const windowPidMatchesThisProcess = async (
    windowPid: number | null,
  ): Promise<boolean> => {
    if (!windowPid || windowPid <= 0) return false;
    if (windowPid === currentPid) return true;
    return isAncestor(windowPid, currentPid);
  };

  const isThisPaneFocused = async (): Promise<boolean> => {
    try {
      const activeWindow = await $`hyprctl activewindow -j`.text();
      const parsed = JSON.parse(activeWindow) as { pid?: number };
      if (await windowPidMatchesThisProcess(parsed.pid ?? null)) {
        return true;
      }
    } catch {}

    try {
      const id = (await $`xdotool getactivewindow`.text()).trim();
      const pidOutput = await $`xprop -id ${id} _NET_WM_PID`.text();
      const match = pidOutput.match(/=\s*(\d+)/);
      const activePid = match ? Number.parseInt(match[1], 10) : null;
      return windowPidMatchesThisProcess(activePid);
    } catch {
      return false;
    }
  };

  return {
    event: async ({ event }) => {
      if (event.type === "session.status") {
        if (event.properties.status.type === "busy") {
          busySessions.add(event.properties.sessionID);
        }
        return;
      }

      if (event.type === "message.part.updated") {
        const { part } = event.properties;
        if (part.type !== "text") return;
        if (!part.text || !part.text.trim()) return;
        lastAssistantTextBySession.set(
          part.sessionID,
          summarizeAssistantText(part.text, 140),
        );
        return;
      }

      if (event.type === "permission.asked") {
        const thisPaneFocused = await isThisPaneFocused();
        if (thisPaneFocused) return;

        const { permission, metadata } = event.properties;
        const detail = metadata?.filepath ?? permission;
        await $`notify-send "opencode" "Permission required: ${detail}"`;
        return;
      }

      if (event.type === "session.idle") {
        const sessionId = event.properties.sessionID;
        const wasBusy = busySessions.delete(sessionId);
        if (!wasBusy) return;

        const thisPaneFocused = await isThisPaneFocused();
        if (thisPaneFocused) return;

        const preview =
          lastAssistantTextBySession.get(sessionId) ?? "Agent finished";
        await $`notify-send "opencode" "${preview}"`;
      }
    },
  };
};
