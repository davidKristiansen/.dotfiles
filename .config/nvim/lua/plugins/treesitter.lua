-- SPDX-License-Identifier: MIT
vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-refactor" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },
}, { confirm = false })

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

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "c",
    "cpp",
    "lua",
    "vim",
    "vimdoc",
    "query",
    "json",
    "yaml",
    "python",
    "bash",
    "toml",
    "markdown",
    "markdown_inline",
    "asciidoc", -- Added asciidoc to ensure_installed
  },
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
  indent = { enable = true },
})