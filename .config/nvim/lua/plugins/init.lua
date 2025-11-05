-- SPDX-License-Identifier: MIT

-- One place to declare plugins
vim.pack.add({
  { src = "https://github.com/tpope/vim-eunuch" },
  { src = "https://github.com/bullets-vim/bullets.vim" },
}, { confirm = false })

require "plugins.gruvbox"
require "plugins.mini"
require "plugins.telescope"
require "plugins.blink"
require "plugins.dial"
require "plugins.git"
-- require "plugins.lua-json5"
require "plugins.mason"
-- require "plugins.mcphub"
require "plugins.neo-tree"
require "plugins.neotest"
require "plugins.obsidian"
-- require "plugins.overseer"
require "plugins.render_markdown"
require "plugins.sidekick"
require "plugins.tmux"
require "plugins.treesitter"
require "plugins.which_key"
