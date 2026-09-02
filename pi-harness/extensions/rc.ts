// /rc — alias for the remote-pi extension's /remote-pi command
// dispatches through pi's prompt/command expansion so all subcommands work:
//   /rc, /rc pair, /rc status, /rc stop, /rc setup, ...
export default function (pi) {
	pi.registerCommand("rc", {
		description: "Remote control (alias for /remote-pi)",
		getArgumentCompletions: async () => [
			"setup", "status", "stop", "pair", "devices", "revoke",
			"rename", "set-relay", "relay start", "relay stop",
			"relay status", "relay url", "config", "peers",
		],
		handler: async (args, ctx) => {
			const sub = args.trim();
			ctx.sendUserMessage(`/remote-pi${sub ? " " + sub : " pair"}`, {
				expandPromptTemplates: true,
			});
		},
	});
}
