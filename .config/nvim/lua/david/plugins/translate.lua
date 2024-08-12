return {
  {
    "uga-rosa/translate.nvim",
    keys = {
      {
        "gtr",
        "<cmd>Translate -command=translate_shell -output=replace en<cr>",
        desc = "Replace",
        mode = { "n", "v" },
      },
      {
        "gtf",
        "<cmd>Translate -command=translate_shell -output=floating en<cr>",
        desc = "Float",
        mode = { "n", "v" },
      },
      {
        "gts",
        "<cmd>Translate -command=translate_shell -output=split en<cr>",
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
