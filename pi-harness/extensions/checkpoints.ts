/**
 * Checkpoints extension for pi — `/undo`, `/redo`, `/checkpoints`.
 *
 * Rewinds BOTH the working files and the conversation, like opencode/claude-code rewind.
 *
 * Files: before each agent turn, snapshot the entire worktree (tracked, untracked,
 * dirty — everything git can see, respecting .gitignore) into a tree object via a
 * temporary index (`GIT_INDEX_FILE`). No refs are touched, nothing is committed,
 * the user's real index/staging area is never modified by checkpointing. Restore
 * applies a `git diff --binary` patch between the captured trees onto the worktree
 * only, so user staging survives (agent-created files are deleted; ignored files
 * are untouched). Outside a git repo the extension degrades to conversation-only
 * mode.
 *
 * Conversation: each checkpoint records the session-tree anchor (parent of the user
 * message that started the turn). `/undo` calls ctx.navigateTree() to move the leaf
 * back — the same mechanism /tree uses — so prior turns genuinely leave the LLM
 * context. `/redo` jumps forward to the leaf captured at undo time. If the
 * checkpoint sits at the very root of the conversation (nothing to rewind to),
 * `/undo` falls back to injecting a "context was reverted" note into the next turn.
 *
 * Stack persistence: every mutation is appended to the session as a custom entry
 * (`checkpoint` / `pos` / `truncate` events) and replayed from the current branch on
 * session_start, so the undo stack survives restarts. Scanning only the active
 * branch means manual /tree jumps naturally drop checkpoints left on abandoned
 * branches. Memory and replay execute the exact same op sequence, so they stay in
 * sync.
 *
 * Safety: if the worktree changed since the last known-good state (user edits made
 * outside the agent, or divergence mid-stack), a confirmation dialog is shown before
 * restoring; in headless modes the restore is refused instead of destroying work.
 *
 * Note: checkpointing runs `git add -A` against a throwaway index once per turn;
 * on very large repositories this costs a directory scan per turn.
 */

import { spawn } from "node:child_process";
import { promises as fs } from "node:fs";
import { join } from "node:path";
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

const ENTRY_TYPE = "checkpoints";
const GIT_TIMEOUT_MS = 60_000;

interface Checkpoint {
	tree: string | null;
	/** Session entry to move the leaf to when rewinding the conversation to this point. */
	anchor: string | null;
	/** Leaf entry id at capture time (used by /redo to jump forward). */
	leaf: string | null;
	atRoot: boolean;
	ts: number;
}

type StoredEvent =
	| {
			kind: "checkpoint";
			tree: string | null;
			anchor: string | null;
			leaf: string | null;
			atRoot: boolean;
			ts: number;
	  }
	| { kind: "pos"; pos: number }
	| { kind: "truncate"; count: number };

