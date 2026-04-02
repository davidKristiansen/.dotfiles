-- SPDX-License-Identifier: MIT

vim.loader.enable()

-- Leader early
vim.g.mapleader = " "

-- Core
require "core.options"
require "core.winbar"
require "core.autocmds"
require "core.lsp"

-- Keymaps loaded last (all plugins available via plugin/ auto-sourcing)
-- Use after/ directory to ensure keymaps run after all plugin/ files
-- PackChanged hooks live inside each plugin/*.lua file (self-contained)
