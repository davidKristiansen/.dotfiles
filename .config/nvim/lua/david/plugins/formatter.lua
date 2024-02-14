return {
  {
    'stevearc/conform.nvim',
    init = function()
      vim.cmd([[
      autocmd FileType json syntax match Comment +\/\/.\+$+
      ]])
    end,
    ft = { "python", "json" },
    -- init = function ()
    --   vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    -- end,
    opts = {
      formatters_by_ft = {
        python = { "isort", "autopep8" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        -- json = { "fixjson" },
        ["*"] = { "codespell" },
      },
    },
  }
}
