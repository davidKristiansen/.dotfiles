import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("copilot-only", {
    description: "Show copilot-only extension status",
    handler: async (_args, ctx) => {
      const all = ctx.modelRegistry.getAll();
      const available = ctx.modelRegistry.getAvailable();
      const allProviders = [...new Set(all.map((m) => m.provider))];
      const availableProviders = [...new Set(available.map((m) => m.provider))];
      ctx.ui.notify(
        `All: ${allProviders.length} providers, ${all.length} models\n` +
        `Available (with auth): ${availableProviders.join(", ") || "(none)"}`,
        "info"
      );
    },
  });
}
