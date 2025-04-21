-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    local palette = require("gruvbox").palette
    local lsp = vim.lsp
    local lualine = require("lualine")
    local theme = require("lualine.themes.gruvbox")

    -- Customize base theme
    for _, mode in pairs({ "normal", "insert", "visual", "replace", "command", "inactive" }) do
      if theme[mode] and theme[mode].c then
        theme[mode].c.bg = palette.dark0_hard
        theme[mode].c.fg = palette.light1
      end
    end
    theme.inactive.c.fg = palette.gray

    -- Highlight group for macro recording
    vim.api.nvim_set_hl(0, "LualineRecording", {
      fg = palette.neutral_red,
      bold = true,
    })

    ---@return string
    local function macro_recording()
      local reg = vim.fn.reg_recording()
      if reg == "" then return "" end
      return "%#LualineRecording#●%* " .. reg
    end

    ---@return string
    local function lsp_client_names()
      local clients = lsp.get_clients({ bufnr = 0 })
      if #clients == 0 then return "" end
      return " " .. table.concat(vim.tbl_map(function(c) return c.name end, clients), ", ")
    end

    ---@return string
    local function shorten_path()
      local path = vim.fn.expand("%:p")
      local home = vim.fn.expand("~")
      path = path:gsub("^" .. vim.pesc(home), "~")
      local segments = vim.split(path, "/", { plain = true })
      for i = 2, #segments - 1 do
        segments[i] = segments[i]:sub(1, 1):match("^%.") and segments[i]:sub(1, 2) or segments[i]:sub(1, 1)
      end
      return table.concat(segments, "/")
    end

    lualine.setup({
      options = {
        theme = theme,
        section_separators = "",
        component_separators = "",
        globalstatus = true,
        disabled_filetypes = { statusline = { "alpha" }, winbar = {} },
      },
      sections = {
        lualine_a = { "mode", macro_recording },
        lualine_b = { "branch" },
        lualine_c = {},
        lualine_x = { lsp_client_names, "diagnostics", "filetype" },
        lualine_y = { "encoding" },
        lualine_z = { "location" },
      },
      winbar = {
        lualine_c = { shorten_path },
      },
      inactive_winbar = {
        lualine_c = { shorten_path },
      },
    })


    -- -- Try to fix some double lualines
    -- local lualine_nvim_opts = require 'lualine.utils.nvim_opts'
    -- local base_set = lualine_nvim_opts.set
    --
    -- lualine_nvim_opts.set = function(name, val, scope)
    --   if vim.env.TMUX ~= nil and name == 'statusline' then
    --     if scope and scope.window == vim.api.nvim_get_current_win() then
    --       vim.g.tpipeline_statusline = val
    --       vim.cmd 'silent! call tpipeline#update()'
    --     end
    --     return
    --   end
    --   return base_set(name, val, scope)
    -- end
    --
    -- -- Let tpipeline control statusline drawing
    vim.opt.laststatus = 3
  end,
}
