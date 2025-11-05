-- SPDX-License-Identifier: MIT

-- --------------------------------------------------------------------
-- Winbar
-- --------------------------------------------------------------------
vim.api.nvim_set_hl(0, "WinbarPath", { fg = "#928374" })

local function get_winbar_str(winid)
  local current_buf = vim.api.nvim_win_get_buf(winid)
  local current_filename = vim.api.nvim_buf_get_name(current_buf)

  if current_filename == "" or vim.bo[current_buf].buftype ~= '' then
    return ""
  end

  local filename = vim.fn.fnamemodify(current_filename, ":t")

  local ok, devicons = pcall(require, "nvim-web-devicons")
  local file_icon
  if ok then
    file_icon, _ = devicons.get_icon(filename)
  end

  local final_string = " " .. (file_icon or "") .. " " .. filename

  local bufs = vim.api.nvim_list_bufs()
  local duplicates = {}
  for _, buf in ipairs(bufs) do
    if buf ~= current_buf and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == '' then
      local other_filename = vim.api.nvim_buf_get_name(buf)
      if filename == vim.fn.fnamemodify(other_filename, ":t") then
        table.insert(duplicates, other_filename)
      end
    end
  end

  if #duplicates > 0 then
    -- Find minimal unique path
    local current_parts = vim.split(vim.fn.fnamemodify(current_filename, ":h"), "/", { plain = true })
    local depth = 1
    local unique = false

    while not unique and depth <= #current_parts do
      local current_path = table.concat(vim.list_slice(current_parts, #current_parts - depth + 1), "/")
      unique = true

      for _, dup_file in ipairs(duplicates) do
        local dup_parts = vim.split(vim.fn.fnamemodify(dup_file, ":h"), "/", { plain = true })
        local dup_path = table.concat(vim.list_slice(dup_parts, #dup_parts - depth + 1), "/")

        if current_path == dup_path then
          unique = false
          break
        end
      end

      if not unique then
        depth = depth + 1
      else
        final_string = final_string .. " %#WinbarPath#../" .. current_path .. "%*"
      end
    end
  end

  if vim.bo[current_buf].modified then
    final_string = final_string .. " ●"
  end

  return final_string .. " "
end

_G.get_winbar_str = get_winbar_str

-- Set winbar for each window
local function set_winbar()
  local buf = vim.api.nvim_get_current_buf()
  local buftype = vim.bo[buf].buftype
  local filetype = vim.bo[buf].filetype

  -- Only show winbar for normal files
  if buftype == '' and filetype ~= 'TelescopePrompt' then
    vim.wo.winbar = "%!v:lua.get_winbar_str(" .. vim.api.nvim_get_current_win() .. ")"
  else
    vim.wo.winbar = nil
  end
end

-- Set initial winbar
set_winbar()

-- Update winbar when entering a window or buffer
local group = vim.api.nvim_create_augroup("Winbar", { clear = true })
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
  group = group,
  callback = set_winbar,
})
