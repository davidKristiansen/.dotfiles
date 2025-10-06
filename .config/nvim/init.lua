-- SPDX-License-Identifier: MIT

-- Leader early
vim.g.mapleader = " "

-- Core
require("core.options")
require("core.colorscheme")
require("core.autocmds")

-- Plugins (fetch + load + setup)
require("plugins").setup()

require("core.keymaps")
