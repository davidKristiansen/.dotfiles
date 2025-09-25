-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  name = "taplo",
  cmd = { "taplo", "lsp", "stdio" },
  filetypes = { "toml" },
  root_dir = function(fname)
    return vim.fs.root(fname, { "pyproject.toml", "Cargo.toml", ".git" }) or vim.fn.getcwd()
  end,
}
