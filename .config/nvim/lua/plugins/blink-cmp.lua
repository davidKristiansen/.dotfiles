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
  },

  opts = {
    keymap = {
      -- No preset to avoid overriding our custom logic
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide", "fallback" },
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-up>"] = { "scroll_documentation_up", "fallback" },
      ["<C-down>"] = { "scroll_documentation_down", "fallback" },
    },
    signature = { enabled = true, },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      accept = { auto_brackets = { enabled = true } },
      ghost_text = {
        enabled = true,
        show_with_menu = false
      },
      list = {
        selection = {
          preselect = false,
        }
      },
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
      default = { "lazydev", "avante", "lsp", "path", "snippets", "buffer", "markdown" },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
        avante = {
          module = 'blink-cmp-avante',
          name = 'Avante',
          opts = {
            -- options for blink-cmp-avante
          }
        },
        cmdline = {
          min_keyword_length = function(ctx)
            -- when typing a command, only show when the keyword is 3 characters or longer
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
      --   prebuilt_binaries = {
      --     force_version = "v1.3.1"
      --   },
    },

    cmdline = {
      completion = {
        ghost_text = { enabled = true },
        menu = {
          auto_show = false,
        }
      },
      keymap = {
        preset = "none" },
    },
  },

  opts_extend = { "sources.default" },
}
