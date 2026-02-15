vim.pack.add({
  { src = "https://github.com/saghen/blink.download" },
  { src = "https://github.com/saghen/blink.pairs",   version = vim.version.range("*") },
}, { confirm = false })

-- require('vim._extui').enable({})

require("blink.pairs").setup({
  highlights = {
    enabled = true,
  }
})
