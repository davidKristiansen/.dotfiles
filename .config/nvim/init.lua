-- SPDX-License-Identifier: MIT

-- Leader early
vim.g.mapleader = " "

-- Core
require("core.options")
require("core.autocmds")
require("core.lsp")

-- Plugins (fetch + load + setup)
require("plugins").setup()

require("core.keymaps")
