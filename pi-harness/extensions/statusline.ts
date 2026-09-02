// statusline — non-LLM footer status for pi
//
// Works in a single repo OR a parent folder containing multiple repos.
//
// Footer entries via setStatus:
//   single repo:  repo: "main ±3 ↑2"          branch, dirty count, ahead/behind
//   multi-repo:   repo: "6 repos · ±12 · ↑9"  aggregates over immediate child repos
//   ci:           "prs 4 ✗1"                  open PRs + failing-check count across
//                                             the repo(s) (gh polled <= every 5 min)
//
// Silent when offline / no repos / gh missing. Never blocks, never notifies on failure.

import { execFile } from "node:child_process";
import { readdirSync, readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { visibleWidth, truncateToWidth } from "@earendil-works/pi-tui";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const PR_POLL_MS = 5 * 60 * 1000;

interface UiCtx {
	ui?: { hasUI: boolean; setStatus(key: string, value?: string): void };
}

interface StatusSnapshot {
	repo?: string;
	usage?: string;
	model?: string;
	thinking?: string;
}

function sh(cmd: string, args: string[], timeoutMs = 8000): Promise<string | null> {
	return new Promise((resolve) => {
		try {
			execFile(cmd, args, { timeout: timeoutMs, maxBuffer: 1024 * 512 }, (err, stdout) => {
				resolve(err ? null : stdout.toString().trim());
			});
		} catch {
			resolve(null);
		}
	});
}

function k(n: number): string {
	return n >= 1_000_000 ? `${(n / 1_000_000).toFixed(1)}M` : n >= 1000 ? `${(n / 1000).toFixed(1)}k` : `${n}`;
}

/** Sum token usage across assistant messages in the session. Provider-agnostic. */
function sessionTotals(entries: Array<Record<string, any>>): string | null {
	let input = 0;
	let output = 0;
	for (const e of entries) {
		const u = e?.message?.usage ?? e?.usage;
		if (!u || typeof u !== "object") continue;
		input += Number(u.input ?? 0);
		output += Number(u.output ?? 0);
	}
	if (input + output === 0) return null;
	return `tok ${k(input)}in/${k(output)}out`;
}

// ------------------------------------------------------- subscription quota
// Provider-agnostic: if ~/.pi/agent/usage.sh exists, its first output line is
// shown verbatim after "quota" (works with ANY provider). Fallback: OpenRouter
// credit lookup when an OpenRouter key is configured.

async function httpJson(url: string, headers: Record<string, string>, timeoutMs = 8000): Promise<any | null> {
	try {
		const ctrl = new AbortController();
		const t = setTimeout(() => ctrl.abort(), timeoutMs);
		const res = await fetch(url, { headers, signal: ctrl.signal });
		clearTimeout(t);
		return res.ok ? await res.json() : null;
	} catch {
		return null;
	}
}

function parsePercentQuota(raw: string): string | null {
	const cleaned = raw.replace(/[$,]/g, "");
	const percentages = [...cleaned.matchAll(/(\d+(?:\.\d+)?)\s*%/g)].map((m) => `${Math.round(Number(m[1]))}%`);
	const resets = [...cleaned.matchAll(/(?:reset|resets|remaining)\s*[:=]?\s*([^,;|]+)/gi)].map((m) => m[1].trim());
	if (percentages.length > 0) return `usage ${percentages.slice(0, 2).join("  ")}${resets.length ? ` · reset ${resets[0]}` : ""}`;
	const ratio = cleaned.match(/(\d+(?:\.\d+)?)\s*(?:\/|of)\s*(\d+(?:\.\d+)?)/i);
	if (!ratio) return null;
	const used = Number(ratio[1]);
	const limit = Number(ratio[2]);
	if (!Number.isFinite(used) || !Number.isFinite(limit) || limit <= 0) return null;
	return `quota ${Math.round((used / limit) * 100)}%`;
}

async function subscriptionQuota(): Promise<string | null> {
	const home = process.env.HOME ?? "";
	const script = join(home, ".pi", "agent", "usage.sh");
	if (existsSync(script)) {
		const out = await sh("bash", [script], 15000);
		if (!out) return null;
		return parsePercentQuota(out) ?? null;
	}
	try {
		const auth = JSON.parse(readFileSync(join(home, ".pi", "agent", "auth.json"), "utf8"));
		const key = auth?.openrouter?.key;
		if (!key) return null;
		const j = await httpJson("https://openrouter.ai/api/v1/auth/key", { Authorization: `Bearer ${key}` });
		const d = j?.data;
		if (!d) return null;
		const used = typeof d.usage === "number" ? d.usage : null;
		const limit = d.limit === null || d.limit === undefined ? null : Number(d.limit);
		if (used !== null && limit && limit > 0) return `quota ${Math.round((used / limit) * 100)}%`;
		return null;
	} catch {
		return null;
	}
}

/** Repo roots at/below cwd: cwd itself if a repo, else immediate child dirs with .git. */
async function findRepos(cwd: string): Promise<string[]> {
	if ((await sh("git", ["-C", cwd, "rev-parse", "--show-toplevel"], 3000)) !== null) return [cwd];
	try {
		const kids = readdirSync(cwd, { withFileTypes: true })
			.filter((d) => d.isDirectory() && !d.name.startsWith("."))
			.map((d) => join(cwd, d.name));
		const checks = await Promise.all(kids.map((p) => sh("git", ["-C", p, "rev-parse", "--show-toplevel"], 3000)));
		return kids.filter((_, i) => checks[i] !== null).slice(0, 12); // cap for sanity
	} catch {
		return [];
	}
}

async function oneRepoLine(root: string): Promise<string | null> {
	const branch = await sh("git", ["-C", root, "branch", "--show-current"], 3000);
	if (!branch) return null;
	const parts = [branch];

	const dirty = await sh("git", ["-C", root, "status", "--porcelain"]);
	if (dirty && dirty.length > 0) parts.push(`±${dirty.split("\n").length}`);

	const ab = await sh("git", ["-C", root, "rev-list", "--left-right", "--count", "@{upstream}...HEAD"]);
	if (ab) {
		const [behind, ahead] = ab.split(/\s+/).map((s) => parseInt(s, 10));
		if (ahead > 0 || behind > 0) parts.push(`↑${ahead}↓${behind}`);
	}
	return parts.join(" ");
}

async function multiRepoLine(roots: string[]): Promise<string | null> {
	const lines = await Promise.all(roots.map((r) => oneRepoLine(r)));
	const ok = lines.filter((l): l is string => l !== null);
	if (ok.length === 0) return null;
	let dirty = 0;
	let dirtyRepos = 0;
	let unpushed = 0;
	for (const l of ok) {
		const m = l.match(/±(\d+)/);
		if (m) {
			dirty += parseInt(m[1], 10);
			dirtyRepos++;
		}
		if (l.includes("↑")) {
			const a = l.match(/↑(\d+)/);
			unpushed += a ? parseInt(a[1], 10) : 0;
		}
	}
	const bits = [`${ok.length} repo${ok.length === 1 ? "" : "s"}`];
	if (dirtyRepos > 0) bits.push(`${dirtyRepos} dirty ±${dirty}`);
	if (unpushed > 0) bits.push(`↑${unpushed} unpushed`);
	return bits.join(" · ");
}

async function repoSlug(root: string): Promise<string | null> {
	const url = await sh("git", ["-C", root, "remote", "get-url", "origin"], 3000);
	if (!url) return null;
	const m = url.match(/[:/]([^/]+\/[^/]+?)(?:\.git)?$/);
	return m ? m[1] : null;
}

async function prStatus(roots: string[]): Promise<string | null> {
	if (!(await sh("git", ["--version"]))) return null;
	const slugs = (await Promise.all(roots.map(repoSlug))).filter((s): s is string => s !== null).slice(0, 8);
	if (slugs.length === 0) return null;

	let total = 0;
	let failing = 0;
	for (const slug of slugs) {
		const out = await sh("gh", ["pr", "list", "-R", slug, "--state", "open", "--limit", "50", "--json", "statusCheckRollup"], 15000);
		if (out === null) continue;
		type Pr = { statusCheckRollup?: Array<{ conclusion?: string | null; state?: string }> };
		try {
			const prs: Pr[] = JSON.parse(out);
			total += prs.length;
			failing += prs.filter((p) =>
				(p.statusCheckRollup ?? []).some((c) => c.conclusion === "FAILURE" || c.state === "FAILURE"),
			).length;
		} catch {
			/* skip malformed */
		}
	}
	return total === 0 ? "prs 0" : failing > 0 ? `prs ${total} ✗${failing}` : `prs ${total} ✓`;
}

export default function (pi: ExtensionAPI) {
	let lastPrPoll = 0;
	let lastUsagePoll = 0;
	const USAGE_POLL_MS = 60 * 1000;
	let timer: ReturnType<typeof setTimeout> | null = null;

	async function refresh(
		ctx: UiCtx & { cwd?: string; sessionManager?: { getEntries(): Array<Record<string, any>> } },
		forcePr = false,
	) {
		if (!ctx.ui?.hasUI) return;
		const roots = await findRepos(ctx.cwd ?? process.cwd());

		const line =
			roots.length === 1 ? await oneRepoLine(roots[0]) : await multiRepoLine(roots);
		ctx.ui.setStatus("repo", line ?? undefined);
		ctx.ui.setStatus("tok", sessionTotals(ctx.sessionManager?.getEntries() ?? []) ?? undefined);
		ctx.ui.setStatus("model", undefined);
		ctx.ui.setStatus("thinking", undefined);
		ctx.ui.setStatus("usage", undefined);
		ctx.ui.setStatus("ci", undefined);

		const now = Date.now();
		if (forcePr || now - lastPrPoll >= PR_POLL_MS) {
			lastPrPoll = now;
			ctx.ui.setStatus("ci", (await prStatus(roots)) ?? undefined);
			lastUsagePoll = now;
			ctx.ui.setStatus("usage", await subscriptionQuota());
		} else if (now - lastUsagePoll >= USAGE_POLL_MS) {
			lastUsagePoll = now;
			ctx.ui.setStatus("usage", await subscriptionQuota());
		}
		if (timer) clearTimeout(timer);
		timer = setTimeout(() => void refresh(ctx, true), PR_POLL_MS);
		timer.unref?.();
	}

	pi.on("session_start", async (_event, ctx) => {
		if (ctx.mode === "tui") {
			ctx.ui.setFooter((_tui, theme, footerData) => ({
				render: (width: number) => {
					const stripAnsi = (s: string) => s.replace(/\x1b\[[0-9;]*m/g, "");
					const statuses = footerData.getExtensionStatuses();
					const mode = stripAnsi(statuses.get("pi-permission-suite") ?? "[mode] - full");
					const model = ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : "no-model";
					let usage = stripAnsi(statuses.get("pi-sub") ?? statuses.get("usage") ?? "");
					const modeColor = mode.endsWith("full") ? "success" : mode.endsWith("auto") ? "warning" : mode.endsWith("ask") ? "error" : "accent";
					const left = `${theme.fg(modeColor, mode)} ${theme.fg("dim", "·")} ${theme.fg("muted", ctx.cwd)}${usage ? ` ${theme.fg("dim", "·")} ${theme.fg("warning", usage)}` : ""}`;
					const leftW = visibleWidth(left);
					const modelW = visibleWidth(model);
					const gap = Math.max(1, width - leftW - modelW);
					const line = `${left}${" ".repeat(gap)}${theme.fg("accent", model)}`;
					return [truncateToWidth(line, width)];
				},
				invalidate: () => undefined,
			}));
		}
		await refresh(ctx, true);
	});

	pi.on("turn_end", async (_event, ctx) => {
		await refresh(ctx);
	});

	pi.on("agent_end", async (_event, ctx) => {
		await refresh(ctx);
	});

	pi.registerCommand("status-refresh", {
		description: "Force refresh the status line (git + PR checks)",
		handler: async (_args, ctx) => {
			lastPrPoll = 0;
			await refresh(ctx as UiCtx & { cwd: string }, true);
			ctx.ui.notify("Status refreshed", "info");
		},
	});
}
