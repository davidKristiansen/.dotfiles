return {
  {
    'echasnovski/mini.nvim',
    lazy = false,
    version = '*',
    config = function()
      require('mini.align').setup()
    end
  }
}
