-- SPDX-License-Identifier: MIT
-- lua/plugins/tpipeline.lua
-- Integrates vim-tpipeline for tmux + Neovim statusline passthrough.
-- Only activates inside a tmux session (env var TMUX present).
-- Keeps configuration minimal so lualine remains the statusline provider.


vim.pack.add({
  { src = "https://github.com/alexghergh/nvim-tmux-navigation" },
  { src = "https://github.com/vimpostor/vim-tpipeline" },
}, { confirm = false })

if not vim.env.TMUX then
  return -- Do nothing when not inside a tmux session
end

require("nvim-tmux-navigation").setup({
  disable_when_zoomed = true, -- Prevent navigation when tmux pane is zoomed
})

vim.g.tpipeline_autoembed = 1
