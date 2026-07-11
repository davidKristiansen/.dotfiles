# LSP rewiring — Spec

## Overview
Restructure the Neovim LSP setup so behavior is legible and trustworthy: `lsp/` becomes the
single source of truth for servers, formatting gains a safe hunk-only-on-save default, the
dangerous FixAll-on-save path is deleted, and LSP logic scattered across `plugin/mason.lua`
and `plugin/neo-tree.lua` is consolidated into `lua/core/lsp/`.

## Users & goals
- **Users:** David (sole user of this config).
- **Primary job:** trust what happens on save, and be able to see the whole LSP wiring in one place.
- **Success for the user:** format-on-save is actually usable (safe by construction), and reading `lua/core/lsp/` + `lsp/` explains everything.

## User stories
- As the user, I want format-on-save to touch only lines I changed, so third-party code is never reformatted.
- As the user, I want FixAll to be strictly manual, so destructive fixes (esp. in C) never run implicitly.
- As the user, I want one directory (`lsp/`) that lists and configures every server, so there is no hidden second list.
- As the user, I want keymaps/toggles for each format granularity (line / changed / buffer), so I control formatting explicitly.

## Scope
**In scope (v1):**
- New formatting module in `lua/core/lsp/` with three granularities: line, changed hunks (via gitsigns hunk API), whole buffer.
- Format-on-save **on by default**, hunk-scoped, everywhere (including C). Untracked/new files count as fully changed — no special treatment.
- Delete the FixAll on-save pipeline: `pipeline()`, per-buffer toggle, `<leader>Ta`, `:LspFixAllToggle`, and its `LspAttach` autocmd. `fix_all.lua` keeps only `run()` + `<leader>cA` + `:LspFixAll`.
- `lsp/` = single source of truth: a file per server (stub `return {}` where no config is needed — add jinja_lsp, groovyls, marksman, typos_lsp). `core.lsp` scans `lsp/` and calls `vim.lsp.enable()` explicitly.
- Mason demoted to installation only: `ensure_installed` derived from the `lsp/` scan; mason-lspconfig auto-enable turned off.
- Move the `vim.lsp.config('*', { capabilities = lsp-file-operations })` block from `plugin/neo-tree.lua` into `core.lsp`.
- Single `LspAttach` autocmd owned by `core.lsp`.
- Toggle namespace under `<leader>T`, including the currently-buried `vim.g` toggles (inlay hints, on-type formatting).
- Fix stale header comments (e.g. `lsp/copilot.lua` claiming `lua/lsp/servers/cpilot.lua`).

**Keymap layout:**

| Key | Action |
|---|---|
| `<leader>cf` (n) | Format changed hunks |
| `<leader>cf` (x) | Format selection |
| `<leader>cF` | Format whole buffer |
| `<leader>cl` | Format current line |
| `<leader>Tf` | Toggle format-on-save (buffer) |
| `<leader>TF` | Toggle format-on-save (global) |
| `<leader>Th` | Toggle inlay hints |
| `<leader>cA` | FixAll (manual only) |

**Non-goals:**
- No new plugins (conform.nvim etc.) — native `vim.lsp.buf.format` + gitsigns hunks.
- No changes to which servers are used, their settings, or completion (blink-cmp) wiring.
- No FixAll-on-save capability in any form, not even opt-in.

## Acceptance criteria
- WHEN a tracked file with local modifications is saved THEN the system SHALL format only the git-modified hunk ranges and SHALL NOT touch unmodified lines.
- WHEN an untracked/new file is saved THEN the system SHALL format the entire file (whole file = one hunk).
- WHEN a file with no modifications is saved THEN the system SHALL perform no formatting.
- WHEN a C file is saved THEN the system SHALL apply the same hunk-only formatting (no C carve-out) and SHALL NOT run FixAll.
- WHEN `<leader>cA` or `:LspFixAll` is invoked THEN the system SHALL run FixAll on the buffer; there SHALL be no other trigger for FixAll.
- WHEN Neovim starts THEN every server with a file in `lsp/` SHALL be enabled via an explicit `vim.lsp.enable()` call driven by scanning `lsp/`, and mason-lspconfig SHALL NOT auto-enable servers.
- WHEN a new `lsp/<server>.lua` file is added THEN the server SHALL be both installed (mason ensure_installed) and enabled with no other file edited.
- WHEN any LSP client attaches THEN exactly one `LspAttach` autocmd (owned by `core.lsp`) SHALL run.
- WHEN `<leader>Tf`/`<leader>TF` is pressed THEN format-on-save SHALL toggle for the buffer/globally with a notify confirming the new state.

