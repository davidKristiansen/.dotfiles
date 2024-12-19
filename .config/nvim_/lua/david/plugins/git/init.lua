return {

  {
    'lewis6991/gitsigns.nvim',
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "folke/which-key.nvim"
    },
    cmd = { "Gitsigns" },
    init = function()
      local wk = require('which-key')
      wk.add({
        { "<leader>g", group = "git" },
      })
    end,
    opts = {
      on_attach = function(bufnr)
        require("david.plugins.git.keymaps").on_attach(bufnr)
      end,
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
        delay = 0,
        ignore_whitespace = false,
        virt_text_priority = 1000,
      },
    }
  },
  {
    'sindrets/diffview.nvim',
    dependencies = {
      "tpope/vim-fugitive"
    },
    opts = {
      keymaps = {
        file_panel = {
          {
            "n", "cc",
            "<Cmd>Git commit <bar> wincmd J<CR>",
            { desc = "Commit staged changes" },
          },
          {
            "n", "ca",
            "<Cmd>Git commit --amend <bar> wincmd J<CR>",
            { desc = "Amend the last commit" },
          },
          {
            "n", "c<space>",
            ":Git commit ",
            { desc = "Populate command line with \":Git commit \"" },
          },
        },
      }
    },
    cmd = { "DiffviewOpen" },
    keys = {
      { "<leader>fg", "<cmd>DiffviewToggleFiles<cr>", "Gitview" }
    }
  },
  -- {
  --   "kdheepak/lazygit.nvim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --   },
  --   cmd = { "LazyGit" },
  --   keys = {
  --     { "<leader>gl", "<cmd>LazyGit<CR>", desc = "Lazygit" }
  --   },
  --   opts = {},
  --   config = function(_, opts)
  --     require("telescope").load_extension("lazygit")
  --   end
  -- },
  {
    "NeogitOrg/neogit",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",  -- required
      "sindrets/diffview.nvim", -- optional - Diff integration

      -- Only one of these is needed, not both.
      "nvim-telescope/telescope.nvim", -- optional
      "ibhagwan/fzf-lua",              -- optional
    },
    init = function()
      local group = vim.api.nvim_create_augroup('MyCustomNeogitEvents', { clear = true })
      vim.api.nvim_create_autocmd('User', {
        pattern = 'NeogitPushComplete',
        group = group,
        callback = require('neogit').close,
      })
    end,

    opts = {
      kind = "split",
      signs = {
        -- { CLOSED, OPENED }
        section = { "", "" },
        item = { "", "" },
        hunk = { "", "" },
      },
      integrations = {
        diffview = true,
        telescope = true,
        fzf_lua = true,
      },
    }
  },
  {
    "tpope/vim-fugitive",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { '<leader>gD', ':Gvdiffsplit ', "Diff (vsplit)" }
    }
  }
}
