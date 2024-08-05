return {
  {
    "uga-rosa/translate.nvim",
    keys = {
      {
        "gtr",
        "<cmd>Translate EN -source=JA -command=translate_shell -output=replace<cr>",
        desc = "Replace",
        mode = { "n", "v" },
      },
      {
        "gtf",
        "<cmd>Translate EN -source=JA -command=translate_shell -output=float<cr>",
        desc = "Float",
        mode = { "n", "v" },
      },
      {
        "gts",
        "<cmd>Translate EN -source=JA -command=translate_shell -output=split<cr>",
        desc = "Split",
        mode = { "n", "v" },
      },
    },
    cmd = { "Translate" },
    init = function()
      local wk = require('which-key')
      wk.add({
        { "gt", group = "translate" },
      })
    end,
    opts = {
      default = {
        command = "translate-shell",
        parse = "remove_newline",
        output = "split",
      },
    },
  },
}
