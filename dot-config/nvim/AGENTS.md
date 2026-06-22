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

All plugins load through one declarative helper, **`lua/utils/lazy.lua`**. A plugin file is a single `require('utils.lazy').add({ ... })` call; the helper owns the load guard, the `vim.pack.add()`, the trigger wiring, the stub→real keymap swap, and error handling (`config` runs under `pcall`). This is the single way to add a plugin — never hand-roll a `loaded` flag, stub table, or `nvim_feedkeys` replay.

**Spec fields:**
- `src` / `deps` — plugin source(s); `deps` load before `src` (string URLs or `{ src=, version=, branch= }` tables).
- **Load tier** (pick one; omit all triggers *and* `lazy` ⇒ `vim.schedule`, "later"):
  - `lazy = false` — eager, during `plugin/` sourcing.
  - `event` — autocmd event(s), e.g. `'InsertEnter'`.
  - `ft` — FileType; table form `{ pattern=, cond=fn(ev) }` adds a per-buffer predicate. On load the helper re-fires FileType so the plugin attaches to the already-open buffer.
  - `cmd` — stub user-command(s) that load then re-run with the original args.
  - `keys` — list of `{ lhs, rhs, desc=, mode=, silent= }`. A stub (with `desc`, for which-key) is registered now; the real keymap is installed from the same entry on load. `rhs` may be a function or a `<cmd>…<cr>` string.
- `cond` — environment gate; if it returns false the plugin never loads (and `init` never runs).
- `init` — runs eagerly at `add()` time (globals/options needed before the plugin loads).
- `config` — runs after `vim.pack.add()` (setup, signs, autocmds, user commands).
- `on_pack_changed` — PackChanged handler, registered before `vim.pack.add()` (e.g. treesitter `TSUpdate`).

Combine triggers in one spec to share a single load guard (e.g. obsidian loads on `ft` markdown-in-vault **or** `<leader>n*` keys). `add()` returns `{ load }` so external triggers (e.g. a buffer-local map) can drive the same guard.

| Tier | Trigger | Plugins |
|------|---------|---------|
| **Eager** (`lazy=false`) | during sourcing | 00-gruvbox, 01-mini, 02-treesitter, which-key |
| **Later** (`vim.schedule`) | next tick | 03-fzf-lua, blink-cmp, dial, gitsigns (git.lua), nvim-mcp, neo-tree lsp-file-operations capabilities |
| **event** | autocmd | blink-pairs (`InsertEnter`), mason (`BufReadPre`/`FileType`) |
| **ft** | FileType | typst (`typst`), vimtex (`tex`), render-markdown (`markdown`), obsidian (`markdown` in vault) |
| **cmd** | user command | sshfs (`:SSHConnect`/`:SSHConfig`) |
| **keys** | first keypress | dap (`<F5>`/`<leader>d*`), neotest (`<leader>t*`), overseer (`<leader>o*`), claudecode (`<leader>a*`), pi (`<leader>p*`), hex (`<leader>Tx`), neo-tree UI (`<leader>e`/`<leader>E`), obsidian (`<leader>n*`), git heavy (`<leader>g*`) |
| **cond** | env gate | tmux (`$TMUX`) |

**Split-loaded plugins:**
- `git.lua` — gitsigns + fugitive on the *later* tier; neogit/diffview/lazygit on `<leader>g*` keys (two `add()` calls).
- `neo-tree.lua` — lsp-file-operations capability advertisement on the *later* tier (must precede LSP attach); the neo-tree UI on `<leader>e`/`<leader>E` keys.
- `obsidian.lua` — one spec, dual trigger: `ft` markdown-in-vault **or** `<leader>n*` keys.

