-- SPDX-License-Identifier: MIT

-- Leader early
vim.g.mapleader = " "

-- Core
require "core.options"
require "core.winbar"
require "core.autocmds"
require "core.lsp"

-- Plugins (fetch + load + setup)
require "plugins"

require "core.keymaps"