export default function (pi: ExtensionAPI) {
	let repoRoot: string | null = null;
	let checkpoints: Checkpoint[] = [];
	// Invariant: checkpoints[0..pos-1] are past states, checkpoints[pos..] are
	// redo-able future states, live state == checkpoints[pos] (virtual entry at len).
	let pos = 0;
	let expectedTree: string | null = null; // last known-good worktree state (post-agent)
	let restoring = false;
	let indexFile: string | null = null;
	let queue: Promise<unknown> = Promise.resolve();

	// ---------------------------------------------------------------- git core

	function git(args: string[], opts?: { input?: string; useTempIndex?: boolean }): Promise<{ stdout: string; stderr: string; code: number }> {
		return new Promise((resolve, reject) => {
			const child = spawn(
				"git",
				args,
				opts?.useTempIndex && indexFile
					? { cwd: repoRoot ?? undefined, env: { ...process.env, GIT_INDEX_FILE: indexFile } }
					: { cwd: repoRoot ?? undefined },
			);
			let stdout = "";
			let stderr = "";
			const timer = setTimeout(() => child.kill("SIGKILL"), GIT_TIMEOUT_MS);
			child.stdout.on("data", (d: Buffer) => {
				stdout += d.toString();
			});
			child.stderr.on("data", (d: Buffer) => {
				stderr += d.toString();
			});
			child.on("error", (err) => {
				clearTimeout(timer);
				reject(err);
			});
			child.on("close", (code) => {
				clearTimeout(timer);
				resolve({ stdout, stderr, code: code ?? -1 });
			});
			child.stdin.on("error", () => undefined); // EPIPE when child exits early (e.g. shutdown race)
			child.stdin.end(opts?.input ?? "");
		});
	}

	/** Serialize git operations (the temp index is shared per-process). */
	function serialized<T>(fn: () => Promise<T>): Promise<T> {
		const run = queue.then(fn, fn);
		queue = run.catch(() => undefined);
		return run;
	}

	/** Snapshot the full worktree into a tree object via the temp index. Never touches refs or the real index. */
	async function captureTree(): Promise<string | null> {
		if (!repoRoot || !indexFile) return null;
		return serialized(async () => {
			const add = await git(["add", "-A", "--"], { useTempIndex: true });
			if (add.code !== 0) return null;
			const wt = await git(["write-tree"], { useTempIndex: true });
			if (wt.code !== 0) return null;
			const tree = wt.stdout.trim();
			return /^[0-9a-f]{40}$/.test(tree) ? tree : null;
		}).catch(() => null);
	}

	/** True if the tree object still exists (restart / gc safety check). */
	async function treeUsable(tree: string): Promise<boolean> {
		if (!repoRoot) return false;
		try {
			return (await git(["cat-file", "-e", `${tree}^{tree}`])).code === 0;
		} catch {
			return false;
		}
	}

	/**
	 * Restore the worktree to `target` by applying a binary diff from the freshly
	 * captured current state. Worktree only — the real index (user staging) is
	 * never modified. Atomic: git apply fails wholesale rather than half-applying.
	 */
	async function restoreTree(target: string): Promise<boolean> {
		if (!repoRoot) return false;
		return serialized(async () => {
			const current = await captureTree();
			if (!current) return false;
			if (current === target) return true;
			const diff = await git(["diff", "--binary", current, target]);
			if (diff.code !== 0) return false;
			if (!diff.stdout.trim()) return true;
			const apply = await git(["apply", "--whitespace=nowarn"], { input: diff.stdout });
			return apply.code === 0;
		}).catch(() => false);
	}

	// ------------------------------------------------------------- persistence

	function persistCheckpoint(cp: Checkpoint) {
		pi.appendEntry<StoredEvent>(ENTRY_TYPE, {
			kind: "checkpoint",
			tree: cp.tree,
			anchor: cp.anchor,
			leaf: cp.leaf,
			atRoot: cp.atRoot,
			ts: cp.ts,
		});
	}

	function persistPos() {
		pi.appendEntry<StoredEvent>(ENTRY_TYPE, { kind: "pos", pos });
	}

	interface BranchLike {
		type: string;
		customType?: string;
		data?: unknown;
	}

	function applyEvent(cps: Checkpoint[], data: StoredEvent): number {
		switch (data.kind) {
			case "checkpoint":
				cps.push({
					tree: data.tree ?? null,
					anchor: data.anchor ?? null,
					leaf: data.leaf ?? null,
					atRoot: !!data.atRoot,
					ts: data.ts ?? 0,
				});
				break;
			case "truncate":
				cps.length = Math.max(0, Math.min(data.count, cps.length));
				break;
			case "pos":
				return Math.max(0, Math.min(data.pos, cps.length));
		}
		return -1;
	}

	function rebuildFromSession(branch: BranchLike[]): void {
		checkpoints = [];
		pos = 0;
		let sawPos = false;
		for (const entry of branch) {
			if (entry.type !== "custom" || entry.customType !== ENTRY_TYPE) continue;
			const data = entry.data as StoredEvent | undefined;
			if (!data || typeof data !== "object") continue;
			const p = applyEvent(checkpoints, data);
			if (p >= 0) {
				pos = p;
				sawPos = true;
			}
		}
		if (!sawPos) pos = checkpoints.length;
	}

	function updateStatus(ctx: { ui?: { setStatus(k: string, v?: string): void; hasUI: boolean } }): void {
		if (!ctx.ui?.hasUI) return;
		ctx.ui.setStatus("checkpoints", checkpoints.length > 0 ? `undo ${pos}/${checkpoints.length}` : undefined);
	}

	// ------------------------------------------------------------------ events

	pi.on("session_start", async (_event, ctx) => {
		const tmpBase = join(process.env.HOME ?? process.cwd(), ".pi", "agent", "tmp");
			await fs.mkdir(tmpBase, { recursive: true });
			indexFile = join(tmpBase, `checkpoints-${process.pid}-${Math.random().toString(36).slice(2)}.index`);
		checkpoints = [];
		pos = 0;
		expectedTree = null;
		repoRoot = null;
		try {
			const probe = await git(["rev-parse", "--show-toplevel"]);
			const root = probe.stdout.trim();
			if (probe.code === 0 && root) repoRoot = root;
		} catch {
			repoRoot = null; // git missing or not a repo -> conversation-only mode
		}
		rebuildFromSession(ctx.sessionManager.getBranch());
		updateStatus(ctx);
	});

	pi.on("session_shutdown", async () => {
		if (indexFile) {
			await fs.rm(indexFile, { force: true }).catch(() => undefined);
			indexFile = null;
		}
	});

	pi.on("turn_start", async (_event, ctx) => {
		if (restoring) return;
		if (pos < checkpoints.length) {
			// New agent work after an undo invalidates the redo stack (standard semantics).
			// Persist the truncation so replay-after-restart performs the same op.
			const count = pos;
			checkpoints = checkpoints.slice(0, count);
			pi.appendEntry<StoredEvent>(ENTRY_TYPE, { kind: "truncate", count });
		}
		const leaf = ctx.sessionManager.getLeafEntry();
		const cp: Checkpoint = {
			tree: await captureTree(),
			anchor: leaf?.parentId ?? null,
			leaf: leaf?.id ?? null,
			atRoot: !leaf || leaf.parentId === null,
			ts: Date.now(),
		};
		checkpoints.push(cp);
		pos = checkpoints.length;
		persistCheckpoint(cp);
		persistPos();
		updateStatus(ctx);
	});

	pi.on("agent_end", async () => {
		if (restoring) return;
		const tree = await captureTree();
		if (tree) expectedTree = tree;
	});

	// ------------------------------------------------------- shared undo logic

	async function confirmIfDirty(ctx: ExtensionCommandContext, expected: string | null): Promise<boolean> {
		if (!expected) return true; // no baseline (e.g. fresh session) -> proceed
		const current = await captureTree();
		if (!current || current === expected) return true;
		if (!ctx.hasUI) {
			ctx.ui.notify("Uncommitted changes detected; refusing to overwrite them in non-interactive mode", "warning");
			return false;
		}
		return ctx.ui.confirm(
			"Uncommitted changes detected",
			"The working tree has changes newer than this checkpoint. Restoring will overwrite them. Continue?",
		);
	}

	// ---------------------------------------------------------------- commands

	pi.registerCommand("undo", {
		description: "Step back one checkpoint (files + conversation)",
		handler: async (_args, ctx) => {
			await ctx.waitForIdle();
			if (pos <= 0) {
				ctx.ui.notify("Nothing to undo", "info");
				return;
			}
			const target = checkpoints[pos - 1];
			if (!target) return;

			// Dirty check: compare the live worktree against the state we believe we're at.
			const atState = pos < checkpoints.length ? (checkpoints[pos]?.tree ?? null) : expectedTree;
			if (!(await confirmIfDirty(ctx, atState))) return;

			if (target.tree && !(await treeUsable(target.tree))) {
				ctx.ui.notify(`/undo: checkpoint tree ${target.tree.slice(0, 8)} no longer exists in git`, "error");
				return;
			}

			// Capture redo info BEFORE moving the conversation leaf.
			const preLeaf = ctx.sessionManager.getLeafEntry();
			const wasAtHead = pos === checkpoints.length;
			const snapshot: Checkpoint = {
				tree: await captureTree(),
				anchor: preLeaf?.parentId ?? null,
				leaf: preLeaf?.id ?? null,
				atRoot: !preLeaf || preLeaf.parentId === null,
				ts: Date.now(),
			};

			restoring = true;
			try {
				// Conversation first: if navigation is cancelled, files stay untouched.
				let conversationRewound = false;
				if (target.anchor) {
					const nav = await ctx.navigateTree(target.anchor, { summarize: false, label: "undo" });
					if (nav.cancelled) {
						ctx.ui.notify("/undo cancelled: conversation navigation was blocked", "warning");
						return;
					}
					conversationRewound = true;
				}

				let filesRestored = !target.tree; // conversation-only mode counts as success
				if (target.tree) {
					filesRestored = await restoreTree(target.tree);
				}

				pos -= 1;
				if (wasAtHead) {
					// Leaving the head: record the abandoned state so /redo has a target.
					checkpoints.push(snapshot);
					persistCheckpoint(snapshot);
				}
				persistPos();
				expectedTree = target.tree ?? snapshot.tree;

				const parts = [
					conversationRewound ? "conversation rewound" : "conversation at root; context kept",
					target.tree ? (filesRestored ? "files restored" : "file restore FAILED") : "files skipped (no git)",
				];
				ctx.ui.notify(`Undo: ${parts.join(", ")}`, filesRestored ? "info" : "warning");
				updateStatus(ctx);
			} finally {
				restoring = false;
			}
		},
	});

	pi.registerCommand("redo", {
		description: "Step forward one checkpoint (files + conversation)",
		handler: async (_args, ctx) => {
			await ctx.waitForIdle();
			if (pos >= checkpoints.length - 1) {
				ctx.ui.notify("Nothing to redo", "info");
				return;
			}
			const target = checkpoints[pos + 1];
			if (!target) return;

			const atState = checkpoints[pos]?.tree ?? null;
			if (!(await confirmIfDirty(ctx, atState))) return;

			if (target.tree && !(await treeUsable(target.tree))) {
				ctx.ui.notify(`/redo: checkpoint tree ${target.tree.slice(0, 8)} no longer exists in git`, "error");
				return;
			}

			restoring = true;
			try {
				const navTarget = target.leaf ?? target.anchor;
				if (navTarget) {
					const nav = await ctx.navigateTree(navTarget, { summarize: false, label: "redo" });
					if (nav.cancelled) {
						ctx.ui.notify("/redo cancelled: conversation navigation was blocked", "warning");
						return;
					}
				}
				if (target.tree) {
					const ok = await restoreTree(target.tree);
					if (!ok) ctx.ui.notify("/redo: failed to restore files (git apply failed)", "error");
				}
				pos += 1;
				persistPos();
				expectedTree = target.tree;
				ctx.ui.notify("Redo: state reapplied", "info");
				updateStatus(ctx);
			} finally {
				restoring = false;
			}
		},
	});

	pi.registerCommand("checkpoints", {
		description: "List captured checkpoints",
		handler: async (_args, ctx) => {
			if (checkpoints.length === 0) {
				ctx.ui.notify("No checkpoints yet (one is captured before each agent turn)", "info");
				return;
			}
			const lines = checkpoints.map((cp, i) => {
				const marker = i < pos ? " " : i === pos ? ">" : "+"; // past / current / redo-able
				const time = new Date(cp.ts).toLocaleTimeString();
				const tree = cp.tree ? cp.tree.slice(0, 8) : "(no git)";
				return `${marker} [${i}] ${time}  tree:${tree}`;
			});
			ctx.ui.notify(
				`Checkpoints (${pos}/${checkpoints.length} applied):\n${lines.join("\n")}\n'>' = current, '+' = redo-able`,
				"info",
			);
		},
	});
}
