-- SPDX-License-Identifier: MIT

local M = {}

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

function M.setup()
  local ok, fzf = pcall(require, "fzf-lua")
  if not ok then return end

  fzf.setup({
    winopts = {
      -- park the UFO in the bottom-left pasture
      row = 1.0,  -- 1.0 = bottom of screen
      col = 0.0,  -- 0.0 = left edge
      height = 0.5,
      width  = 0.5,
      border = "rounded",
      -- put the prompt at the bottom to match the vibe
      -- (set to true if you prefer prompt at top)
      -- fzf-lua: prompt is at bottom by default; leave as-is or set:
      --  preview = { default = "bat_native" },
      preview = {
        layout = "horizontal", -- results left, preview right
      },
    },
  })

  -- convenience: safe wrapper that falls back smartly
  local function safe_call(fn, fallback)
    local ok2 = pcall(fn)
    if not ok2 and fallback then fallback() end
  end

  -- files (git first, then everything)
  map("n", "<leader>F", function()
    safe_call(function() fzf.git_files() end, function() fzf.files() end)
  end, { desc = "Find files (git or all)" })

  map("n", "<leader>f", function()
    fzf.files()
  end, { desc = "Find files (git or all)" })

  map("n", "<leader>sf", function()
    fzf.files()
  end, { desc = "Search files (all)" })

  -- live grep across project
  map("n", "<leader>sg", function()
    fzf.live_grep()
  end, { desc = "Live grep" })

  -- grep current word
  map("n", "<leader>sw", function()
    fzf.grep_cword()
  end, { desc = "Grep word under cursor" })

  -- buffers, help
  map("n", "<leader>sb", function()
    fzf.buffers()
  end, { desc = "List buffers" })

  map("n", "<leader>sh", function()
    fzf.help_tags()
  end, { desc = "Help tags" })

  -- resume last picker (fallback to files if none yet)
  map("n", "<leader><leader>", function()
    safe_call(function() fzf.resume() end, function() fzf.files() end)
  end, { desc = "Resume last picker" })
end

return M

