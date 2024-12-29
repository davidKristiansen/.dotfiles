return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      -- "MysticalDevil/inlay-hints.nvim",
      'saghen/blink.cmp',
      "p00f/clangd_extensions.nvim",
      {
        "folke/lazydev.nvim",
        opts = {}
      },
      -- "folke/trouble.nvim",
      "folke/which-key.nvim",
    },
    opts = {
      inlay_hints = {
        enabled = true
      }
    },
    init = function()
      local wk = require('which-key')
      wk.add({
        { "<leader>c", group = "code actions" },
      })
    end,
    config = function(_, opts)
      local lspconfig = require("lspconfig")
      -- local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lsp_capabilities = require("blink.cmp").get_lsp_capabilities()
      local servers = require("david.plugins.lsp.servers")
      local mason_lspconfig = require("mason-lspconfig")
      -- local trouble = require("trouble")

      require("david.plugins.lsp.util").on_attach(function(client, buffer)
        require("david.plugins.lsp.keymaps").on_attach(client, buffer)

        if opts.inlay_hints.enabled and client.supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(true)
        end
      end)

      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities() or {},
        lsp_capabilities or {}
      )

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers.opts[server] or {})

        if servers.setup[server] then
          servers.setup[server](server, server_opts)
        end
        lspconfig[server].setup(server_opts)
      end

      mason_lspconfig.setup({
        handlers = { setup }
      })
    end
  },

  {
    "williamboman/mason.nvim",
    config = true
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim"
    },
    opts = {
      ensure_installed = {
        "lua_ls",
        "clangd",
        "jsonls",
        "ruff",
        "basedpyright"
        -- "pylsp"
      },
      automatic_installation = true
    }
  },
  {
    'jamespeapen/swayconfig.vim'
  }
  -- {
  --   "MysticalDevil/inlay-hints.nvim",
  --   -- config = {
  --   --   require("lazy").setup({
  --   --     "MysticalDevil/inlay-hints.nvim",
  --   --     event = "LspAttach",
  --   --     dependencies = { "neovim/nvim-lspconfig" },
  --   --     config = function()
  --   --       require("inlay-hints").setup()
  --   --     end
  --   --   }) },
  --   opts = {},
  --   cmd = { "InlayHintsToggle" },
  --   keys = {
  --     { "<leader>ci", "<cmd>InlayHintsToggle<cr>", "Toggle inlay hintes" }
  --   }
  -- },
}
