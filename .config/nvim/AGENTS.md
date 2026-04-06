# Agents

This document describes the CURRENT state of the Neovim configuration (no historical changelog). It must be kept up to date; delete or rewrite instead of appending history. Prefer clarity over chronology.

## Commit Rules (for agents & contributors)

Use semantic conventional commit prefixes focused on Neovim scope:
- chore(nvim): for maintenance / refactors / non-feature tweaks
- feat(nvim): for new user-visible functionality (new plugin, mapping, feature toggle)
- fix(nvim): for bug fixes or correcting broken behavior
- docs(nvim): for documentation-only edits (including updating this file)
- perf(nvim): for performance improvements
- style(nvim): for purely stylistic changes (whitespace, formatting) with no logic impact
- refactor(nvim): for structural changes that neither fix a bug nor add a feature
- test(nvim): for test related changes (if tests are added later)

Only one logical change per commit. Keep scope minimal. Do NOT maintain a manual changelog; the git history provides traceability.

## Architecture Overview

This config uses the **`plugin/` directory auto-sourcing pattern** based on `vim.pack`. Each `plugin/*.lua` file is self-contained: it declares its own dependencies via `vim.pack.add()`, then configures the plugin immediately. Files are auto-sourced alphabetically by Neovim during startup — no central orchestrator or `require()` chain needed.

Load order is controlled via numeric-prefix naming (e.g. `00-gruvbox.lua` loads before `bigfile.lua`). Duplicate `vim.pack.add()` calls across files are harmless (idempotent).

Startup sequence:
1. `init.lua` — `vim.loader.enable()`, leader key, core modules (options, winbar, autocmds, LSP), built-in ui2.
2. `plugin/*.lua` — auto-sourced alphabetically (each file registers its lazy-load trigger; most code runs deferred).
3. `after/plugin/*.lua` — runs after all plugin/ files (global keymaps).

### Lazy Loading Strategy

Plugins use **aggressive lazy loading** to minimize blocking startup. Every `plugin/*.lua` file is still self-contained, but the actual `vim.pack.add()` + `require(...).setup()` is wrapped in a deferred trigger:

| Tier | Trigger | When it runs | Plugins |
|------|---------|-------------|---------|
| **Eager** | none | During `plugin/` sourcing | 00-gruvbox, 01-mini, 02-treesitter, which-key |
| **vim.schedule** | Next event loop tick | After first draw, before interaction | 03-fzf-lua, blink-cmp, mason, dial, tmux (guarded by `$TMUX`), sshfs, worktree, git (gitsigns + fugitive only) |
| **InsertEnter** | First insert mode | When user starts typing | blink-pairs |
| **FileType** | Specific filetype opened | When relevant file is opened | typst (`typst`), vimtex (`tex`), render-markdown (`markdown`, `opencode_output`), obsidian (`markdown` inside vault) |
| **Keymap** | First keypress of mapped key | On demand | dap (`<F5>`/`<leader>d*`), neotest (`<leader>t*`), neo-tree (`<leader>e`), undotree (`<leader>u`), obsidian (`<leader>n*`), opencode (`<leader>o*`), git heavy plugins (`<leader>g*` except gitsigns keys) |

**Keymap-triggered pattern:** Stub keymaps are defined eagerly (with `desc` for which-key). On first press, the stub loads the plugin, sets real keymaps, and replays the key via `nvim_feedkeys`. A `loaded` guard prevents double-loading.

**FileType-triggered pattern:** A `once = true` autocmd calls `vim.pack.add()` + setup, then `vim.cmd('doautocmd FileType')` to re-trigger for the current buffer.

**Split-loaded plugins:**
- `git.lua` — gitsigns + fugitive via `vim.schedule`; neogit/diffview/lazygit via keymap stubs.
- `obsidian.lua` — loads on `<leader>n*` keymap OR `FileType markdown` inside vault.

## Directory Layout

Top-level files:
- init.lua — Entry point: `vim.loader.enable()`, leader key, core requires, built-in ui2.
- AGENTS.md — This living document.
- nvim-pack-lock.json — vim.pack lockfile.
- .luarc.json — lua_ls workspace config.

