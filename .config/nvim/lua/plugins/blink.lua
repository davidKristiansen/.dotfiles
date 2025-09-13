-- SPDX-License-Identifier: MIT

local opts = {
  -- integrate with LuaSnip
  -- enabled = function()
  --   local ft = vim.bo.filetype
  --   return ft ~= "AvanteInput" and ft ~= "oil"
  -- end,

  snippets = { preset = "luasnip" },

  fuzzy = {
    implementation = "prefer_rust_with_warning", -- tries native, falls back to Lua
    prebuilt_binaries = { download = true },     -- allow downloading prebuilts
  },

  -- default sources: tweak order if you like
  sources = {
    default = { "avante", "copilot", "lsp", "path", "snippets", "buffer" },
    providers = {
      copilot = {
        name         = "copilot",
        module       = "blink-copilot", -- if using giuxtaposition plugin, use "blink-cmp-copilot"
        async        = true,
        score_offset = 100,             -- float Copilot higher than LSP if you want
      },
      avante = {
        module = 'blink-cmp-avante',
        name = 'Avante',
        opts = {}
      }
    }, -- you can add "calc", etc., if installed
  },


  appearance = {
    nerd_font_variant = 'mono'
  },

  -- completion behavior
  completion = {
    accept = { auto_brackets = { enabled = true } },
    trigger = {
      show_on_insert = true,
      show_on_trigger_character = true,
    },
    list = {
      selection = { preselect = false },
    },
    -- docs window on the side
    documentation = { auto_show = true },
  },
  -- keymaps (Blink has a preset; we add Tab-friendly behavior)
  keymap = {
    preset        = "default",
    ["<CR>"]      = { "accept", "fallback" },
    ["<C-e>"]     = { "hide" },
    ["<C-Space>"] = { "show" },
    ["<Tab>"]     = { "select_next", "snippet_forward", "fallback" },
    ["<S-Tab>"]   = { "select_prev", "snippet_backward", "fallback" },
    ["<C-b>"]     = { "scroll_documentation_up", "fallback" },
    ["<C-f>"]     = { "scroll_documentation_down", "fallback" },
  },


}


local M = {}

function M.setup()
  local ok, blink = pcall(require, "blink.cmp")
  if not ok then return end

  blink.setup(opts)
end

return M
