-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
  name = "lua_ls",
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_dir = function(fname)
    local root = vim.fs.root(fname, { ".luarc.json", ".luarc.jsonc", ".git", "lazy-lock.json" })
    if not root then
      root = vim.fs.dirname(fname) -- fallback: current file's dir
    end
    return root
  end,



  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT", -- Match Neovim's runtime
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          -- Uncomment this if you want all runtime files included (slower):
          -- unpack(vim.api.nvim_get_runtime_file("", true)),
        },
      },
      diagnostics = {
        globals = { "vim" }, -- So it doesn't complain about the `vim` global
      },
    },
  },
}
