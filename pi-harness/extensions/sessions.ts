import { Container, SelectList, Spacer, Text } from "@earendil-works/pi-tui";
import { SessionManager, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.registerCommand("sessions", {
		description: "Browse and switch sessions for this project",
		handler: async (_args, ctx) => {
			await ctx.waitForIdle();
			let sessions = await SessionManager.list(ctx.cwd);
			if (sessions.length === 0) sessions = await SessionManager.listAll();
			const picked = await ctx.ui.custom<string | null>((tui, theme, _kb, done) => {
				const container = new Container();
				container.addChild(new Text(theme.fg("accent", theme.bold("Sessions"))));
				container.addChild(new Spacer(1));
				if (sessions.length === 0) {
					container.addChild(new Text(theme.fg("muted", "No previous sessions found for this directory")));
					container.addChild(new Spacer(1));
					container.addChild(new Text(theme.fg("dim", "esc close")));
					return { render: (width: number) => container.render(width), invalidate: () => container.invalidate(), handleInput: (data: string) => { if (data === "\x1b") done(null); } };
				}
				const items = sessions.map((s) => ({ value: s.path, label: `${s.modified.toLocaleString()}  ${s.name || s.firstMessage?.replace(/\s+/g, " ").slice(0, 80) || "(empty)"}` }));
				const select = new SelectList(items, Math.min(items.length, 12), { selectedPrefix: (text) => theme.fg("accent", text), selectedText: (text) => theme.fg("accent", text), description: (text) => theme.fg("muted", text), scrollInfo: (text) => theme.fg("dim", text), noMatch: (text) => theme.fg("warning", text) });
				select.onSelect = (item) => done(item.value);
				select.onCancel = () => done(null);
				container.addChild(select);
				container.addChild(new Spacer(1));
				container.addChild(new Text(theme.fg("dim", "↑↓ navigate • enter select • esc cancel")));
				return { render: (width: number) => container.render(width), invalidate: () => container.invalidate(), handleInput: (data: string) => { select.handleInput(data); tui.requestRender(); } };
			}, { overlay: true });
			if (!picked || ctx.sessionManager.getSessionFile() === picked) return;
			await ctx.switchSession(picked);
		},
	});
}
