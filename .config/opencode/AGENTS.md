# Global Rules

## Knowledge Vault

Before starting a task, load the `vault` skill and search for relevant existing notes.

When the conversation produces noteworthy knowledge, ask if it should go in the vault.

## draw.io Diagrams

When creating draw.io diagrams, always ensure they are readable in both light and dark mode:

- Set `adaptiveColors="auto"` on the `<mxGraphModel>` root element
- Fill colors are auto-inverted — no action needed
- Use `light-dark(lightColor,darkColor)` for all `fontColor`, `strokeColor`, and edge colors that would otherwise be a single dark or light value
- Common pairs: `light-dark(#003366,#a1cdf9)` for text/edges, `light-dark(#333,#ccc)` for note text, `light-dark(#827717,#c4b84e)` for note accents
- For inline HTML color attributes in labels, use `style="color:light-dark(#666,#aaa)"` instead of `color="#666"`
- Never hardcode a single dark color for text/strokes without a `light-dark()` wrapper
