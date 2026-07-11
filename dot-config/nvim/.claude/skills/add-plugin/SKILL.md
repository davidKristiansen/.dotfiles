---
name: add-plugin
description: Install and configure a new Neovim plugin following this config's utils.lazy pattern
---

## When to use

Use this skill when the user asks to add, install, or integrate a new Neovim plugin.

## Steps

1. **Read the plugin's README**
   - Fetch `https://raw.githubusercontent.com/<owner>/<repo>/HEAD/README.md` (or the default branch) using WebFetch.
   - Identify: required dependencies, **optional** dependencies, setup options, recommended configuration, and any build steps (e.g. native compilation, `make`, `cargo build`).
   - **Required deps:** if not already in this config, add them via the spec's `deps` list (or as separate plugin files if they need their own config).
   - **Optional deps:** do NOT add them automatically. Ask the user which (if any) they want. Many plugins list multiple alternatives for the same role (e.g. picker, icons, statusline). Prefer what this config already has:
     - Picker: **fzf-lua** (not telescope, not mini.pick)
     - Icons: **mini.icons** (not nvim-web-devicons)
     - Surround: **mini.surround**
     - Statusline: **mini.statusline**
     - Completion: **blink.cmp** (not nvim-cmp)
     - Git signs: **gitsigns.nvim**
   - If an optional dep is already installed in this config, wire it up without asking.

2. **Create `plugin/<name>.lua` as a single `require('utils.lazy').add({ ... })` call**
   - Use a plain name (e.g. `plugin/foo.lua`) unless load order matters, in which case use a numeric prefix (e.g. `plugin/04-foo.lua`).
   - The helper (`lua/utils/lazy.lua`) owns `vim.pack.add`, the load guard, the `pcall` around `config`, the stub→real keymap swap, and PackChanged registration. Do NOT hand-roll any of that.

3. **Declare sources with `src` / `deps`**
   - `src` is the primary plugin; `deps` (loaded first) are required companions. Use string URLs or `{ src=, version=, branch= }` tables.
   - Include only **required** companion plugins and any optional ones the user confirmed.

4. **Pick the most aggressive load tier that still works** (see AGENTS.md → Lazy Loading Strategy):
   - `lazy = false` (eager) only if it must run at startup (e.g. colorscheme).
   - Omit all triggers ⇒ `vim.schedule` ("later") for always-wanted-but-not-blocking plugins.
   - `event` / `ft` / `cmd` / `keys` for on-demand plugins. Prefer `ft` for filetype plugins and `keys` for command/menu plugins.
   - `cond` to gate on environment (e.g. `$TMUX`); `init` for globals that must be set before load.
   ```lua
   require('utils.lazy').add({
     src  = 'https://github.com/<owner>/<repo>',
     deps = { 'https://github.com/<owner>/<dep-repo>' },
     ft   = 'lua',                       -- or event= / cmd= / keys= / lazy=false
     config = function()
       require('<plugin>').setup({ ... })
     end,
     keys = {
       { '<leader>xx', function() require('<plugin>').thing() end, desc = 'Plugin: Do thing' },
     },
   })
   ```

5. **Keymaps go in `keys` (on-demand) or `config` (always-loaded tiers)**
   - For `keys`-triggered plugins, list `{ lhs, rhs, desc=, mode= }` — the helper registers a stub now (for which-key) and the real keymap on load. `rhs` may be a function or a `<cmd>…<cr>` string.
   - For eager/later/event/ft tiers, set keymaps inside `config`.
   - **Every keymap MUST include a `desc`** for which-key discoverability.

6. **Register which-key groups if adding a new `<leader>` prefix**
   - If the plugin introduces a new `<leader>X` group that does not already exist in `plugin/which-key.lua`, add the group there:
   ```lua
   wk.add({ { '<leader>X', group = 'new-group' } }, { mode = { 'n', 'v', 'o' } })
   ```
   - Existing groups: `a` (ai), `c` (code), `g` (git), `s` (search), `T` (toggles), `t` (tests), `n` (notes), `d` (DAP), `e` (explorer), `f` (fix/files).

7. **Build steps**
   - If the README mentions a build step (native compilation, `make`, `cargo build`, etc.), add an `on_pack_changed = function(ev) ... end` handler to the spec (the helper registers it before `vim.pack.add`).

8. **LSP server config (if applicable)**
   - If the plugin provides or requires an LSP server, create `lsp/<server>.lua` at the config root (Neovim 0.11+ native path).
   - Add the server name to the `servers` table in `plugin/mason.lua` if it should be auto-installed by Mason.

9. **Update AGENTS.md**
   - Add the new file to the `plugin/` listing in `AGENTS.md` with a one-line description, maintaining alphabetical order within its section.

## Commit

```
feat(nvim): add <plugin-name> — <one-line purpose>
```

## Checklist

- [ ] Plugin README fetched and reviewed for deps/build steps/setup
- [ ] `plugin/<name>.lua` is a single `require('utils.lazy').add({ ... })` call
- [ ] `src` / `deps` declared (including any required companions)
- [ ] Appropriate load tier chosen (`lazy`/`event`/`ft`/`cmd`/`keys`)
- [ ] All keymaps have `desc`
- [ ] which-key group added if new `<leader>` prefix introduced
- [ ] `AGENTS.md` updated with the new entry
- [ ] Single logical commit with `feat(nvim):` prefix
