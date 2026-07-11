---
name: remove-plugin
description: Safely remove a Neovim plugin and all its configuration from this config
---

## When to use

Use this skill when the user asks to remove, uninstall, or delete a Neovim plugin.

## Steps

1. **Identify all references**
   - The primary file will be `plugin/<name>.lua`.
   - Search for any cross-references in other files:
     - Other `plugin/*.lua` files that might depend on it or reference it.
     - `lua/core/keymaps.lua` (global keymaps that interact with the plugin).
     - `lua/core/lsp/keymaps.lua` (if LSP-related).
     - `lua/plugins/` (legacy config-returning modules).
     - `init.lua` (PackChanged hooks for the plugin).
     - `lsp/<server>.lua` (if the plugin provides an LSP server).
     - `plugin/mason.lua` (if the server was in the `servers` table).
     - `plugin/which-key.lua` (if the plugin had a dedicated `<leader>` group).

2. **Delete the plugin file**
   - Remove `plugin/<name>.lua`.

3. **Clean up cross-references**
   - Remove any `PackChanged` hook in `init.lua` specific to this plugin.
   - Remove the server from `plugin/mason.lua` `servers` table if applicable.
   - Delete `lsp/<server>.lua` if the plugin was the sole reason for that server config.
   - Remove the which-key group from `plugin/which-key.lua` if no other keymaps use that `<leader>` prefix.
   - Delete any files under `lua/plugins/` that were exclusively loaded by the removed plugin file.

4. **Verify no dangling references**
   - Grep the entire config for the plugin's module name (e.g. `require('plugin-name')`) to ensure nothing is left behind.

5. **Update AGENTS.md**
   - Remove the plugin entry from the `plugin/` listing.
   - Remove any mentions of the plugin from other sections (LSP, keymap strategy, etc.) if they were plugin-specific.

6. **Clean up installed files (optional, inform user)**
   - Tell the user to run `:PackClean` (or equivalent) to remove the plugin from disk.
   - If an LSP server was removed from Mason, suggest `:MasonUninstall <server>`.

## Commit

```
chore(nvim): remove <plugin-name>
```

## Checklist

- [ ] `plugin/<name>.lua` deleted
- [ ] PackChanged hooks cleaned from `init.lua` (if any)
- [ ] `plugin/mason.lua` servers table updated (if applicable)
- [ ] `lsp/<server>.lua` deleted (if applicable)
- [ ] `plugin/which-key.lua` group removed (if exclusive to this plugin)
- [ ] `lua/plugins/` helper modules deleted (if exclusive)
- [ ] No dangling `require()` references remain
- [ ] `AGENTS.md` updated
- [ ] Single logical commit with `chore(nvim):` prefix
- [ ] User informed about `:PackClean` / `:MasonUninstall`
