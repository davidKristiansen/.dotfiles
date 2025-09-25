-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  "saghen/blink.cmp",
  version = "1.*",
  -- build = 'cargo build --release',
  event = { "InsertEnter" },
  dependencies = {
    "rafamadriz/friendly-snippets",
    "Kaiser-Yang/blink-cmp-avante",
    "giuxtaposition/blink-cmp-copilot",
    "zbirenbaum/copilot.lua",
  },

  opts = {
    enabled = function()
      local ft, bt = vim.bo.filetype, vim.bo.buftype
      if ft == "copilot-chat" or bt == "prompt" then
        return false
      end
      return true
    end,
    keymap = {
      -- keep your current flow; no Tab hijacking
      ["<Tab>"]     = { "select_next", "fallback" },
      ["<S-Tab>"]   = { "select_prev", "fallback" },
      ["<CR>"]      = { "accept", "fallback" },
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"]     = { "hide", "fallback" },
      ["<Up>"]      = { "select_prev", "fallback" },
      ["<Down>"]    = { "select_next", "fallback" },
      ["<C-p>"]     = { "select_prev", "fallback" },
      ["<C-n>"]     = { "select_next", "fallback" },
      ["<C-up>"]    = { "scroll_documentation_up", "fallback" },
      ["<C-down>"]  = { "scroll_documentation_down", "fallback" },
    },

    signature = { enabled = true },
    appearance = { nerd_font_variant = "mono" },

    completion = {
      accept = { auto_brackets = { enabled = true } },
      ghost_text = {
        enabled = true,
        show_with_menu = false, -- keeps ghost text out when menu is open
      },
      list = { selection = { preselect = false } },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 250,
        treesitter_highlighting = true,
        window = { border = "rounded" },
      },
    },

    sources = {
      per_filetype = {
        codecompanion = { "codecompanion" },
      },

      -- Add "copilot" to your defaults
      default = { "lazydev", "avante", "lsp", "path", "snippets", "buffer", "markdown", "copilot" },

      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100,
        },
        avante = {
          module = "blink-cmp-avante",
          name = "Avante",
          opts = {},
        },

        -- Copilot provider for blink
        copilot = {
          name = "copilot",
          module = "blink-cmp-copilot", -- or "blink-copilot" for the other plugin
          async = true,
          score_offset = 90,            -- float near top, below LazyDev
        },

        cmdline = {
          min_keyword_length = function(ctx)
            if ctx.mode == "cmdline" and string.find(ctx.line, " ") == nil then
              return 3
            end
            return 0
          end,
        },
        markdown = {
          name = "RenderMarkdown",
          module = "render-markdown.integ.blink",
          fallbacks = { "lsp" },
        },
      },
    },

    fuzzy = {
      implementation = "lua",
      use_frecency = true,
      use_proximity = true,
    },

    cmdline = {
      completion = {
        ghost_text = { enabled = true },
        menu = { auto_show = false },
      },
      keymap = { preset = "none" },
    },
  },

  opts_extend = { "sources.default" },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "BlinkCmpMenuOpen",
      callback = function() vim.b.copilot_suggestion_hidden = true end,
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "BlinkCmpMenuClose",
      callback = function() vim.b.copilot_suggestion_hidden = false end,
    })
  end,
}
