-- SPDX-License-Identifier: MIT

-- Leader early
vim.g.mapleader = " "

-- Core
require("core.options")
require("core.colorscheme")
require("core.autocmds")
require("core.keymaps")

-- Plugins (fetch + load + setup)
require("plugins").setup()

-- LSP
require("lsp").setup()
