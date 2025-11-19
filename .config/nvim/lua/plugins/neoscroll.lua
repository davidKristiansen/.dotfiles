vim.pack.add({
  { src = "https://github.com/karb94/neoscroll.nvim" }
}, { confirm = false })

vim.keymap.set('n', '<ScrollWheelUp>', '<C-y>')
vim.keymap.set('n', '<ScrollWheelDown>', '<C-e>')
vim.keymap.set('i', '<ScrollWheelUp>', '<C-y>')
vim.keymap.set('i', '<ScrollWheelDown>', '<C-e>')
vim.keymap.set('v', '<ScrollWheelUp>', '<C-y>')
vim.keymap.set('v', '<ScrollWheelDown>', '<C-e>')

require 'neoscroll'.setup {
  mappings = { '<C-y>', '<C-e>' },
}
