-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    local palette = require("gruvbox").palette
    local lsp = vim.lsp

    -- Highlight group for macro recording
    vim.api.nvim_set_hl(0, "LualineRecording", {
      fg = palette.neutral_red,
      bold = true,
    })

    local function macro_recording()
      local reg = vim.fn.reg_recording()
      if reg == "" then return "" end
      return "%#LualineRecording#" .. "⏺" .. "%*"
    end

    local function lsp_client_names()
      local clients = lsp.get_clients({ bufnr = 0 })
      if #clients == 0 then return "" end
      return " " .. table.concat(vim.tbl_map(function(c) return c.name end, clients), ", ")
    end

    local function shorten_path()
      local path = vim.fn.expand("%:p")
      local home = vim.fn.expand("~")
      if path:find(home, 1, true) == 1 then
        path = "~" .. path:sub(#home + 1)
      end

      local segments = vim.split(path, "/")
      for i = 2, #segments - 1 do
        local seg = segments[i]
        if seg:sub(1, 1) == "." then
          segments[i] = seg:sub(1, 2)
        else
          segments[i] = seg:sub(1, 1)
        end
      end

      return table.concat(segments, "/")
    end

    local gruvbox = require("lualine.themes.gruvbox")
    for _, mode in ipairs({ "normal", "insert", "visual", "replace", "command", "inactive" }) do
      if gruvbox[mode] and gruvbox[mode].c then
        gruvbox[mode].c.bg = palette.dark0_hard
        gruvbox[mode].c.fg = palette.light1
      end
    end
    gruvbox.inactive.c.fg = palette.gray

    local lualine_opts = {
      options = {
        theme = gruvbox,
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
    }

    require("lualine").setup(lualine_opts)
  end,
}
