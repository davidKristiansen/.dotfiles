-- SPDX-License-Identifier: MIT
vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-refactor" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },
}, { confirm = false })


require("nvim-treesitter.configs").setup({
  highlight = { enable = true },
  auto_install = true,
  additional_vim_regex_highlighting = false,
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
        ["ib"] = "@block.inner",
        ["ab"] = "@block.outer",
        ["as"] = "@statement.outer",
        ["ad"] = "@conditional.outer",
        ["id"] = "@conditional.inner",
        ["a/"] = "@comment.outer",
      },
    },
    move = {
      enable = true,
      goto_next_start = {
        ["]c"] = "@class.outer",
        ["]f"] = "@function.outer",
      },
      goto_next_end = {
        ["]C"] = "@class.outer",
        ["]F"] = "@function.outer",
      },
      goto_previous_start = {
        ["[c"] = "@class.outer",
        ["[f"] = "@function.outer",
      },
      goto_previous_end = {
        ["[C"] = "@class.outer",
        ["[F"] = "@function.outer",
      },
    },
  },
  refactor = {
    highlight_definitions = {
      enable = true,
      clear_on_cursor_move = true,
    },
    navigation = {
      enable = true,
      keymaps = {
        goto_next_usage = "]r",
        goto_previous_usage = "[r",
      },
    },
  },
})

-- Add asciidoc parser
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.asciidoc = {
  install_info = {
    url = "https://github.com/cathaysia/tree-sitter-asciidoc",
    files = { "tree-sitter-asciidoc/src/parser.c", "tree-sitter-asciidoc/src/scanner.c" },
    branch = "master",
    generate_requires_npm = false,
    requires_generate_from_grammar = false,
  },
  filetype = "adoc",
}

-- Non-blocking first-run parser update (runs once)
local once = require("utils.once")
once.run("ts_update", function()
  vim.schedule(function()
    pcall(vim.cmd, "silent! TSUpdate")
  end)
end)

-- Consolidated FileType autocmd for treesitter features
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype
    local lang = vim.treesitter.language.get_lang(ft)

    if not lang or not vim.treesitter.language.add(lang) then
      return
    end

    vim.treesitter.start()

    -- Set folding if available
    if vim.treesitter.query.get(lang, "folds") then
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end

    -- Set indentation if available (overrides traditional indent)
    if vim.treesitter.query.get(lang, "indents") then
      vim.bo.indentexpr = "nvim_treesitter#indent()"
    end
  end,
})
