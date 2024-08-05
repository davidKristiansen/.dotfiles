-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  command = [[silent! lua vim.highlight.on_yank() {higroup="IncSearch", timeout=400}]],
})

-- Hybrid line numbers
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter", "TermOpen" }, {
  pattern = "*",
  callback = function()
    local buftype = vim.api.nvim_get_option_value("buftype", {})
    local mode = vim.api.nvim_get_mode()

    if buftype == "nofile" or buftype == "terminal" then
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
    else
      vim.opt_local.number = true
      vim.opt_local.relativenumber = (mode ~= "i")
    end
  end,
})
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave", "TermClose" }, {
  pattern = "*",
  callback = function()
    local buftype = vim.api.nvim_get_option_value("buftype", {})

    if buftype ~= "nofile" and buftype ~= "terminal" then
      vim.opt_local.number = true
      vim.opt_local.relativenumber = false
    end
  end,
})

-- Clean trailing whitespaces on write
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

-- create directories when needed, when saving a file
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    local file = vim.loop.fs_realpath(event.match) or event.match

    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    local backup = vim.fn.fnamemodify(file, ":p:~:h")
    backup = backup:gsub("[/\\]", "%%")
    vim.go.backupext = backup
  end,
})

-- Restore last position
vim.api.nvim_create_autocmd("BufRead", {
  command = [[call setpos(".", getpos("'\""))]],
})
