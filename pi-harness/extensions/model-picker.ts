import { type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Container, SelectList, Spacer, Text, type SelectItem } from "@earendil-works/pi-tui";

function formatModelLabel(provider: string, id: string, name?: string) {
	return name ? `${provider}/${id} — ${name}` : `${provider}/${id}`;
}

const THINKING_LEVELS = ["off", "minimal", "low", "medium", "high", "xhigh", "max"] as const;

export default function (pi: ExtensionAPI) {
	const openPicker = async (ctx: any) => {
		if (ctx.mode !== "tui") {
			ctx.ui.notify("Model picker requires TUI mode", "warning");
			return;
		}

		const current = ctx.model;
		const models = ctx.modelRegistry.getAvailable().slice().sort((a, b) => {
			const aCurrent = current && a.provider === current.provider && a.id === current.id;
			const bCurrent = current && b.provider === current.provider && b.id === current.id;
			if (aCurrent && !bCurrent) return -1;
			if (!aCurrent && bCurrent) return 1;
			const providerCmp = a.provider.localeCompare(b.provider);
			if (providerCmp !== 0) return providerCmp;
			return a.id.localeCompare(b.id);
		});

		if (models.length === 0) {
			ctx.ui.notify("No available models found", "warning");
			return;
		}

		const items: SelectItem[] = models.map((model) => {
			const isCurrent = current && model.provider === current.provider && model.id === current.id;
			return {
				value: `${model.provider}/${model.id}`,
				label: `${formatModelLabel(model.provider, model.id, model.name)}${isCurrent ? " (current)" : ""}`,
				description: `${model.contextWindow.toLocaleString()} ctx · ${model.maxTokens.toLocaleString()} out${model.reasoning ? " · reasoning" : ""}${model.input.includes("image") ? " · vision" : ""}`,
			};
		});

		const choice = await ctx.ui.custom((tui, theme, _kb, done) => {
			const container = new Container();
			container.addChild(new Text(theme.fg("accent", theme.bold("Pick a model"))));
			container.addChild(new Spacer(1));

			const select = new SelectList(items, Math.min(items.length, 12), {
				selectedPrefix: (text) => theme.fg("accent", text),
				selectedText: (text) => theme.fg("accent", text),
				description: (text) => theme.fg("muted", text),
				scrollInfo: (text) => theme.fg("dim", text),
				noMatch: (text) => theme.fg("warning", text),
			});

			select.onSelect = (item) => done(item.value);
			select.onCancel = () => done(null);

			container.addChild(select);
			container.addChild(new Spacer(1));
			container.addChild(new Text(theme.fg("dim", "↑↓ navigate • enter select • esc cancel")));

			return {
				render(width: number) {
					return container.render(width);
				},
				invalidate() {
					container.invalidate();
				},
				handleInput(data: string) {
					select.handleInput(data);
					tui.requestRender();
				},
			};
		}, { overlay: true });

		if (!choice) return;
		const [provider, ...rest] = choice.split("/");
		const modelId = rest.join("/");
		const model = ctx.modelRegistry.find(provider, modelId);
		if (!model) {
			ctx.ui.notify(`Model not found: ${choice}`, "warning");
			return;
		}

		const level = await ctx.ui.select("Thinking level", [...THINKING_LEVELS]);
		const thinking = typeof level === "string" ? level : null;

		const ok = await pi.setModel(model);
		if (!ok) {
			ctx.ui.notify(`No API key configured for ${choice}`, "error");
			return;
		}

		if (thinking) {
			pi.setThinkingLevel(thinking as any);
		}

		ctx.ui.notify(`Model set to ${choice}${thinking ? ` · thinking ${thinking}` : ""}`, "info");
	};

	pi.registerCommand("model-picker", {
		description: "Pick a model and thinking level",
		handler: async (_args, ctx) => {
			await openPicker(ctx);
		},
	});

	pi.registerCommand("thinking", {
		description: "Set the thinking level",
		handler: async (_args, ctx) => {
			const level = await ctx.ui.select("Thinking level", [...THINKING_LEVELS]);
			if (!level) return;
			pi.setThinkingLevel(level as any);
			ctx.ui.notify(`Thinking: ${level}`, "info");
		},
	});

	pi.registerShortcut("ctrl+shift+m", {
		description: "Open model picker",
		handler: async (ctx) => {
			await openPicker(ctx);
		},
	});
}
}
