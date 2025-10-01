-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

local M = {}

function M.setup(buf)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
  end

  local picker = require("config.lsp.picker")

  local function map_jump(lhs, fn, desc)
    map("n", lhs, fn, desc)
    local gv = "gv" .. lhs:sub(2)
    map("n", gv, function()
      vim.cmd("vsplit"); fn()
    end, desc .. " (vsplit)")
  end

  map_jump("gd", picker.definitions, "Goto Definition")
  map_jump("gD", picker.declarations, "Goto Declaration")
  map_jump("gI", picker.implementations, "Goto Implementation")
  map_jump("gy", picker.type_definitions, "Goto Type Definition")
  map_jump("gr", picker.references, "References")

  map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
  map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous Diagnostic")
  map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next Diagnostic")
  map("n", "<leader>d", vim.diagnostic.open_float, "Show Diagnostic")
  map("n", "<leader>q", vim.diagnostic.setloclist, "Quickfix Diagnostics")

  -- formatting
  map("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format Buffer")
  map("n", "<leader>uf", function() vim.cmd("Format") end, "Format Mode: cycle")
  map("n", "<leader>uF", function()
    local modes = { "off", "save", "ontype" }
    vim.ui.select(modes, { prompt = "Format mode" }, function(choice)
      if choice then vim.cmd("Format " .. choice) end
    end)
  end, "Format Mode: pick")
end

return M
