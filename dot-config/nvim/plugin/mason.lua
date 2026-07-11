-- SPDX-License-Identifier: MIT
-- mason + mason-lspconfig + nvim-lspconfig: LSP server INSTALLATION only.
-- Which servers exist is owned by lsp/*.lua (see core.lsp); enabling is done
-- there via vim.lsp.enable(). mason-lspconfig only translates those names to
-- mason packages and installs them — automatic_enable is off.

-- nvim-lspconfig loads eagerly: it only contributes base configs via its lsp/
-- runtime dir, which must be on the runtimepath before the first FileType
-- event resolves the servers enabled by core.lsp.
require('utils.lazy').add({
  src = 'https://github.com/neovim/nvim-lspconfig',
  lazy = false,
})

-- mason stays on the first real buffer so a dashboard-only session never pays
-- for it, while ensure_installed/auto-install still fire as soon as a file is
-- opened.
require('utils.lazy').add({
  src = 'https://github.com/mason-org/mason.nvim',
  deps = {
    'https://github.com/mason-org/mason-lspconfig.nvim',
  },
  event = { 'BufReadPre', 'FileType' },
  config = function()
    require('mason').setup({
      ui = {
        icons = {
          package_installed = '',
          package_pending = '',
          package_uninstalled = '',
        },
      },
    })

    require('mason-lspconfig').setup({
      ensure_installed = require('core.lsp').servers(),
      automatic_enable = false, -- core.lsp owns vim.lsp.enable()
    })
  end,
})
