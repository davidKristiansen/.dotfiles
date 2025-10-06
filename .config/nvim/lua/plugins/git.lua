-- SPDX-License-Identifier: MIT
-- lua/plugins/git.lua

local M = {}

function M.setup()
  -- 1) Install plugins
  vim.pack.add({
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
    { src = "https://github.com/NeogitOrg/neogit" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/tpope/vim-fugitive" },
    { src = "https://github.com/sindrets/diffview.nvim" },
    { src = "https://github.com/kdheepak/lazygit.nvim" },
  })

  -- 2) Gitsigns setup
  require("gitsigns").setup({
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "▁" },
      topdelete = { text = "▔" },
      changedelete = { text = "▎" },
      untracked = { text = "┆" }
    },
    on_attach = function(bufnr)
      local gitsigns = package.loaded.gitsigns
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
      end

      -- Navigation with preview (keep focus in source window)
      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          -- local cur_win = vim.api.nvim_get_current_win()
          gitsigns.nav_hunk("next")
          gitsigns.preview_hunk_inline()
          -- if cur_win and vim.api.nvim_win_is_valid(cur_win) then
          --   vim.api.nvim_set_current_win(cur_win)
          -- end
        end
      end, "Git: Next hunk (preview, keep focus)")

      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          -- local cur_win = vim.api.nvim_get_current_win()
          gitsigns.nav_hunk("prev")
          gitsigns.preview_hunk_inline()
          -- if cur_win and vim.api.nvim_win_is_valid(cur_win) then
          --   vim.api.nvim_set_current_win(cur_win)
          -- end
        end
      end, "Git: Previous hunk (preview, keep focus)")

      -- Other hunk actions
      map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "Stage hunk (works on visual selection for partial)")
      map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "Reset hunk (works on visual selection for partial)")
      map("n", "<leader>gh", gitsigns.select_hunk, "Select hunk (then adjust & <leader>gs / <leader>gr to split)")
      map("n", "<leader>gS", gitsigns.stage_buffer, "Stage buffer")
      map("n", "<leader>gp", gitsigns.preview_hunk_inline, "Preview hunk")
      map("n", "<leader>gR", gitsigns.reset_buffer, "Reset buffer")
      map("n", "<leader>gp", gitsigns.preview_hunk, "Preview hunk")
      map("n", "<leader>gu", gitsigns.undo_stage_hunk, "Undo stage hunk")
      map("n", "<leader>gb", gitsigns.toggle_current_line_blame, "Toggle blame")
      map("n", "<leader>gd", gitsigns.diffthis, "Diff (buffer vs index)")
      map("n", "<leader>gD", function() gitsigns.diffthis("~") end, "Diff (vs HEAD)")
    end
  })

  -- 3) Diffview
  require("diffview").setup({})

  -- 4) Neogit
  require("neogit").setup({ kind = "tab", integrations = { diffview = true } })

  -- 5) Global keymaps
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true, desc = desc })
  end

  -- Neogit
  map("n", "<leader>gn", function() require("neogit").open({ kind = "tab" }) end, "Neogit status")
  map("n", "<leader>gc", function() require("neogit").open({ "commit" }) end, "Commit")
  map("n", "<leader>gP", function() require("neogit").open({ "push" }) end, "Push")
  map("n", "<leader>gU", function() require("neogit").open({ "pull" }) end, "Pull")
  map("n", "<leader>gm", function() require("neogit").open({ "merge" }) end, "Merge")

  -- Diffview
  map("n", "<leader>go", ":DiffviewOpen<CR>", "Diffview open")
  map("n", "<leader>gO", ":DiffviewOpen HEAD~1..HEAD<CR>", "Diffview HEAD~1..HEAD")
  map("n", "<leader>gq", ":DiffviewClose<CR>", "Diffview close")
  map("n", "<leader>gt", ":DiffviewToggleFiles<CR>", "Diffview toggle files")
  map("n", "<leader>gf", ":DiffviewFileHistory %<CR>", "File history (file)")
  map("n", "<leader>gF", ":DiffviewFileHistory<CR>", "File history (repo)")

  -- Fugitive
  map("n", "<leader>gG", ":Git<CR>", "Fugitive :Git")
  map("n", "<leader>gB", ":Gblame<CR>", "Fugitive blame")
  map("n", "<leader>gD", ":Gdiffsplit<CR>", "Fugitive diffsplit")

  -- Lazygit
  map("n", "<leader>gg", ":LazyGit<CR>", "Open LazyGit")
end

return M
