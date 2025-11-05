-- SPDX-License-Identifier: MIT
vim.pack.add({

  { src = "https://github.com/obsidian-nvim/obsidian.nvim" },
}, { confirm = false })

-- Resolve a path to its real absolute path (follow symlinks when possible)
local function realpath(p)
  local ok, r = pcall(vim.loop.fs_realpath, p)
  return (ok and r) or vim.fn.fnamemodify(p, ":p")
end

-- Return true if buffer `buf` lives inside one of the vault roots
local function is_in_vault(buf, vault_roots)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then return false end
  local rp = realpath(name)
  for _, root in ipairs(vault_roots) do
    if rp:sub(1, #root) == root then
      return true
    end
  end
  return false
end


-- configure plugin
local vault_path = (os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")) .. "/vault"
require("obsidian").setup({
  legacy_commands = false,
  workspaces = {
    { name = "vault", path = vault_path },
    -- add more if you like
  },
})

-- collect normalized vault roots for membership checks
local vault_roots = {}
for _, ws in ipairs({ { path = vault_path } }) do
  table.insert(vault_roots, realpath(vim.fn.expand(ws.path)))
end

-- helper mappers
local function nmap(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { silent = true, noremap = true, desc = desc })
end
local function bmap(buf, mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true, buffer = buf, desc = desc })
end

---------------------------------------------------------------------------
-- GLOBAL: TOP LEVEL COMMANDS (available anywhere)
---------------------------------------------------------------------------
nmap("<leader>nn", "<cmd>Obsidian new<cr>", "Obsidian: New note")
nmap("<leader>no", "<cmd>Obsidian open<cr>", "Obsidian: Open note/app")
nmap("<leader>ns", "<cmd>Obsidian search<cr>", "Obsidian: Search")
nmap("<leader>nq", "<cmd>Obsidian quick_switch<cr>", "Obsidian: Quick switch")
nmap("<leader>nw", "<cmd>Obsidian workspace<cr>", "Obsidian: Switch workspace")
nmap("<leader>nt", "<cmd>Obsidian today<cr>", "Obsidian: Today")
nmap("<leader>ny", "<cmd>Obsidian yesterday<cr>", "Obsidian: Yesterday (workday)")
nmap("<leader>nT", "<cmd>Obsidian tomorrow<cr>", "Obsidian: Tomorrow (workday)")
nmap("<leader>nd", "<cmd>Obsidian dailies -2 1<cr>", "Obsidian: Dailies (range)")
nmap("<leader>nM", "<cmd>Obsidian new_from_template<cr>", "Obsidian: New from template")
nmap("<leader>ng", "<cmd>Obsidian tags<cr>", "Obsidian: Tags")

---------------------------------------------------------------------------
-- BUFFER-LOCAL: NOTE / VISUAL COMMANDS (markdown AND inside a vault)
---------------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  group = vim.api.nvim_create_augroup("obsidian_note_keymaps", { clear = true }),
  callback = function(ev)
    if not is_in_vault(ev.buf, vault_roots) then return end

    -- Note-context actions
    bmap(ev.buf, "n", "<leader>nb", "<cmd>Obsidian backlinks<cr>", "Obsidian: Backlinks")
    bmap(ev.buf, "n", "<leader>nl", "<cmd>Obsidian links<cr>", "Obsidian: List links in note")
    bmap(ev.buf, "n", "<leader>nh", "<cmd>Obsidian toc<cr>", "Obsidian: Table of contents")
    bmap(ev.buf, "n", "<leader>nr", "<cmd>Obsidian rename<cr>", "Obsidian: Rename + fix backlinks")
    bmap(ev.buf, "n", "<leader>nc", "<cmd>Obsidian toggle_checkbox<cr>", "Obsidian: Toggle checkbox")
    bmap(ev.buf, "n", "<leader>nf", "<cmd>Obsidian follow_link<cr>", "Obsidian: Follow link")
    bmap(ev.buf, "n", "<leader>nm", "<cmd>Obsidian template<cr>", "Obsidian: Insert template")
    bmap(ev.buf, "n", "<leader>np", "<cmd>Obsidian paste_img<cr>", "Obsidian: Paste image")

    -- Visual-mode helpers
    bmap(ev.buf, "x", "<leader>nL", ":Obsidian link<cr>", "Obsidian: Link selection → note")
    bmap(ev.buf, "x", "<leader>nn", ":Obsidian link_new<cr>", "Obsidian: New note from selection")
    bmap(ev.buf, "x", "<leader>ne", ":Obsidian extract_note<cr>", "Obsidian: Extract selection → note")
  end,
})
