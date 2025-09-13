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

-- isort used for Python import sorting via stdin
local isort = {
  formatCommand = "isort --stdout --filename ${INPUT} -",
  formatStdin = true,
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
    return vim.fs.root(fname, { ".yamllint", ".prettierrc", "pyproject.toml", ".git" })
        or vim.fn.getcwd()
  end,
  settings = {
    rootMarkers = { ".yamllint", ".prettierrc", "pyproject.toml" },
    languages = {
      yaml = { yamllint, prettier_for("yaml") },
      json = { prettier_for("json") },
      markdown = { prettier_for("markdown") },
      html = { prettier_for("html") },
      python = { isort },
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
