-- SPDX-License-Identifier: MIT
-- fzf-lua: fuzzy finder (shared dependency of many features; loaded on next tick).

require('utils.lazy').add({
  src = 'https://github.com/ibhagwan/fzf-lua',
  deps = {
    'https://github.com/otavioschwanck/fzf-lua-enchanted-files',
  },
  config = function()
    local default_ignores = {
      '**/.pytest_cache/**',
      '**/__pycache__/**',
      '**/.mypy_cache/**',
      '**/.venv/**',
      '**/venv/**',
      '**/.git/**',
      '**/.idea/**',
      '**/build/**',
      '**/dist/**',
      '**/*.egg-info/**',
    }

    require('fzf-lua').setup({
      fzf_opts = { ['--layout'] = 'default' },
      -- Computed each time it opens, because it depends on the size of
      -- the window. Stop one line short of the bottom so the statusline
      -- stays visible: at row 1.00 the picker sits flush against the
      -- bottom and covers it.
      winopts = function()
        local height = math.floor(vim.o.lines * 0.40)
        return {
          height = height,
          width = 1.00,
          row = vim.o.lines - vim.o.cmdheight - height - 1,
          col = 0.50,
        }
      end,
      keymap = { fzf = { ['ctrl-c'] = 'abort' } },
      actions = {
        files = {
          true,
          ['enter'] = FzfLua.actions.file_edit_or_qf,
          ['ctrl-s'] = FzfLua.actions.file_split,
          ['ctrl-v'] = FzfLua.actions.file_vsplit,
          ['ctrl-t'] = FzfLua.actions.file_tabedit,
          ['ctrl-q'] = FzfLua.actions.file_sel_to_qf,
          ['alt-Q'] = FzfLua.actions.file_sel_to_ll,
          ['alt-i'] = FzfLua.actions.toggle_ignore,
          ['alt-h'] = FzfLua.actions.toggle_hidden,
          ['alt-f'] = FzfLua.actions.toggle_follow,
        },
      },
      grep = {
        rg_glob = true,
        glob_flag = '--iglob',
        glob_separator = '%s%-%-',
        additional_args = function()
          local args = {}
          for _, g in ipairs(default_ignores) do
            table.insert(args, '--iglob')
            table.insert(args, '!' .. g)
          end
          return args
        end,
      },
    })

    require('fzf-lua').register_ui_select()

    require('fzf-lua-enchanted-files').setup({
      max_history_per_cwd = 50,
      auto_history = true,
    })
  end,
})
