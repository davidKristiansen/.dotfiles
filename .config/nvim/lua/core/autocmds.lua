-- SPDX-License-Identifier: MIT

-- Trim trailing whitespace
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Auto-create directories on save + stable backupext
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("auto_create_dir", { clear = true }),
  callback = function(ev)
    local file = vim.loop.fs_realpath(ev.match) or ev.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    local backup = vim.fn.fnamemodify(file, ":p:~:h"):gsub("[/\\]", "%%")
    vim.go.backupext = backup
  end,
})

-- Restore last position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local ok, mark = pcall(vim.api.nvim_buf_get_mark, 0, '"')
    if ok and mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Hybrid numbers
local function is_special()
  local bt = vim.api.nvim_get_option_value("buftype", {})
  return bt == "nofile" or bt == "terminal"
end

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter", "TermOpen" }, {
  group = vim.api.nvim_create_augroup("hybrid_numbers_on", { clear = true }),
  callback = function()
    if is_special() then
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
    else
      vim.opt_local.number = true
      vim.opt_local.relativenumber = vim.api.nvim_get_mode().mode ~= "i"
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave", "TermClose" }, {
  group = vim.api.nvim_create_augroup("hybrid_numbers_off", { clear = true }),
  callback = function()
    if not is_special() then
      vim.opt_local.number = true
      vim.opt_local.relativenumber = false
    end
  end,
})

-- Yank flash
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200, on_visual = true })
  end,
})

-- Auto-open Oil when launching Neovim with no file arguments (plain `nvim`)
-- Does not work!
-- vim.api.nvim_create_autocmd("VimEnter", {
--   group = vim.api.nvim_create_augroup("auto_open_oil", { clear = true }),
--   callback = function()
--     -- Only trigger when no files were passed on the command line
--     if vim.fn.argc() == 0 then
--       local ok, oil = pcall(require, 'oil')
--       if ok then
--         -- Replace the empty unnamed buffer with Oil view of current working directory
--         oil.open()
--       end
--     end
--   end,
-- })
--

