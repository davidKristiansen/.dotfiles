-- SPDX-License-Identifier: MIT
local M = {}

function M.setup()
  -- One place to declare plugins
  vim.pack.add({
    -- Core Lua helpers / UI primitives
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/MunifTanjim/nui.nvim" },

    -- Git plugins
    { src = "https://github.com/NeogitOrg/neogit" },
    { src = "https://github.com/tpope/vim-fugitive" },
    { src = "https://github.com/sindrets/diffview.nvim" },
    { src = "https://github.com/kdheepak/lazygit.nvim" },

    -- LSP / Language Tooling
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },

    -- Completion & AI (order: engine + sources + assistants)
    { src = "https://github.com/saghen/blink.cmp",                         version = "v1.6.0" },
    { src = "https://github.com/fang2hou/blink-copilot" },
    { src = "https://github.com/Kaiser-Yang/blink-cmp-avante" },
    { src = "https://github.com/zbirenbaum/copilot.lua" },
    { src = "https://github.com/yetone/avante.nvim" },

    -- Snippets
    { src = "https://github.com/L3MON4D3/LuaSnip" },
    { src = "https://github.com/rafamadriz/friendly-snippets" },

    -- Navigation / File & Buffer UX
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://github.com/nvim-mini/mini.nvim" },

    -- Editing Enhancements / Text Objects / Increment helpers
    { src = "https://github.com/monaqa/dial.nvim" },
    { src = "https://github.com/bullets-vim/bullets.vim" },
    { src = "https://github.com/windwp/nvim-autopairs" },


    -- UI / Visuals
    { src = "https://github.com/folke/which-key.nvim" },
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
    { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
    { src = "https://github.com/tpope/vim-eunuch" },

    -- Tmux Integration
    { src = "https://github.com/alexghergh/nvim-tmux-navigation" },
    { src = "https://github.com/vimpostor/vim-tpipeline" },
  }, { load = true })

  -- Ensure commands exist in this session
  vim.cmd("packadd nvim-treesitter")
  vim.cmd("packadd dial.nvim") -- ensure dial loaded early so custom <C-a>/<C-x> mappings take effect

  -- Per-plugin setups (ordered by functional groups)
  -- Navigation / File & Buffer UX
  -- require("plugins.oil").setup()
  require("plugins.mini_pick").setup()

  -- Editing Enhancements
  require("plugins.dial").setup()
  require("plugins.mini_surround").setup()
  require("nvim-autopairs").setup()

  -- Snippets
  require("plugins.luasnip").setup()

  -- LSP / Language Tooling
  require("plugins.mason").setup()
  require("plugins.mason-lspconfig").setup()
  require("plugins.treesitter").setup()

  -- Completion & AI
  require("plugins.copilot").setup()
  require("plugins.blink").setup()
  require("plugins.avante").setup()

  -- Git
  require("plugins.neogit").setup()
  require("plugins.diffview").setup()
  -- Fugitive does not require explicit setup, just :Git commands

  -- UI / Visuals
  require("plugins.which_key").setup()
  require("plugins.mini_statusline").setup()
  require("plugins.render_markdown").setup()
  require("plugins.mini_starter").setup()
  require("plugins.mini_files").setup()

  -- Tmux Integration
  require("plugins.tmux_navigation").setup()
  require("plugins.tpipeline").setup()
end

return M
