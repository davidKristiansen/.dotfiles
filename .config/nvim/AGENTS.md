# Agents

This document describes the CURRENT state of the Neovim configuration (no historical changelog). It must be kept up to date; delete or rewrite instead of appending history. Prefer clarity over chronology.

## Commit Rules (for agents & contributors)

Use semantic conventional commit prefixes focused on Neovim scope:
- chore(nvim): for maintenance / refactors / non‑feature tweaks
- feat(nvim): for new user‑visible functionality (new plugin, mapping, feature toggle)
- fix(nvim): for bug fixes or correcting broken behavior
- docs(nvim): for documentation-only edits (including updating this file)
- perf(nvim): for performance improvements
- style(nvim): for purely stylistic changes (whitespace, formatting) with no logic impact
- refactor(nvim): for structural changes that neither fix a bug nor add a feature
- test(nvim): for test related changes (if tests are added later)

Only one logical change per commit. Keep scope minimal. Do NOT maintain a manual changelog; the git history provides traceability.

## Directory Layout

Top-level files:
- init.lua – Entry point; bootstraps core + plugin setup.
- AGENTS.md – This living document (no history section).

lua/core/
- autocmds.lua – Global autocommands.
- colorscheme.lua – Colorscheme & highlight tweaks.
- keymaps.lua – Global keymaps (non-LSP).
- options.lua – Vim options.

lua/plugins/
- init.lua – Declares plugin specs (vim.pack) & ordered setup.
- avante.lua – Avante AI assistant config.
- blink.lua – Completion engine config.
- copilot.lua – Copilot provider config.
- dial.lua – Increment/decrement augends & keymaps.
- fyler.lua – Project/file picker integration.
- git.lua – Git integration helpers.
- luasnip.lua – Snippet engine + loaders.
- mini_align.lua – mini.align setup.
- mini_files.lua – mini.files navigation.
- mini_icons.lua – mini.icons setup.
- mini_pick.lua – mini.pick fuzzy finding.
- mini_starter.lua – Start screen.
- mini_statusline.lua – Statusline config.
- mini_surround.lua – Surround mappings.
- oil.lua – Oil file explorer.
- render_markdown.lua – Markdown rendering enhancements.
- sidekick.lua – sidekick.nvim setup.
- tmux_navigation.lua – nvim-tmux-navigation config.
- tpipeline.lua – tmux pipeline + statusline embedding.
- treesitter.lua – Treesitter languages & features.
- which_key.lua – which-key group definitions.

lua/lsp/
- init.lua – Server config merge + enable logic + attach autocmd setup.
- keymaps.lua – Buffer-local LSP mappings.
- on_attach.lua – LspAttach handler (inlay hints, formatting toggles, omnifunc).
- servers/ (optional overrides) – Only this path is used (legacy fallback removed).

lua/utils/ (if present)
- once.lua – One-time execution helper.


## LSP Configuration Model

- Per-server override file path: lua/lsp/servers/<server>.lua returning a table merged (force) with default lspconfig definition.
- No legacy fallback module paths are consulted (servers/ only).
- M.enable_servers({list}) uses new vim.lsp.config/vim.lsp.enable API when available; falls back to lspconfig.setup/start otherwise.
- on_attach.lua sets:
  - Buffer keymaps via lsp/keymaps.lua
  - Inlay hints (if server supports)
  - Omnifunc
  - :LspOnTypeFormatToggle and :LspFormatOnSaveToggle buffer commands

## Keymap Strategy

- Global mappings: lua/core/keymaps.lua
- LSP buffer-local: lua/lsp/keymaps.lua invoked from on_attach
- AI / provider cycling: plugins/avante.lua
- All keymaps include desc for discoverability (which-key).

## Plugin Load Order (summary)
Declared in plugins/init.lua then setup in this sequence:
1. Navigation (mini_pick)
2. Editing (dial, mini_surround, autopairs, mini_align)
3. Snippets (luasnip)
4. Language tooling (plugins.lsp, treesitter)
5. Completion & AI (blink, sidekick)
6. Git (git)
7. UI / Visual (which_key, mini_statusline, render_markdown, mini_starter, mini_files)
8. Terminal integration (tmux_navigation, tpipeline)

## Guidelines For Agents

1. Minimize scope; touch only what request needs.
2. Keep this file authoritative—rewrite outdated content instead of appending.
3. Add plugin: spec in plugins/init.lua, create plugins/<name>.lua with M.setup(), require it at correct position.
4. Use pcall(require, ...) for new plugin setup to avoid bootstrap failures.
5. Provide desc for all user-facing keymaps.
6. Use semantic commits (see Commit Rules); never append a manual changelog.
7. LSP changes: create/modify lua/lsp/servers/<id>.lua; avoid editing upstream defaults.
8. Removing a plugin: delete its module, spec, and require() call; then update this document.
9. Ask for clarification before large structural refactors.

## Quick Reference

Add server override: lua/lsp/servers/<id>.lua
Toggle on-type formatting: :LspOnTypeFormatToggle
Toggle format on save: :LspFormatOnSaveToggle
Cycle Avante provider: mapping in plugins/avante.lua (e.g. <leader>ap)

## What This Document Is Not

- Not a historical log (git history is enough)
- Not a backlog or roadmap
- Not a place for speculative ideas (open an issue instead)

## LLM Agent Behavior

Operate surgically, keep state consistent, and ensure AGENTS.md always reflects reality post-change. Explain uncertainties before acting on ambiguous requests.

(Previous activity log removed; rely on git history.)










