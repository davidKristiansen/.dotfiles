-- SPDX-License-Identifier: MIT
-- lua/plugins/tpipeline.lua
-- Integrates vim-tpipeline for tmux + Neovim statusline passthrough.
-- Only activates inside a tmux session (env var TMUX present).
-- Keeps configuration minimal so lualine remains the statusline provider.

local M = {}

function M.setup()
  if not vim.env.TMUX then
    return -- Do nothing when not inside a tmux session
  end

  -- vim-tpipeline is a Vimscript plugin; no Lua require needed.
  -- Enable automatic embedding of Neovim's statusline into tmux.
  vim.g.tpipeline_autoembed = 1

  -- Link StatusLine highlight to WinSeparator for a cohesive minimal look.
  -- pcall(vim.cmd, 'hi link StatusLine WinSeparator')
  --
  -- -- Hide Neovim's native statusline so tmux embedded line (from tpipeline) is the only one visible.
  -- local previous_laststatus = vim.o.laststatus
  -- vim.o.laststatus = 0
  --
  -- -- Restore previous laststatus on exit (defensive; in case user detaches from tmux later).
  -- vim.api.nvim_create_autocmd('VimLeavePre', {
  --   once = true,
  --   callback = function()
  --     pcall(function()
  --       vim.o.laststatus = previous_laststatus
  --     end)
  --   end,
  -- })
  --
  -- -- Maintain thin style characters (used if a statusline briefly reappears or during restoration).
  -- local existing = vim.o.fillchars
  -- local needed = 'stl:─,stlnc:─'
  -- if existing == '' then
  --   vim.o.fillchars = needed
  -- else
  --   if not existing:match('stl:') then existing = existing .. ',' .. needed end
  --   vim.o.fillchars = existing
  -- end
end

return M

