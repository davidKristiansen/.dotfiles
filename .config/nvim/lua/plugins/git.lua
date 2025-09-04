return {
  {
    "NeogitOrg/neogit",
    cmd = { "Neogit" },
    dependencies = {
      "nvim-lua/plenary.nvim",  -- required
      "sindrets/diffview.nvim", -- optional - Diff integration
      "ibhagwan/fzf-lua",       -- optional
    },
    opts = {
      integrations = {
        fzf_lua = true
      },
    },
    keys = {
      { "<leader>gn", ":Neogit kind=split<cr>", desc = "Show Neogit" },
    }
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs                        = {
        add          = { text = '┃' },
        change       = { text = '┃' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      signs_staged                 = {
        add          = { text = '┃' },
        change       = { text = '┃' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      signs_staged_enable          = true,
      signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
      numhl                        = false, -- Toggle with `:Gitsigns toggle_numhl`
      linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
      word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir                 = {
        follow_files = true
      },
      auto_attach                  = true,
      attach_to_untracked          = false,
      current_line_blame           = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts      = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 100,
        use_focus = true,
      },
      current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
      sign_priority                = 6,
      update_debounce              = 100,
      status_formatter             = nil,   -- Use default
      max_file_length              = 40000, -- Disable if file is longer than this (in lines)
      preview_config               = {
        -- Options passed to nvim_open_win
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
      },
      on_attach                    = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']h', function()
            if vim.wo.diff then
              vim.cmd.normal({ ']h', bang = true })
            else
              gitsigns.nav_hunk('next')
            end
          end,
          { desc = "Next hunk" }
        )

        map('n', '[h', function()
            if vim.wo.diff then
              vim.cmd.normal({ '[h', bang = true })
            else
              gitsigns.nav_hunk('prev')
            end
          end,
          { desc = "Previous hunk" }
        )

        -- Actions
        map('n', '<leader>gs', gitsigns.stage_hunk, { desc = "Stage hunk" })
        map('n', '<leader>gr', gitsigns.reset_hunk, { desc = "Reset hunk" })

        map('v', '<leader>gs', function()
            gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end,
          { desc = "Stage hunk" }
        )

        map('v', '<leader>gr', function()
            gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end,
          { desc = "Reset hunk" }
        )

        map('n', '<leader>gS', gitsigns.stage_buffer, { desc = "Stage buffer" })
        map('n', '<leader>gR', gitsigns.reset_buffer, { desc = "Reset buffer" })
        map('n', '<leader>gp', gitsigns.preview_hunk, { desc = "Preview hunk" })
        map('n', '<leader>gi', gitsigns.preview_hunk_inline, { desc = "Preview hunk (inline)" })

        -- map('n', '<leader>gb', function()
        --   gitsigns.blame_line({ full = true , { desc = "Blame line" }})
        -- end)

        map('n', '<leader>gd', gitsigns.diffthis, { desc = "Diff this" })

        map('n', '<leader>gD', function()
          gitsigns.diffthis('~')
        end, { desc = "Git this (~)" })

        map('n', '<leader>gQ', function() gitsigns.setqflist('all') end, { desc = "Set quickfix list (all)" })
        map('n', '<leader>hq', gitsigns.setqflist, { desc = "Set quickfix list" })

        -- Toggles
        map('n', '<leader>gb', gitsigns.toggle_current_line_blame, { desc = "Blame line" })
        map('n', '<leader>gw', gitsigns.toggle_word_diff, { desc = "Word diff" })

        -- Text object
        map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, { desc = "Select hunk" })
      end
    },
  },
  {
    "tpope/vim-fugitive"
  },
  {
    "sindrets/diffview.nvim",
  }
}
