-- SPDX-License-Identifier: MIT
local M = {}

function M.setup()
  -- One place to declare plugins
  vim.pack.add({
    { src = "https://github.com/sainnhe/gruvbox-material" },

    -- Core Lua helpers / UI primitives
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/MunifTanjim/nui.nvim" },

    -- Navigation / File & Buffer UX
    { src = "https://github.com/ibhagwan/fzf-lua" },

    -- Completion & AI (order: engine + sources + assistants)
    { src = "https://github.com/saghen/blink.cmp",                           version = "v1.7.0" },
    { src = "https://github.com/fang2hou/blink-copilot" },
    { src = "https://github.com/folke/sidekick.nvim" },
    { src = "https://github.com/ravitemer/mcphub.nvim" },
    { src = "https://github.com/obsidian-nvim/obsidian-mcp.nvim" },

    -- LSP / Language Tooling
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },

    -- Snippets
    { src = "https://github.com/L3MON4D3/LuaSnip" },
    { src = "https://github.com/rafamadriz/friendly-snippets" },

    -- Navigation / File & Buffer UX
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://github.com/nvim-mini/mini.nvim" },
    { src = "https://github.com/A7Lavinraj/fyler.nvim" },

    -- Editing Enhancements / Text Objects / Increment helpers
    { src = "https://github.com/monaqa/dial.nvim" },
    { src = "https://github.com/bullets-vim/bullets.vim" },
    { src = "https://github.com/windwp/nvim-autopairs" },

    -- UI / Visuals
    { src = "https://github.com/folke/which-key.nvim" },
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
    { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
    { src = "https://github.com/tpope/vim-eunuch" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },

    -- Tmux Integration
    { src = "https://github.com/alexghergh/nvim-tmux-navigation" },
    { src = "https://github.com/vimpostor/vim-tpipeline" },

    -- Notes
    { src = "https://github.com/obsidian-nvim/obsidian.nvim" },

    -- Git
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
    { src = "https://github.com/NeogitOrg/neogit" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/sindrets/diffview.nvim" },
    { src = "https://github.com/kdheepak/lazygit.nvim" },
    -- picker backend
    { src = "https://github.com/ibhagwan/fzf-lua" },

    -- Test
    { src = "https://github.com/antoinemadec/FixCursorHold.nvim" },
    { src = "https://github.com/nvim-neotest/nvim-nio" },
    { src = "https://github.com/nvim-neotest/neotest" },
    { src = "https://github.com/antoinemadec/FixCursorHold.nvim" },
    { src = "https://github.com/sluongng/neotest-bazel" },
    { src = "https://github.com/rcasia/neotest-bash" },
    { src = "https://github.com/nvim-neotest/neotest-python" },

  }, { load = true })

  require("plugins.gruvbox").setup()

  -- Navigation / File & Buffer UX
  require("plugins.fzf-lua").setup()

  -- Editing Enhancements
  require("plugins.dial").setup()
  require("nvim-autopairs").setup()

  -- Snippets
  require("plugins.luasnip").setup()

  -- LSP / Language Tooling
  require("plugins.mason").setup()
  require("plugins.treesitter").setup()

  -- Completion & AI
  require("plugins.blink").setup()
  require("plugins.sidekick").setup()
  require("plugins.mcphub").setup()

  -- Git
  require("plugins.git").setup()

  -- UI / Visuals
  require("plugins.which_key").setup()
  require("plugins.render_markdown").setup()
  require("plugins.fyler").setup()

  -- Tmux Integration
  require("plugins.tmux_navigation").setup()
  require("plugins.tpipeline").setup()

  -- Notes
  require("plugins.obsidian").setup()

  -- Test
  require("plugins.neotest").setup()

  -- mini
  require("plugins.mini").setup()
end

return M
