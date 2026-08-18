-- SPDX-License-Identifier: MIT

vim.loader.enable()

-- Repair XDG_RUNTIME_DIR before anything can reach serverstart(). stdpath('run')
-- lives under it and Neovim hard-fails on a missing directory instead of falling
-- back, so one bad value takes down every plugin that opens a socket at require
-- time -- fzf-lua does. A devcontainer inherits the host's /run/user/$UID, which
-- is root-owned and empty in the container, so it can never appear. ~/.zshenv
-- fixes the same thing for shells; this covers the launches that never see zsh
-- (MCP servers, `docker exec sh`). Keep the fallback path byte-identical to the
-- one in ~/.zshenv -- if the two disagree, sockets scatter over two directories
-- and instance discovery (nvim-mcp) quietly stops finding anything.
do
  local uid = vim.uv.getuid and vim.uv.getuid()
  local run = vim.env.XDG_RUNTIME_DIR
  if uid and (run == nil or run == '' or vim.fn.filewritable(run) ~= 2) then
    local dir = string.format('%s/xdg-runtime-%d', vim.env.TMPDIR or '/tmp', uid)
    vim.fn.mkdir(dir, 'p', tonumber('700', 8))
    vim.env.XDG_RUNTIME_DIR = dir
  end
end

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
