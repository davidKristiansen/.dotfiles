---
name: add-plugin
description: Install and configure a new Neovim plugin following this config's vim.pack pattern
---

## When to use

Use this skill when the user asks to add, install, or integrate a new Neovim plugin.

## Steps

1. **Read the plugin's README**
   - Fetch `https://raw.githubusercontent.com/<owner>/<repo>/HEAD/README.md` (or the default branch) using WebFetch.
   - Identify: required dependencies, **optional** dependencies, setup options, recommended configuration, and any build steps (e.g. native compilation, `make`, `cargo build`).
   - **Required deps:** if not already in this config, add them in the same `vim.pack.add()` call or as separate plugin files if they need their own config.
   - **Optional deps:** do NOT add them automatically. Ask the user which (if any) they want. Many plugins list multiple alternatives for the same role (e.g. picker, icons, statusline). Prefer what this config already has:
     - Picker: **fzf-lua** (not telescope, not mini.pick)
     - Icons: **mini.icons** (not nvim-web-devicons)
     - Surround: **mini.surround**
     - Statusline: **mini.statusline**
     - Completion: **blink.cmp** (not nvim-cmp)
     - Git signs: **gitsigns.nvim**
   - If an optional dep is already installed in this config, wire it up without asking.

2. **Create `plugin/<name>.lua`**
   - Use a plain name (e.g. `plugin/foo.lua`) unless load order matters, in which case use a numeric prefix (e.g. `plugin/04-foo.lua`).
   - The file must be fully self-contained.

3. **Declare dependencies with `vim.pack.add()`**
   - Every plugin file declares its own deps at the top. Duplicates across files are idempotent and harmless.
   - Include only **required** companion plugins and any optional ones the user confirmed.
   ```lua
   vim.pack.add({
     { src = 'https://github.com/<owner>/<repo>' },
     -- required companion:
     { src = 'https://github.com/<owner>/<dep-repo>' },
   }, { confirm = false })
   ```

4. **Setup with `pcall`**
   - Wrap `require('<plugin>').setup(...)` in `pcall` to avoid bootstrap failures on first install.
   ```lua
   local ok, plugin = pcall(require, '<plugin>')
   if not ok then return end
   plugin.setup({ ... })
   ```

5. **Define keymaps inline**
   - Plugin-specific keymaps belong in the same `plugin/<name>.lua` file.
   - **Every keymap MUST include a `desc` field** for which-key discoverability.
   ```lua
   vim.keymap.set('n', '<leader>xx', function() ... end, { desc = 'Plugin: Do thing' })
   ```

6. **Register which-key groups if adding a new `<leader>` prefix**
   - If the plugin introduces a new `<leader>X` group that does not already exist in `plugin/which-key.lua`, add the group there:
   ```lua
   wk.add({ { '<leader>X', group = 'new-group' } }, { mode = { 'n', 'v', 'o' } })
   ```
   - Existing groups: `a` (ai), `c` (code), `g` (git), `s` (search), `T` (toggles), `t` (tests), `n` (notes), `d` (DAP), `e` (explorer), `f` (fix/files).

7. **PackChanged hooks (only if needed)**
   - If the README mentions a build step (native compilation, `make`, `cargo build`, etc.), add a `PackChanged` autocmd **inside the same plugin file**, before `vim.pack.add()`.

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
- [ ] `plugin/<name>.lua` created, self-contained
- [ ] `vim.pack.add()` declared at top (including any companion plugins)
- [ ] Setup wrapped in `pcall`
- [ ] All keymaps have `desc`
- [ ] which-key group added if new `<leader>` prefix introduced
- [ ] `AGENTS.md` updated with the new entry
- [ ] Single logical commit with `feat(nvim):` prefix
