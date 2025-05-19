-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

-- plugins/mason.lua
return {
  "williamboman/mason.nvim",
  event = { "VeryLazy" },
  cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonUpdate", "MasonLog", },
  build = ":MasonUpdate",
  opts = {
    ensure_installed = {
      "lua_ls",
      "clangd",
      "jsonls",
      -- "basedpyright",
      "bashls",
      "marksman",
      "markdown-toc",
      "efm",
      "yamlfmt",
      "yamllint",
      "ruff",
      "prettier",
      "taplo"
    },
    automatic_installation = true,
  },
  config = function(_, opts)
    require("mason").setup(opts)

    local registry = require("mason-registry")

    -- 1. Discover all servers defined in lua/lsp/*.lua
    local config_path = vim.fn.stdpath("config") .. "/lua/lsp/"
    local files = vim.fn.readdir(config_path)
    local function server_name(file)
      return file:match("^(.*)%.lua$")
    end

    -- 2. Map LSP config name to Mason package names
    local lsp_to_mason = {
      lua_ls = "lua-language-server",
      clangd = "clangd",
      jsonls = "json-lsp",
      ruff = "ruff",
      basedpyright = "basedpyright",
      bashls = "bash-language-server",
      marksman = "marksman",
      efm = "efm",
    }

    -- 3. Ensure each server is installed
    for _, file in ipairs(files) do
      local lsp_name = server_name(file)
      local mason_name = lsp_to_mason[lsp_name]
      if mason_name and not registry.is_installed(mason_name) then
        local ok, pkg = pcall(registry.get_package, mason_name)
        if ok and not pkg:is_installed() then
          pkg:install()
        end
      end
    end
  end,
  init = function()
    vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH
  end,
}
