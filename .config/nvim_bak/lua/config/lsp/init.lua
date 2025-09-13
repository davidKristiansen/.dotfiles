-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

local autocmds = require("config.lsp.autocmd")
local fmt      = require("config.lsp.format") -- << add
local fn       = vim.fn
local lsp      = vim.lsp

-- Default root markers + default capabilities for all servers
lsp.config("*", {
  root_markers = { ".git" },
  capabilities = fmt.capabilities(), -- << add
})

-- Track all configured servers (acts as a set)
local servers = {}

-- Load all LSP configs from lua/lsp/ and set up deferred eager start
local lsp_dir = fn.stdpath("config") .. "/lua/lsp"
for _, file in ipairs(fn.readdir(lsp_dir)) do
  local name = file:match("^(.*)%.lua$")
  if name then
    local ok, config = pcall(require, "lsp." .. name)
    if ok and type(config) == "table" then
      config.name = config.name or name

      if config.root_markers and not config.root_dir then
        local markers = config.root_markers
        config.root_dir = function(fname)
          return vim.fs.root(fname, markers)
              or vim.fs.root(fname, { ".git" })
              or vim.fn.getcwd()
        end
      end

      -- ensure per-server caps inherit the default if they didn't set it
      if not config.capabilities then
        config.capabilities = fmt.capabilities()
      end

      vim.lsp.config(config.name, config)
      servers[config.name] = true

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("lsp.eager_start", { clear = false }),
        pattern = config.filetypes,
        callback = function(args)
          local buf = args.buf
          local fname = vim.api.nvim_buf_get_name(buf)
          for _, client in pairs(vim.lsp.get_clients({ bufnr = buf })) do
            if client.name == config.name and client.config.root_dir == config.root_dir then
              return
            end
          end
          local root_dir = config.root_dir and config.root_dir(fname)
          if root_dir then
            local client_config = vim.tbl_deep_extend("force", config, { root_dir = root_dir })
            vim.lsp.start(client_config)
          end
        end,
      })
    else
      vim.notify("[lsp/init] Invalid config for '" .. name .. "'", vim.log.levels.WARN)
    end
  end
end

autocmds.setup(vim.tbl_keys(servers))
