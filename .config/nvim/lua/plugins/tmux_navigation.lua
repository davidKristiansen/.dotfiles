-- SPDX-License-Identifier: MIT
-- lua/plugins/tmux_navigation.lua
-- Seamless navigation between Neovim splits and tmux panes.
-- Mirrors the original lazy spec options while fitting current project conventions.

local M = {}

function M.setup()
  local ok, nav = pcall(require, 'nvim-tmux-navigation')
  if not ok then return end

  nav.setup({
    disable_when_zoomed = true, -- Prevent navigation when tmux pane is zoomed
  })
end

return M

