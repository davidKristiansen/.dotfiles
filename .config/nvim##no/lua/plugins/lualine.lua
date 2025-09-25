-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
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
    local function winbar_component()
      local bufname = vim.api.nvim_buf_get_name(0)
      if bufname == "" then return "" end
      local ft = vim.bo.filetype

      -- Don’t show on non-file buffers
      local ignore_ft = {
        "alpha", "dashboard", "NvimTree", "Outline", "toggleterm", "TelescopePrompt"
      }
      if vim.tbl_contains(ignore_ft, ft) then return "" end

      -- Get devicon
      local devicons = require("nvim-web-devicons")
      local filename = vim.fn.expand("%:t")
      local icon, icon_hl = devicons.get_icon(filename, vim.fn.expand("%:e"), { default = true })

      -- Width-aware path shortener
      local function shorten_path_to_width(path, filename, extras_len)
        local win_width = vim.api.nvim_win_get_width(0)
        local home = vim.fn.expand("~")
        path = path:gsub("^" .. vim.pesc(home), "~")
        local segments = vim.split(path, "/", { plain = true })
        if #segments == 0 then return "" end
        -- Early out: if it fits, show all
        local full = table.concat(segments, "/")
        local preview = full .. "/" .. filename
        if #preview + extras_len < win_width - 8 then
          return full
        end
        -- Otherwise, collapse segments from the middle until it fits
        local left, right = 2, #segments - 1
        while left < right do
          local candidate = {}
          for i, seg in ipairs(segments) do
            if i == left and right > left then
              table.insert(candidate, "…")
              i = right -- skip to right segment
            elseif i < left or i > right then
              table.insert(candidate, seg)
            end
          end
          local result = table.concat(candidate, "/")
          if #result + 1 + #filename + extras_len < win_width - 8 then
            return result
          end
          right = right - 1
        end
        -- Only last segment if nothing else fits
        return segments[#segments]
      end
      local path = vim.fn.expand("%:p:h")
      -- Compute extras length: icon + modified + diagnostics (roughly)
      local modified = vim.bo.modified and " [+]" or ""
      local diag = ""    -- You could call diag_count() here, but it's typically small
      local icon_len = 2 -- fudge factor for the icon
      local extras_len = #modified + #diag + icon_len + 4
      local short_path = shorten_path_to_width(path, filename, extras_len)

      -- Diagnostics (optional, compact)
      local function diag_count()
        local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
        local warns = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        if errors > 0 then
          return string.format(" 󰅚 %d", errors)
        elseif warns > 0 then
          return string.format(" 󰀪 %d", warns)
        else
          return ""
        end
      end

      -- Build winbar string
      return string.format(
        " %%#%s#%s%%* %s/%s%s%s",
        icon_hl or "Normal",
        icon or "",
        short_path,
        filename,
        modified,
        diag_count()
      )
    end

    lualine.setup({
      options = {
        use_tpipeline = true,
        theme = theme,
        section_separators = "",
        component_separators = "",
        globalstatus = false,
        disabled_filetypes = { statusline = { "alpha" }, winbar = {} },
      },
      sections = {
        lualine_a = { "mode", macro_recording },
        lualine_b = { "branch", "diff" },
        lualine_c = {},
        lualine_x = { lsp_client_names, "diagnostics", "filetype", "encoding" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      winbar = {
        lualine_c = { winbar_component },
      },
      inactive_winbar = {
        lualine_c = { winbar_component },
      },
    })
    if vim.env.TMUX then
      vim.opt.laststatus = 0
    else
      vim.opt.laststatus = 3
    end
  end,
}