### Edge cases & failure behavior
- No LSP client supports range formatting for the buffer → skip hunk formatting silently on save (whole-buffer `<leader>cF` may still work if document formatting is supported).
- gitsigns not attached / not a git repo → treat file as untracked (format whole file) only if buffer has no git baseline; otherwise skip rather than guess.
- Save must never error because of formatting: failures degrade to "no format", never block the write.

## Constraints
- **Stack / platform:** Neovim 0.11+ native LSP (`vim.lsp.config` / `vim.lsp.enable`, `lsp/` runtime dir). Lua, existing `utils.lazy` pattern.
- **Dependencies / integrations:** gitsigns (hunk detection), mason + mason-lspconfig (install only), nvim-lspconfig (base configs), lsp-file-operations (capabilities merge, moved to core.lsp).
- **Must not change:** navigation/docs keymaps (`gd`, `grr`, `gri`, `grt`, `gl`, `gD`, `grn`, `gra`, `K`, `<C-k>`, `[d`/`]d`); `<C-F>` inline-completion accept and `<C-G>` select; copilot-only inline-completion gating; `utils.lazy` loading pattern; mason still auto-installs all servers; server settings in existing `lsp/*.lua`.
- **Non-functional:** save latency must stay unnoticeable; sync format timeout comparable to today (~800ms budget).

## Boundaries
- **Always:** follow existing code style (SPDX headers, declarative keymap tables); run `graphify update .` after code changes; verify with a real save in a git repo.
- **Ask first:** adding any new plugin; changing keymaps outside the table above; touching blink-cmp/completion wiring.
- **Never:** reintroduce FixAll-on-save; leave LSP logic in `plugin/neo-tree.lua`; keep a second server list outside `lsp/`.

## Success metrics & definition of done
- Open a Python file in a git repo: edit one function, save → only that hunk is reformatted; `<leader>cA` runs Ruff fixAll; nothing fixes on save.
- Open a C file: save formats only changed hunks; FixAll never fires implicitly.
- `:checkhealth vim.lsp` / attach check: all 15 servers still attach as before.
- All keymaps/toggles in the table above work and show in which-key.
- `grep -rn "lsp" plugin/` shows no LSP wiring outside mason's install list.

## Open questions / assumptions — resolved during implementation
- mason-lspconfig v2 confirmed installed; `automatic_enable = false` used. The old `automatic_installation = true` was a v1 leftover (no-op) and was dropped.
- `<leader>cl` was free. `<leader>Th`/`<leader>Tf`/`<leader>Ti` collided with global LSP toggles in `lua/core/keymaps.lua` — those moved into `core.lsp.keymaps` (consolidation); `<leader>Ti` (inline completion) kept its lhs. On-type formatting toggle = `<leader>To`.
- nvim-lspconfig loads eagerly (`lazy = false`) — its base configs must be on the runtimepath before the first FileType resolves enabled servers; mason itself stays lazy.
- The lsp-file-operations `'*'` capabilities are inlined statically in `core.lsp` (identical to `default_capabilities()`), removing the old startup race where early-attached servers missed them.
- Bug found & fixed en route: `lsp/rust_analyzer.lua` had `diagnostics` at top level where vim.lsp.config ignores it — now properly nested under `settings['rust-analyzer']` (rust-analyzer diagnostics are now actually disabled, as intended).
- Bug found & fixed en route: `fix_all.run()` applied a client's fixAll edit *and* its stale per-diagnostic quickfix edits, corrupting the buffer; quickfixes are now skipped for clients whose source action applied (quickfix-only servers like typos-lsp unaffected).
