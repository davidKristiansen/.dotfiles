-- SPDX-License-Identifier: MIT
-- neo-tree.nvim: file explorer + lsp-file-operations.
--
-- Split load:
--   * lsp-file-operations advertises file-op capabilities to all LSP servers,
--     which must happen before servers attach — kept on the early (next-tick)
--     tier exactly as before.
--   * the neo-tree UI (and the event-hooking half of lsp-file-operations) loads
--     on demand via <leader>e / <leader>E. File operations only originate from
--     the neo-tree UI, so hooking them at first open loses nothing.

-- Early: advertise lsp-file-operations capabilities to all servers.
require('utils.lazy').add({
  src = 'https://github.com/antosha417/nvim-lsp-file-operations',
  deps = {
    'https://github.com/nvim-lua/plenary.nvim',
  },
  config = function()
    local ok, lsp_file_ops = pcall(require, 'lsp-file-operations')
    if ok then
      vim.lsp.config('*', {
        capabilities = lsp_file_ops.default_capabilities(),
      })
    end
  end,
})

-- Only reveal when the current buffer is a real file on disk; otherwise
-- (starter, terminal, [No Name], help, quickfix, …) reveal has no valid target,
-- so fall back to a plain open/toggle.
local function on_real_file()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  return vim.bo[buf].buftype == '' and name ~= '' and vim.fn.filereadable(name) == 1
end

-- On demand: the neo-tree UI.
require('utils.lazy').add({
  src = 'https://github.com/nvim-neo-tree/neo-tree.nvim',
  deps = {
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/MunifTanjim/nui.nvim',
    'https://github.com/antosha417/nvim-lsp-file-operations',
  },
  config = function()
    require('neo-tree').setup({
      use_popups_for_input = false,
      enable_git_status = true,
      window = { mappings = { ['<C-v>'] = 'open_vsplit' } },
      filesystem = {
        use_libuv_file_watcher = true,
        follow_current_file = {
          enabled = false,
          leave_dirs_open = false,
        },
      },
    })

    -- Hook file operations now that neo-tree is loaded.
    pcall(function()
      require('lsp-file-operations').setup()
    end)
  end,
  keys = {
    -- Toggle the explorer; on open, reveal (jump to) the current file.
    {
      '<leader>e',
      function()
        vim.cmd(on_real_file() and 'Neotree toggle reveal' or 'Neotree toggle')
      end,
      desc = 'Explorer (reveal current file)',
    },
    -- Reveal current file without toggling closed (focus tree if already open).
    {
      '<leader>E',
      function()
        vim.cmd(on_real_file() and 'Neotree reveal' or 'Neotree focus')
      end,
      desc = 'Explorer: reveal current file',
    },
  },
})
