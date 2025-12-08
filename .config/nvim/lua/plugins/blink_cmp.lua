-- SPDX-License-Identifier: MIT

vim.pack.add({
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  { src = "https://github.com/saghen/blink.cmp",      version = vim.version.range("1.7") },
  { src = "https://github.com/fang2hou/blink-copilot" },
}, { confirm = false })

-- LuaSnip
local function build_jsregexp()
  local ok, fn = pcall(vim.fn.system, { "make", "install_jsregexp" })
  if not ok then
    vim.notify("LuaSnip jsregexp build failed: " .. tostring(fn), vim.log.levels.WARN)
  end
end

-- Try to build regex engine if not already present
local lib = vim.fn.stdpath("data") .. "/site/pack/core/opt/LuaSnip/lib"
if vim.fn.empty(vim.fn.glob(lib .. "/*jsregexp*")) > 0 then
  vim.schedule(build_jsregexp)
end

require("blink.cmp").setup({
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
    default = {
      -- "copilot",
      "lsp",
      "path",
      "snippets",
      "buffer",
    },
    providers = {
      copilot = {
        name         = "copilot",
        module       = "blink-copilot", -- if using giuxtaposition plugin, use "blink-cmp-copilot"
        async        = true,
        score_offset = 100,             -- float Copilot higher than LSP if you want
      },
    },                                  -- you can add "calc", etc., if installed
  },

  appearance = {
    use_nvim_cmp_as_default = false,
    nerd_font_variant = 'mono'
  },

  -- completion behavior
  completion = {
    menu = {
      draw = {
        treesitter = { "lsp" }
      }
    },
    accept = {
      auto_brackets = {
        enabled = true,
      },
    },
    trigger = {
      show_on_insert = true,
      show_on_trigger_character = true,
    },
    list = {
      selection = { preselect = false },
    },
    ghost_text = {
      enabled = vim.g.ai_cmp,
    },
    -- docs window on the side
    documentation = {
      auto_show = true,
    },
  },
  cmdline = {
    enabled = true,
    keymap = {
      preset = "cmdline",
      ["<Right>"] = false,
      ["<Left>"] = false,
    },
    completion = {
      list = { selection = { preselect = false } },
      menu = {
        auto_show = function(ctx)
          return vim.fn.getcmdtype() == ":"
        end,
      },
      ghost_text = { enabled = true },
    },
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


})



-- Cmdline Enter behavior: if completion item is a directory, insert slash and keep completing;
-- if it's a file (or no menu), execute command as normal.
vim.keymap.set('c', '<CR>', function()
  local ok_ci, ci = pcall(vim.fn.complete_info, { 'selected', 'items' })
  if ok_ci and ci and ci.selected and ci.selected ~= -1 and ci.items then
    local entry = ci.items[ci.selected + 1]
    if entry then
      local word = entry.word or entry.abbr
      if word and vim.fn.isdirectory(word) == 1 then
        -- ensure trailing slash and keep cmdline open
        if not word:match('/$') then
          vim.api.nvim_feedkeys('/', 'n', false)
        end
        return -- do not send <CR>
      end
    end
  end
  -- fallback: execute like normal
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
end, { noremap = true, silent = true, desc = 'Cmdline: <CR> open file or descend into dir' })
