-- SPDX-License-Identifier: MIT

vim.loader.enable()

-- Leaders early (before any mapping or plugin code runs)
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- Core
require('core.options')
require('core.winbar')
require('core.autocmds')
require('core.lsp')

-- Built-in UI2 (replaces noice.nvim; official 0.12 API despite the underscore)
require('vim._core.ui2').enable({})

-- Keymaps loaded last (all plugins available via plugin/ auto-sourcing)
-- Use after/ directory to ensure keymaps run after all plugin/ files
-- PackChanged hooks live inside each plugin/*.lua file (self-contained)
