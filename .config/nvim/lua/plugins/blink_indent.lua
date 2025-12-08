vim.pack.add({ 'https://github.com/saghen/blink.indent' }, { confirm = false })


require('blink.indent').setup({
  static = {
    enabled = false,
  },
  scope = {
    enabled = false,
    char = '│ ',
    highlights = { 'BlinkIndent' },
  },
})
