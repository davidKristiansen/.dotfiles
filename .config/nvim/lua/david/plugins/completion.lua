return {
  {
    'saghen/blink.cmp',
    -- build = "cargo build --release",
    version = "*",
    dependencies = {
      'rafamadriz/friendly-snippets',
      "onsails/lspkind.nvim",
    },
    -- version = '*',
    config = function()
      local neogen = require('neogen')
      local opts = {
        keymap = {
          preset        = 'default',
          ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
          ["<C-e>"]     = { "hide", "fallback" },
          ['<Tab>']     = {
            function(cmp)
              if neogen.jumpable() then
                neogen.jump_next()
              else
                return cmp.select_next()
              end
            end,
            "snippet_forward",
            "fallback"
          },
          ['<S-Tab>']   = {
            function(cmp)
              if neogen.jumpable() then
                neogen.jump_prev()
              else
                return cmp.select_prev()
              end
            end,
            "snippet_backward",
            "fallback"
          },
          ['<CR>']      = { 'accept', 'fallback' },

          ["<Up>"]      = { "select_prev", "fallback" },
          ["<Down>"]    = { "select_next", "fallback" },
          ["<C-p>"]     = { "select_prev", "fallback" },
          ["<C-n>"]     = { "select_next", "fallback" },
          ["<C-up>"]    = { "scroll_documentation_up", "fallback" },
          ["<C-down>"]  = { "scroll_documentation_down", "fallback" },
        },
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = 'mono'
        },

        fuzzy = {
          -- When enabled, allows for a number of typos relative to the length of the query
          -- Disabling this matches the behavior of fzf
          -- use_typo_resistance = false,
          -- Frecency tracks the most recently/frequently used items and boosts the score of the item
          use_frecency = true,
          -- Proximity bonus boosts the score of items matching nearby words
          use_proximity = true,
          -- UNSAFE!! When enabled, disables the lock and fsync when writing to the frecency database. This should only be used on unsupported platforms (i.e. alpine termux)
          use_unsafe_no_lock = false,
          -- Controls which sorts to use and in which order, falling back to the next sort if the first one returns nil
          -- You may pass a function instead of a string to customize the sorting
          sorts = { 'score', 'sort_text' },

          prebuilt_binaries = {
            -- Whether or not to automatically download a prebuilt binary from github. If this is set to `false`
            -- you will need to manually build the fuzzy binary dependencies by running `cargo build --release`
            download = true,
            -- Ignores mismatched version between the built binary and the current git sha, when building locally
            ignore_version_mismatch = false,
            -- When downloading a prebuilt binary, force the downloader to resolve this version. If this is unset
            -- then the downloader will attempt to infer the version from the checked out git tag (if any).
            --
            -- Beware that if the fuzzy matcher changes while tracking main then this may result in blink breaking.
            force_version = nil,
            -- When downloading a prebuilt binary, force the downloader to use this system triple. If this is unset
            -- then the downloader will attempt to infer the system triple from `jit.os` and `jit.arch`.
            -- Check the latest release for all available system triples
            --
            -- Beware that if the fuzzy matcher changes while tracking main then this may result in blink breaking.
            force_system_triple = nil,
            -- Extra arguments that will be passed to curl like { 'curl', ..extra_curl_args, ..built_in_args }
            extra_curl_args = {}
          },
        },
        -- default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
        },
        completion = {
          -- experimental auto-brackets support
          accept = { auto_brackets = { enabled = true } },
          list = {
            selection = { preselect = false, auto_insert = true },
          },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 250,
            treesitter_highlighting = true,
            window = { border = "rounded" },
          },
          menu = {
            border = "rounded",

            cmdline_position = function()
              if vim.g.ui_cmdline_pos ~= nil then
                local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
                return { pos[1] - 1, pos[2] }
              end
              local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
              return { vim.o.lines - height, 0 }
            end,

            draw = {
              columns = {
                { "kind_icon", "label", gap = 1 },
                { "kind" },
              },
              components = {
                kind_icon = {
                  text = function(item)
                    local kind = require("lspkind").symbol_map[item.kind] or ""
                    return kind .. " "
                  end,
                  highlight = "CmpItemKind",
                },
                label = {
                  text = function(item)
                    return item.label
                  end,
                  highlight = "CmpItemAbbr",
                },
                kind = {
                  text = function(item)
                    return item.kind
                  end,
                  highlight = "CmpItemKind",
                },
              },
            },
          },
        },

        -- experimental signature help support
        signature = {
          enabled = true,
          window = { border = "rounded" },
        }
      }
      require("blink.cmp").setup(opts)
    end,
    -- allows extending the providers array elsewhere in your config
    -- without having to redefine it
    opts_extend = { "sources.default" }
  },
}
