-- SPDX-License-Identifier: MIT

-- One place to declare plugins
vim.pack.add({
  { src = "https://github.com/tpope/vim-eunuch" },
  { src = "https://github.com/bullets-vim/bullets.vim" },
}, { confirm = false })

require "plugins.treesitter"
require "plugins.bigfile"
require "plugins.gruvbox"
require "plugins.mini"

require "plugins.blink_indent"
require "plugins.blink_cmp"
require "plugins.blink_pairs"
require "plugins.dap"
require "plugins.dial"
require "plugins.git"
require "plugins.lua-json5"
require "plugins.mason"
-- require "plugins.mcphub"
require "plugins.neo-tree"
require "plugins.neotest"
require "plugins.obsidian"
-- require "plugins.overseer"
require "plugins.render_markdown"
require "plugins.sidekick"
require "plugins.tmux"
require "plugins.which_key"
require "plugins.tiny-glimmer"
require "plugins.neoscroll"
