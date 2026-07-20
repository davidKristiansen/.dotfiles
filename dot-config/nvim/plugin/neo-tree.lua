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
    'https://github.com/mrbjarksen/neo-tree-diagnostics.nvim',
  },
  cmd = 'Neotree',
  config = function()
    require('neo-tree').setup({
      sources = { 'filesystem', 'buffers', 'git_status', 'document_symbols', 'diagnostics' },
      use_popups_for_input = false,
      enable_git_status = true,

      -- Tabbed source selector at the top of the neo-tree panel.
      source_selector = {
        winbar = true,
        content_layout = 'center',
        sources = {
          { source = 'filesystem', display_name = '󰉓 Files' },
          { source = 'buffers', display_name = '󰈙 Bufs' },
          { source = 'git_status', display_name = '󰊢 Git' },
          { source = 'document_symbols', display_name = '󰅩 Symbols' },
          { source = 'diagnostics', display_name = '󰒡 Diag' },
        },
      },

      -- Shared window mappings (apply to all sources).
      window = {
        mappings = {
          ['<C-v>'] = 'open_vsplit',
          ['gd'] = 'diffview_file',
        },
      },

      -- Custom commands available in all sources.
      commands = {
        diffview_file = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          if path and vim.fn.filereadable(path) == 1 then
            vim.cmd('DiffviewFileHistory ' .. vim.fn.fnameescape(path))
          else
            vim.notify('No file under cursor', vim.log.levels.WARN)
          end
        end,
      },

      filesystem = {
        hijack_netrw_behavior = 'disabled',
        use_libuv_file_watcher = true,
        follow_current_file = {
          enabled = false,
          leave_dirs_open = false,
        },
      },

      -- Git actions inside the git_status source (mnemonics match <leader>g*).
      git_status = {
        window = {
          mappings = {
            ['gs'] = 'git_add_file', -- stage   (matches <leader>gs)
            ['gu'] = 'git_unstage_file', -- unstage (matches <leader>gu)
            ['gr'] = 'git_revert_file', -- revert  (matches <leader>gr)
            ['gA'] = 'git_add_all', -- stage all
          },
        },
      },
    })

    -- Source selector tab highlights: active blends with sidebar, inactive transparent.
    local function set_winbar_hl()
      local hl = vim.api.nvim_set_hl
      local nt = vim.api.nvim_get_hl(0, { name = 'NeoTreeNormal', link = false })
      local bg = nt.bg
      if not bg then
        local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
        bg = normal.bg
      end
      -- Active tab: sidebar bg so it connects to the tree below.
      hl(0, 'NeoTreeTabActive', { bg = bg, bold = true })
      hl(0, 'NeoTreeTabSeparatorActive', { bg = bg, fg = bg })
      -- Inactive tabs: transparent.
      hl(0, 'NeoTreeTabInactive', { bg = 'NONE' })
      hl(0, 'NeoTreeTabSeparatorInactive', { bg = 'NONE', fg = 'NONE' })
    end
    set_winbar_hl()
    vim.api.nvim_create_autocmd('ColorScheme', { callback = set_winbar_hl })

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
    -- Open document symbols source in explorer (built-in, experimental).
    { '<leader>es', '<cmd>Neotree toggle document_symbols<cr>', desc = 'Explorer: symbols' },
    -- Open diagnostics source in explorer.
    { '<leader>ed', '<cmd>Neotree toggle diagnostics<cr>', desc = 'Explorer: diagnostics' },
    -- Set the cwd to the directory of the current file.
    {
      '<leader>ew',
      '<cmd>Neotree dir=%:p:h<cr>',
      desc = 'Explorer: set cwd to file dir',
    },
  },
})
