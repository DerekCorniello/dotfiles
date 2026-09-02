// notify — desktop notifications for pi
//
// Routes through notify-send, so it lands in whatever daemon is running
// (swaync/mako/dunst). Fires when:
//   - an agent turn that took >=8s finishes (skips quick back-and-forth)
//   - the agent stops for a question/permission while you're away (turn end
//     with pending question surfaces as a normal finished turn here; the
//     ask-user extension handles its own surfacing)
// Mute/unmute any time: /notify off | /notify on

import { execFile } from "node:child_process";

const MIN_TURN_MS = 8000;

function send(title: string, body: string) {
	try {
		execFile("notify-send", ["-a", "pi", title, body], { timeout: 5000 }, () => undefined);
	} catch {
		/* no notifier installed — stay silent */
	}
}

export default function (pi: ExtensionAPI) {
	let muted = false;
	let turnStarted = 0;

	pi.on("turn_start", () => {
		turnStarted = Date.now();
	});

	pi.on("agent_end", async (_event, ctx) => {
		if (muted) return;
		const dur = Date.now() - turnStarted;
		if (turnStarted === 0 || dur < MIN_TURN_MS) return;
		const name = ctx.sessionManager.getSessionName() ?? "pi";
		send(`✅ ${name}`, `Turn finished in ${Math.round(dur / 1000)}s`);
	});

	// Session-level errors surface as agent_end too; catch hard failures via
	// provider errors ending the turn early — covered by the same path.

	pi.registerCommand("notify", {
		description: "Toggle desktop notifications (/notify on|off)",
		getArgumentCompletions: async () => ["on", "off"],
		handler: async (args, ctx) => {
			const sub = args.trim().toLowerCase();
			if (sub === "off") muted = true;
			else if (sub === "on") muted = false;
			else muted = !muted; // bare /notify toggles
			ctx.ui.notify(`Desktop notifications ${muted ? "muted" : "on"}`, "info");
		},
	});
}
