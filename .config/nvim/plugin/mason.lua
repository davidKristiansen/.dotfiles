-- SPDX-License-Identifier: MIT
-- mason + mason-lspconfig + nvim-lspconfig: LSP server management.

vim.schedule(function()
  vim.pack.add({
      { src = 'https://github.com/mason-org/mason.nvim' },
      { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
      { src = 'https://github.com/neovim/nvim-lspconfig' },
  }, { confirm = false })

  local servers = {
      'ty',
      'bashls',
      'clangd',
      'copilot',
      'jsonls',
      'lua_ls',
      'ruff',
      'yamlls',
      'jinja_lsp',
      'groovyls',
      'marksman',
      'tinymist',
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
end)
