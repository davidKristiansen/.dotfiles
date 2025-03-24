return {
  {
    'echasnovski/mini.surround',
    version = false,
    opts = {},
    event = "VeryLazy",
    init = function()
      require("which-key").add({
        { "s", group = "Surround" },
      })
    end,
  },
}
