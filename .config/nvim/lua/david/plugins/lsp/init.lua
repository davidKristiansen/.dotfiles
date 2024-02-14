return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      {
        "hrsh7th/cmp-nvim-lsp",
        dependencies = { "hrsh7th/nvim-cmp" }
      },
      "p00f/clangd_extensions.nvim",
      {
        "folke/neodev.nvim",
        opts = {}
      },
      "folke/trouble.nvim",
      "folke/which-key.nvim",
    },
    opts = {
      inlay_hints = {
        enabled = false
      }
    },
    config = function(_, opts)
      local lspconfig = require("lspconfig")
      local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
      local servers = require("david.plugins.lsp.servers")
      local mason_lspconfig = require("mason-lspconfig")
      local trouble = require("trouble")

      require("david.plugins.lsp.util").on_attach(function(client, buffer)
        require("david.plugins.lsp.keymaps").on_attach(client, buffer)

        if opts.inlay_hints.enabled and client.supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(buffer, true)
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
        "jsonls"
      },
      automatic_installation = true
    }
  },
  {
    'Fymyte/rasi.vim',
    ft = 'rasi',
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    keys = {
      {
        "]t",
        function()
          require("trouble").next({ skip_groups = true, jump = true });
        end,
        desc = "Next Trouble"
      },
      {
        "[t",
        function()
          require("trouble").previous({ skip_groups = true, jump = true });
        end,
        desc = "Previous Trouble"
      },

    }
  },
}