**Exceptions (not routed through the helper):**
- `undotree.lua` — a bundled plugin loaded via `packadd` on `<leader>u` (no `vim.pack` source).
- `worktree.lua` — a self-contained module (no external plugin); `require('utils.worktree').setup()` runs eagerly (cheap: registers `:Worktree` + `<leader>w*`).

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
- claudecode.lua — claudecode.nvim Claude Code IDE integration via WebSocket MCP protocol, keymaps use `<leader>a*` prefix (keymap-triggered: `<leader>ac`/`<leader>af` etc.; neo-tree add via `<leader>as`).
- blink-cmp.lua — Completion engine + LuaSnip + Copilot source (vim.schedule).
- blink-pairs.lua — Auto pairs (InsertEnter).
- dap.lua — Debug adapter protocol (keymap: `<F5>`, `<leader>d*`).
- dial.lua — Increment/decrement augends & keymaps (vim.schedule).
- git.lua — Git integration (split: gitsigns+fugitive vim.schedule, neogit/diffview/lazygit keymap `<leader>g*`).
- hex.lua — Hex editing via xxd (keymap: `<leader>Tx`).
- mason.lua — Mason tool installer (event: first `BufReadPre`/`FileType`).
- neo-tree.lua — File explorer (keymap: `<leader>e`/`<leader>E`) + lsp-file-operations capabilities (later tier; split-loaded, see Lazy Loading Strategy).
- neotest.lua — Test runner: Python, GTest (keymap: `<leader>t*`).
- nvim-mcp.lua — MCP server for AI assistant integration with Neovim (vim.schedule).
- noice.lua_ — noice.nvim UI replacement (disabled, replaced by built-in ui2 in init.lua).
- obsidian.lua — Obsidian note-taking (keymap: `<leader>n*` + FileType markdown in vault).
- overseer.lua — Task runner and job management (keymap: `<leader>o*`).
- codecompanion.lua_ — codecompanion.nvim AI chat (disabled).
- opencode-nickjvandyke.lua_ — opencode.nvim nickjvandyke fork (disabled).
- pi.lua — pi-nvim bridge to pi coding agent, sends context to running pi session (keymap: `<leader>p*`).
- render-markdown.lua — Markdown rendering (FileType: markdown).
- sshfs.lua — Remote file editing (cmd: `:SSHConnect`/`:SSHConfig`; loads the full `SSH*` command set on first use).
- tmux.lua — Tmux navigation integration (vim.schedule, guarded by `$TMUX`).
- typst.lua — Typst language support (FileType: typst).
- undotree.lua — Visual undo history, built-in Neovim 0.12+ (keymap: `<leader>u`).
- vimtex.lua — LaTeX support (FileType: tex).
- which-key.lua — Which-key group definitions (eager).
- worktree.lua — Git worktree management; self-contained module, `setup()` runs eagerly (keymap: `<leader>w*`).

### after/plugin/
- keymaps.lua — Loads `core.keymaps` after all plugins are configured.

### lua/core/
- autocmds.lua — Global autocommands.
- keymaps.lua — Global keymaps (non-LSP). Includes the session picker (`<leader>s`), system-clipboard paste (`<leader>P`), and the start screen (`<leader>h`). Loaded via `after/plugin/keymaps.lua`.
- options.lua — Vim options.
- winbar.lua — Winbar configuration.
- lsp/init.lua — Server config merge + enable logic + attach autocmd setup.
- lsp/keymaps.lua — Buffer-local LSP mappings: declarative keymap table (navigation, code actions, fix_all, formatting, diagnostics). Single source of truth for all LSP keymaps.
- lsp/on_attach.lua — LspAttach handler (inlay hints, formatting toggles, inline completion).
- lsp/fix_all.lua — Deterministic FixAll + QuickFix-all pipeline (Ruff source.fixAll + typos-lsp quickfix + format). No keymaps (those live in lsp/keymaps.lua). Attaches via its own LspAttach autocmd from `fix_all.setup()`. **On-save defaults: both FixAll and format are OFF.** FixAll can be destructive (removes "unused" imports/vars; risky for C), so it is manual only (`<leader>cA` / `:LspFixAll`); format is manual (`<leader>cf`). Per-buffer on-save opt-in via `<leader>Ta` / `:LspFixAllToggle`; format-on-save toggled per session via `<leader>Tf`.

### lsp/ (top-level, Neovim 0.11+ native LSP config)
Server-specific overrides (one file per server):
- bashls.lua, clangd.lua, copilot.lua, jsonls.lua, lua_ls.lua, ruff.lua, rust_analyzer.lua, tinymist.lua, ty.lua, yamlls.lua
- basedpyright.lua — Python refactoring only (typeCheckingMode=off, diagnostics disabled; ruff+ty handle linting/types).

### lua/utils/
- lazy.lua — Declarative lazy-loading helper over `vim.pack`. Single entry point `require('utils.lazy').add(spec)`; see Lazy Loading Strategy. Every `plugin/*.lua` routes through it (except the `undotree`/`worktree` exceptions noted there).
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
| `<leader>f` | find     |
| `<leader>g` | git      |
| `<leader>n` | notes    |
| `<leader>o` | overseer |
| `<leader>a` | ai       |
| `<leader>p` | pi       |
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
10. Each `plugin/*.lua` file is a single `require('utils.lazy').add({ ... })` call that declares its own deps, trigger, setup (`config`), and keymaps (`keys`). The helper owns `vim.pack.add`, the load guard, PackChanged hooks (`on_pack_changed`), and the stub→real keymap swap.
11. Use semantic commits (see Commit Rules); never append a manual changelog.
12. **Lazy loading:** new plugins MUST pick an appropriate `utils.lazy` tier (see Lazy Loading Strategy). Choose the most aggressive trigger that still works correctly. Never hand-roll a `loaded` guard, stub table, or `nvim_feedkeys` replay — the helper provides all of it.
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
