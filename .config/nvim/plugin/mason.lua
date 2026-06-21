-- SPDX-License-Identifier: MIT
-- mason + mason-lspconfig + nvim-lspconfig: LSP server management.
-- Loaded on the first real buffer (BufReadPre/FileType) so a dashboard-only
-- session never pays for it, while ensure_installed/auto-install still fire as
-- soon as a file is opened.

require('utils.lazy').add({
  src = 'https://github.com/mason-org/mason.nvim',
  deps = {
    'https://github.com/mason-org/mason-lspconfig.nvim',
    'https://github.com/neovim/nvim-lspconfig',
  },
  event = { 'BufReadPre', 'FileType' },
  config = function()
    local servers = {
      'basedpyright',
      'ty',
      'bashls',
      'clangd',
      'copilot',
      'jsonls',
      'lua_ls',
      'ruff',
      'rust_analyzer',
      'yamlls',
      'jinja_lsp',
      'groovyls',
      'marksman',
      'tinymist',
      'typos_lsp',
    }

    require('mason').setup({
      ui = {
        icons = {
          package_installed   = '',
          package_pending     = '',
          package_uninstalled = '',
        },
      },
    })

    require('mason-lspconfig').setup({
      ensure_installed       = servers,
      automatic_installation = true,
    })
  end,
})
