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

  ---------------------------------------------------------------------------
  -- DRY helpers
  ---------------------------------------------------------------------------
  local function after_zt(fn_or_cmd)
    if type(fn_or_cmd) == "function" then
      fn_or_cmd()
    else
      vim.cmd.normal({ fn_or_cmd, bang = true })
    end
    vim.cmd("normal! zt")
  end

  -- 2) Gitsigns setup
  require("gitsigns").setup({
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "▁" },
      topdelete = { text = "▔" },
      changedelete = { text = "▎" },
      untracked = { text = "┆" },
    },
    on_attach = function(bufnr)
      local gitsigns = package.loaded.gitsigns
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
      end

      -- Other hunk actions
      map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
      map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
      map("n", "<leader>gh", gitsigns.select_hunk, "Select hunk")
      map("n", "<leader>gS", gitsigns.stage_buffer, "Stage buffer")
      map("n", "<leader>gp", gitsigns.preview_hunk_inline, "Preview hunk")
      map("n", "<leader>gR", gitsigns.reset_buffer, "Reset buffer")
      map("n", "<leader>gu", gitsigns.undo_stage_hunk, "Undo stage hunk")
      map("n", "<leader>gb", gitsigns.toggle_current_line_blame, "Toggle blame")
      map("n", "<leader>gd", gitsigns.diffthis, "Diff (buffer vs index)")
      map("n", "<leader>gD", function() gitsigns.diffthis("~") end, "Diff (vs HEAD)")

      -- Change base using mini.pick (fallback to vim.ui.select)
      map("n", "<leader>gC", function()
        local refs = vim.fn.systemlist(
          "git for-each-ref --format='%(refname:short)' refs/heads refs/remotes 2>/dev/null"
        )
        if vim.v.shell_error ~= 0 or #refs == 0 then
          vim.notify("No git refs found", vim.log.levels.WARN)
          return
        end
        local ok_pick, pick = pcall(require, "mini.pick")
        if ok_pick and pick and pick.start then
          pick.start({
            source = {
              items = refs,
              name = "Git refs",
              choose = function(item)
                if item then gitsigns.change_base(item) end
              end,
            },
          })
        else
          vim.ui.select(refs, { prompt = "Select git base ref" }, function(choice)
            if choice then gitsigns.change_base(choice) end
          end)
        end
      end, "Change base (pick ref)")
    end,
  })

  -- 3) Diffview helpers
  local function git_list_refs()
    return vim.fn.systemlist(
      "git for-each-ref --format='%(refname:short)' refs/heads refs/remotes refs/tags 2>/dev/null"
    )
  end

  local function diff_local_vs(ref, only_current_file)
    if not ref or ref == "" then return end
    local cmd = ("DiffviewOpen HEAD..%s"):format(ref)
    if only_current_file then cmd = cmd .. " -- %" end
    vim.cmd(cmd)
  end

  local function pick_ref_and_open_diff(only_current_file)
    local refs = git_list_refs()
    if vim.v.shell_error ~= 0 or #refs == 0 then
      vim.notify("No git refs found", vim.log.levels.WARN)
      return
    end
    local ok_pick, pick = pcall(require, "mini.pick")
    if ok_pick and pick and pick.start then
      pick.start({
        source = {
          items = refs,
          name = "Git refs (right side)",
          choose = function(item) diff_local_vs(item, only_current_file) end,
        },
      })
    else
      vim.ui.select(refs, { prompt = "Select ref (right side)" }, function(choice)
        diff_local_vs(choice, only_current_file)
      end)
    end
  end

  require("diffview").setup({
    enhanced_diff_hl = true,
    default_args = { DiffviewOpen = { "--imply-local" } },
    view = {
      default = { layout = "diff2_horizontal", winbar_info = true, disable_diagnostics = false },
      merge_tool = { layout = "diff3_horizontal", disable_diagnostics = true, winbar_info = true },
      file_history = { layout = "diff2_horizontal", winbar_info = true, disable_diagnostics = true },
    },
  })

  -- 4) Neogit
  require("neogit").setup({ kind = "tab", integrations = { diffview = true } })

  -- 5) Global keymaps
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true, desc = desc })
  end

  map("n", "]c", function()
    if vim.wo.diff or vim.b.diffview_view ~= nil then
      vim.cmd.normal({ "]c", bang = true })
    else
      local ok, gs = pcall(require, "gitsigns")
      if ok then
        gs.nav_hunk("next")
        gs.preview_hunk_inline()
      else
        vim.cmd.normal({ "]c", bang = true })
      end
    end
    vim.cmd("normal! zt")
  end, "Next change (zt align + preview if not diffview)")

  map("n", "[c", function()
    if vim.wo.diff or vim.b.diffview_view ~= nil then
      vim.cmd.normal({ "[c", bang = true })
    else
      local ok, gs = pcall(require, "gitsigns")
      if ok then
        gs.nav_hunk("prev")
        gs.preview_hunk_inline()
      else
        vim.cmd.normal({ "[c", bang = true })
      end
    end
    vim.cmd("normal! zt")
  end, "Prev change (zt align + preview if not diffview)")


  -- Diffview: repo-wide and file-only pickers (local ← vs picked →)
  map("n", "<leader>gO", function() pick_ref_and_open_diff(false) end, "Diffview local ← vs pick →")
  map("n", "<leader>go", function() pick_ref_and_open_diff(true) end, "Diffview local ← vs pick → (file)")

  map("n", "<leader>gq", ":DiffviewClose<CR>", "Diffview close")
  map("n", "<leader>gt", ":DiffviewToggleFiles<CR>", "Diffview toggle files")
  map("n", "<leader>gf", ":DiffviewFileHistory %<CR>", "File history (file)")
  map("n", "<leader>gF", ":DiffviewFileHistory<CR>", "File history (repo)")

  -- Neogit
  map("n", "<leader>gn", function() require("neogit").open({ kind = "tab" }) end, "Neogit status")
  map("n", "<leader>gc", function() require("neogit").open({ "commit" }) end, "Commit")
  map("n", "<leader>gP", function() require("neogit").open({ "push" }) end, "Push")
  map("n", "<leader>gU", function() require("neogit").open({ "pull" }) end, "Pull")
  map("n", "<leader>gm", function() require("neogit").open({ "merge" }) end, "Merge")

  -- Fugitive
  map("n", "<leader>gG", ":Git<CR>", "Fugitive :Git")
  map("n", "<leader>gB", ":Gblame<CR>", "Fugitive blame")
  map("n", "<leader>gD", ":Gdiffsplit<CR>", "Fugitive diffsplit")

  -- Lazygit
  map("n", "<leader>gg", ":LazyGit<CR>", "Open LazyGit")
end

return M
