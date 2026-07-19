-- SPDX-License-Identifier: MIT
-- neo-tree.nvim: file explorer + lsp-file-operations.
--
-- The file-operation *capabilities* are advertised statically by core.lsp
-- (no plugin needed at startup); only the event-hooking half of
-- lsp-file-operations loads here, with the neo-tree UI, on <leader>e* keys.
-- File operations only originate from the neo-tree UI, so hooking
-- them at first open loses nothing.

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
    'https://github.com/s1n7ax/nvim-window-picker',
  },
  cmd = 'Neotree',
  config = function()
    require('neo-tree').setup({
      use_popups_for_input = false,
      enable_git_status = true,
      window = { mappings = { ['<C-v>'] = 'open_vsplit' } },
      filesystem = {
        hijack_netrw_behavior = 'disabled',
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
    -- Toggle the explorer sidebar.
    { '<leader>ee', '<cmd>Neotree toggle<cr>', desc = 'Explorer: toggle' },
    -- Reveal the current file in the tree (focus tree if already open).
    {
      '<leader>ef',
      function()
        vim.cmd(on_real_file() and 'Neotree reveal' or 'Neotree focus')
      end,
      desc = 'Explorer: reveal file',
    },
    -- Open buffers source in explorer.
    { '<leader>eb', '<cmd>Neotree toggle buffers<cr>', desc = 'Explorer: buffers' },
    -- Open git status source in explorer.
    { '<leader>eg', '<cmd>Neotree toggle git_status<cr>', desc = 'Explorer: git status' },
    -- Open document symbols source in explorer.
    { '<leader>es', '<cmd>Neotree toggle document_symbols<cr>', desc = 'Explorer: symbols' },
    -- Set the cwd to the directory of the current file.
    {
      '<leader>ew',
      '<cmd>Neotree dir=%:p:h<cr>',
      desc = 'Explorer: set cwd to file dir',
    },
  },
})