### .opencode/ (OpenCode agent config)
- skills/add-plugin/SKILL.md — Skill for installing a new plugin.
- skills/remove-plugin/SKILL.md — Skill for removing a plugin.

### plugin/ (auto-sourced by Neovim, alphabetical order)

Files with numeric prefixes load first:
- 00-gruvbox.lua — Colorscheme (must be first, eager).
- 01-mini.lua — mini.nvim modules: icons, statusline, starter, sessions, surround, align, bufremove (eager).
- 02-treesitter.lua — Treesitter languages, features, textobjects, PackChanged hook (eager).
- 03-fzf-lua.lua — fzf-lua fuzzy finder setup, actions, ui-select (vim.schedule).

Then alphabetically:
- bigfile.lua — Large file handling (custom BufReadPre autocmd, no plugin).
- blink-cmp.lua — Completion engine + LuaSnip + Copilot source (vim.schedule).
- blink-pairs.lua — Auto pairs (InsertEnter).
- dap.lua — Debug adapter protocol (keymap: `<F5>`, `<leader>d*`).
- dial.lua — Increment/decrement augends & keymaps (vim.schedule).
- git.lua — Git integration (split: gitsigns+fugitive vim.schedule, neogit/diffview/lazygit keymap `<leader>g*`).
- mason.lua — Mason tool installer (vim.schedule).
- neo-tree.lua — File explorer (keymap: `<leader>e`).
- neotest.lua — Test runner: Python, GTest (keymap: `<leader>t*`).
- noice.lua_ — noice.nvim UI replacement (disabled, replaced by built-in ui2 in init.lua).
- obsidian.lua — Obsidian note-taking (keymap: `<leader>n*` + FileType markdown in vault).
- opencode.lua — opencode.nvim AI agent integration (nickjvandyke fork), keymaps use `<leader>o` prefix (keymap: `<leader>o*`).
- render-markdown.lua — Markdown rendering (FileType: markdown, opencode_output).
- sshfs.lua — Remote file editing (vim.schedule).
- tmux.lua — Tmux navigation integration (vim.schedule, guarded by `$TMUX`).
- typst.lua — Typst language support (FileType: typst).
- undotree.lua — Visual undo history, built-in Neovim 0.12+ (keymap: `<leader>u`).
- vimtex.lua — LaTeX support (FileType: tex).
- which-key.lua — Which-key group definitions (eager).
- worktree.lua — Git worktree management (vim.schedule).

### after/plugin/
- keymaps.lua — Loads `core.keymaps` after all plugins are configured.

### lua/core/
- autocmds.lua — Global autocommands.
- keymaps.lua — Global keymaps (non-LSP). Includes session keymaps (`<leader>ss` select, `<leader>sw` write, `<leader>sd` delete). Loaded via `after/plugin/keymaps.lua`.
- options.lua — Vim options.
- winbar.lua — Winbar configuration.
- lsp/init.lua — Server config merge + enable logic + attach autocmd setup.
- lsp/keymaps.lua — Buffer-local LSP mappings (fzf-lua pickers, no telescope).
- lsp/on_attach.lua — LspAttach handler (inlay hints, formatting toggles, omnifunc).
- lsp/fix_all.lua — Fix-all code action helper.

### lsp/ (top-level, Neovim 0.11+ native LSP config)
Server-specific overrides (one file per server):
- bashls.lua, clangd.lua, copilot.lua, jsonls.lua, lua_ls.lua, ruff.lua, rust_analyzer.lua, tinymist.lua, ty.lua, yamlls.lua
- basedpyright.lua_ (disabled, note trailing underscore).

### lua/utils/
- picker.lua — Library of fzf-lua picker functions (files, grep, LSP, zoxide, sessions). Session pickers show `display_name  /decoded/path` format. Pure module, no setup side-effects.
- worktree.lua — Git worktree utilities (setup called from `plugin/worktree.lua`).

