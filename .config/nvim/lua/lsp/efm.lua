-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

local function prettier_for(parser)
  return {
    formatCommand = string.format("prettier --stdin-filepath $(realpath %%filepath) --parser %s", parser),
    formatStdin = true,
  }
end

local yamllint = {
  lintCommand = "yamllint -f parsable -",
  lintStdin = true,
  lintFormats = { "%f:%l:%c: [%t%*[^]]%*] %m" },
}

local ruff_format = {
  formatCommand = "ruff check --fix --stdin-filename %filepath -",
  formatStdin = true,
}

local ruff_lint = {
  lintCommand = "ruff check --stdin-filename %filepath -",
  lintStdin = true,
  lintFormats = { "%f:%l:%c: %m" },
}

return {
  name = "efm",
  cmd = { "efm-langserver" },
  filetypes = {
    "yaml",
    "json",
    "markdown",
    "html",
    "python",
  },
  root_dir = function(fname)
    return vim.fs.root(fname, { ".yamllint", ".prettierrc", ".git" }) or vim.fn.getcwd()
  end,
  settings = {
    rootMarkers = { ".yamllint", ".prettierrc" },
    languages = {
      yaml = { yamllint, prettier_for("yaml") },
      json = { prettier_for("json") },
      markdown = { prettier_for("markdown") },
      html = { prettier_for("html") },
      python = { ruff_format, ruff_lint },
    },
  },
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = false,
  },
  capabilities = {
    offsetEncoding = { "utf-8" },
  },
}
