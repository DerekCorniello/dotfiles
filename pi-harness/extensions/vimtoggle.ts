import { CustomEditor, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { matchesKey, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type Mode = "insert" | "normal";

class VimToggleEditor extends CustomEditor {
	private mode: Mode = "insert";
	private mouseDown = false;

	private moveCursorFromMouse(data: string): boolean {
		const match = data.match(/^\x1b\[<(\d+);(\d+);(\d+)([Mm])$/);
		if (!match) return false;

		const button = Number(match[1]);
		const x = Number(match[2]);
		const y = Number(match[3]);
		const isRelease = match[4] === "m";
		const isDrag = (button & 32) !== 0;
		const isLeftButton = (button & 3) === 0;
		if (!isLeftButton && !isDrag) return false;

		if (isRelease) {
			this.mouseDown = false;
			return true;
		}

		if (!this.mouseDown) this.mouseDown = true;
		this.placeCursorAtMouse(x, y);
		return true;
	}

	private placeCursorAtMouse(x: number, y: number): void {
		const editor = this as unknown as {
			lastWidth: number;
			scrollOffset: number;
			paddingX: number;
			buildVisualLineMap(width: number): Array<{ logicalLine: number; startCol: number; length: number }>;
			state: { cursorLine: number };
			setCursorCol(col: number): void;
		};
		const paddingX = editor.paddingX ?? 0;
		const layoutWidth = editor.lastWidth ?? 80;
		const visualLines = editor.buildVisualLineMap(layoutWidth);
		const terminalRows = this.tui.terminal.rows;
		const maxVisibleLines = Math.max(5, Math.floor(terminalRows * 0.3));
		const visibleRow = y - 2; // 1-based rows, row 1 is the top border
		if (visibleRow < 0 || visibleRow >= maxVisibleLines) return;
		const visualIndex = (editor.scrollOffset ?? 0) + visibleRow;
		const segment = visualLines[visualIndex];
		if (!segment) return;

		const line = this.getLines()[segment.logicalLine] ?? "";
		const chunkText = line.slice(segment.startCol, segment.startCol + segment.length);
		const clickCol = Math.max(0, x - paddingX - 1);
		let currentWidth = 0;
		let cursorCol = segment.startCol;
		for (const grapheme of [...new Intl.Segmenter(undefined, { granularity: "grapheme" }).segment(chunkText)]) {
			const width = visibleWidth(grapheme.segment);
			if (currentWidth + width > clickCol) break;
			currentWidth += width;
			cursorCol += grapheme.segment.length;
		}

		(editor as unknown as { state: { cursorLine: number } }).state.cursorLine = segment.logicalLine;
		editor.setCursorCol(cursorCol);
	}

	handleInput(data: string): void {
		if (this.moveCursorFromMouse(data)) return;

		if (matchesKey(data, "escape")) {
			if (this.mode === "insert") {
				this.mode = "normal";
				return;
			}
			super.handleInput(data);
			return;
		}

		if (this.mode === "insert") {
			super.handleInput(data);
			return;
		}

		switch (data) {
			case "i":
				this.mode = "insert";
				return;
			case "a":
				this.mode = "insert";
				super.handleInput("\x1b[C");
				return;
			case "h":
				super.handleInput("\x1b[D");
				return;
			case "j":
				super.handleInput("\x1b[B");
				return;
			case "k":
				super.handleInput("\x1b[A");
				return;
			case "l":
				super.handleInput("\x1b[C");
				return;
			case "0":
				super.handleInput("\x01");
				return;
			case "$":
				super.handleInput("\x05");
				return;
			case "x":
				super.handleInput("\x1b[3~");
				return;
		}

		if (data.length === 1 && data.charCodeAt(0) >= 32) return;
		super.handleInput(data);
	}

	render(width: number): string[] {
		const lines = super.render(width);
		if (lines.length > 0) {
			const label = this.mode === "normal" ? " NORMAL " : " INSERT ";
			const last = lines.length - 1;
			lines[last] = truncateToWidth(lines[last]!, Math.max(0, width - label.length), "") + label;
		}
		return lines;
	}
}

type VimState = { enabled: boolean };

export default function (pi: ExtensionAPI) {
	let enabled = true;

	const apply = (ctx: { mode: string; ui: { setEditorComponent(factory?: any): void; notify(message: string, level: "info" | "warning" | "error"): void } }) => {
		if (ctx.mode !== "tui") return;
		if (enabled) {
			ctx.ui.setEditorComponent((tui, theme, keybindings) => new VimToggleEditor(tui, theme, keybindings));
		} else {
			ctx.ui.setEditorComponent(undefined);
		}
	};

	pi.on("session_start", (_event, ctx) => {
		const entry = ctx.sessionManager
			.getEntries()
			.filter((e: unknown): e is { customType: string; data?: VimState } =>
				typeof e === "object" && e !== null && "customType" in e && (e as { customType?: string }).customType === "vimtoggle-state",
			)
			.pop();
		enabled = entry?.data?.enabled ?? true;
		apply(ctx);
	});

	pi.registerCommand("vimtoggle", {
		description: "Toggle the vim-style editor for the input box",
		handler: async (_args, ctx) => {
			if (ctx.mode !== "tui") {
				ctx.ui.notify("Vim toggle is only available in TUI mode", "warning");
				return;
			}
			enabled = !enabled;
			pi.appendEntry<VimState>("vimtoggle-state", { enabled });
			apply(ctx);
			ctx.ui.notify(enabled ? "Vim toggle enabled" : "Vim toggle disabled", "info");
		},
	});
}