### lua/plugins/ (legacy, mostly removed)
Only config-returning modules remain (loaded by plugin/ files):
- mini/minis/*.lua — Option tables for individual mini modules (loaded by `plugin/01-mini.lua`).
  - **sessions.lua** — mini.sessions config with path-encoded session naming (`/` → `%`), display name metadata via `~/.local/share/nvim/session_meta.json`, VimEnter auto-restore (`nested = true`), `post_read` hook for plugin re-attachment, and `_G._session_helpers` global for cross-module access.
- neotest/auto.lua — Auto-watch test file logic (loaded by `plugin/neotest.lua`).

## LSP Configuration Model

- Native Neovim 0.11+ LSP config via `lsp/<server>.lua` at the config root.
- `lua/core/lsp/init.lua` handles server enable logic and attach autocmd.
- on_attach.lua sets:
  - Buffer keymaps via `lua/core/lsp/keymaps.lua`
  - Inlay hints (if server supports)
  - Omnifunc
  - `:LspOnTypeFormatToggle` and `:LspFormatOnSaveToggle` buffer commands

## Keymap Strategy

- Global mappings: `lua/core/keymaps.lua` (loaded after plugins via `after/plugin/keymaps.lua`)
- LSP buffer-local: `lua/core/lsp/keymaps.lua` invoked from on_attach
- Plugin-specific: defined inline in each `plugin/*.lua` file
- Keymap-triggered plugins: stub keymaps defined eagerly, real keymaps set on load
- All keymaps MUST include `desc` for discoverability (which-key).

### Which-key groups (defined in `plugin/which-key.lua`)

| Prefix       | Group    |
|-------------|----------|
| `<leader>c` | code     |
| `<leader>d` | debug    |
| `<leader>e` | explorer |
| `<leader>g` | git      |
| `<leader>n` | notes    |
| `<leader>o` | opencode |
| `<leader>s` | session  |
| `<leader>t` | tests    |
| `<leader>T` | toggles  |
| `<leader>w` | worktree |
| `]`         | next ->  |
| `[`         | prev <-  |
| `g`         | goto     |
| `z`         | folds/scroll |

When adding a plugin that introduces a new `<leader>` prefix, register the group in `plugin/which-key.lua`.

## Guidelines For Agents

1. Minimize scope; touch only what the request needs.
2. Keep this file authoritative — rewrite outdated content instead of appending.
3. **Add a plugin:** use the `add-plugin` skill (`.opencode/skills/add-plugin/SKILL.md`).
4. **Remove a plugin:** use the `remove-plugin` skill (`.opencode/skills/remove-plugin/SKILL.md`).
5. Use `pcall(require, ...)` for new plugin setup to avoid bootstrap failures.
6. Provide `desc` for ALL user-facing keymaps.
7. **LSP changes:** create/modify `lsp/<server>.lua` at the config root (Neovim 0.11+ native path).
8. Ask for clarification before large structural refactors.
9. Plugin file naming: use numeric prefix only when load order matters (e.g. `00-`, `01-`). Otherwise use plain `<name>.lua`.
10. Each `plugin/*.lua` file is fully self-contained: deps (`vim.pack.add()`), PackChanged hooks, setup, and keymaps.
11. Use semantic commits (see Commit Rules); never append a manual changelog.
12. **Lazy loading:** new plugins MUST use an appropriate lazy-load tier (see table above). Choose the most aggressive trigger that still works correctly. Keymap-triggered plugins need eager stub keymaps with `desc` + a `loaded` guard + `nvim_feedkeys` replay.
13. **After any change**, verify AGENTS.md still reflects reality. Update the lazy loading table, plugin list, and which-key groups if needed.

## Quick Reference

Add a new plugin: `plugin/<name>.lua` (see `add-plugin` skill)
Remove a plugin: delete `plugin/<name>.lua` + cleanup (see `remove-plugin` skill)
Add server override: `lsp/<server>.lua`
Toggle on-type formatting: `:LspOnTypeFormatToggle`
Toggle format on save: `:LspFormatOnSaveToggle`

## What This Document Is Not

- Not a historical log (git history is enough)
- Not a backlog or roadmap
- Not a place for speculative ideas (open an issue instead)

## LLM Agent Behavior

Operate surgically, keep state consistent, and ensure AGENTS.md always reflects reality post-change. Explain uncertainties before acting on ambiguous requests.
