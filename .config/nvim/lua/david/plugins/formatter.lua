return {
  {
    'stevearc/conform.nvim',
    ft = {"python"},
    init = function ()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
    opts = {
      formatters_by_ft = {
        python = { "isort", "autopep8"},
        c = { "clang-format"},
        cpp = { "clang-format"},
      ["*"] = { "codespell" },
      },
    },
  }
}
