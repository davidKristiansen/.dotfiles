-- SPDX-License-Identifier: MIT
-- Git integration. Split load:
--   * gitsigns + fugitive load early (vim.schedule) so signs appear on open.
--   * diffview loads on demand (<leader>g* keymaps / :Diffview* commands).
--   * neogit / lazygit load on demand (<leader>g* keymaps / :Neogit).

-- ── Gitsigns + Fugitive (early) ─────────────────────────────────────────
require('utils.lazy').add({
  src = 'https://github.com/lewis6991/gitsigns.nvim',
  deps = {
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/tpope/vim-fugitive',
    'https://github.com/ibhagwan/fzf-lua',
  },
  config = function()
    require('gitsigns').setup({
      signs = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '▁' },
        topdelete = { text = '▔' },
        changedelete = { text = '▎' },
        untracked = { text = '▎' },
      },
      on_attach = function(_bufnr) end,
    })

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true, desc = desc })
    end

    -- Gitsigns-only keymaps
    map('n', '<leader>gh', function()
      require('gitsigns').preview_hunk()
    end, 'Preview hunk')
    map('n', '<leader>gr', function()
      require('gitsigns').reset_hunk()
    end, 'Reset hunk')
    map('n', '<leader>gR', function()
      require('gitsigns').reset_buffer()
    end, 'Reset buffer')
    map('n', '<leader>gs', function()
      require('gitsigns').stage_hunk()
    end, 'Stage hunk')
    map('n', '<leader>gS', function()
      require('gitsigns').stage_buffer()
    end, 'Stage buffer')
    map('n', '<leader>gu', function()
      require('gitsigns').undo_stage_hunk()
    end, 'Undo stage hunk')

    -- fzf-lua git keymaps
    map('n', '<leader>gt', function()
      require('fzf-lua').git_status()
    end, 'Git status')
    map('n', '<leader>gb', function()
      require('fzf-lua').git_branches()
    end, 'Git checkout branch')

    -- Hunk navigation
    map('n', ']h', function()
      if vim.wo.diff then
        vim.cmd.normal({ ']c', bang = true })
      else
        require('gitsigns').nav_hunk('next')
      end
    end, 'Next hunk')

    map('n', '[h', function()
      if vim.wo.diff then
        vim.cmd.normal({ '[c', bang = true })
      else
        require('gitsigns').nav_hunk('prev')
      end
    end, 'Prev hunk')
  end,
})

-- ── Heavy git plugins (keymap-triggered) ────────────────────────────────
local function pick_ref(opts)
  opts = opts or {}

  local refs = vim.fn.systemlist(
    "git for-each-ref --format='%(refname:short)' refs/heads refs/remotes refs/tags 2>/dev/null"
  )

  if vim.v.shell_error ~= 0 or #refs == 0 then
    vim.notify('No git refs found', vim.log.levels.WARN)
    return
  end

  require('utils.picker').pick(refs, {
    prompt = opts.prompt or 'Git refs> ',
    on_choice = opts.on_choice,
  })
end

local function create_branch()
  vim.ui.input({ prompt = 'New branch name: ' }, function(name)
    if not name or name == '' then
      vim.notify('Branch creation cancelled', vim.log.levels.INFO)
      return
    end

    local out = vim.fn.system('git checkout -b ' .. vim.fn.shellescape(name))

    if vim.v.shell_error == 0 then
      vim.notify("Switched to new branch '" .. name .. "'", vim.log.levels.INFO)
      vim.cmd('redraw!')
    else
      vim.notify(out, vim.log.levels.ERROR, { title = 'git checkout -b failed' })
    end
  end)
end

local function open_pr_view()
  pick_ref({
    prompt = 'PR View (vs Base)> ',
    on_choice = function(base)
      if base then
        vim.cmd('DiffviewOpen ' .. vim.fn.fnameescape(base) .. '...')
      end
    end,
  })
end

local function open_pr_history()
  pick_ref({
    prompt = 'PR History (since Base)> ',
    on_choice = function(base)
      if base then
        vim.cmd('DiffviewFileHistory ' .. vim.fn.fnameescape(base) .. '..HEAD')
      end
    end,
  })
end

local function open_diff_vs_ref()
  pick_ref({
    prompt = 'Diff vs Ref (Merge-Base)> ',
    on_choice = function(choice)
      if choice then
        vim.cmd('DiffviewOpen ' .. vim.fn.fnameescape(choice) .. '...')
      end
    end,
  })
end

local function push_upstream()
  local branch = vim.fn.system('git rev-parse --abbrev-ref HEAD'):gsub('%s+', '')
  local remote = vim.fn.system('git rev-parse --abbrev-ref @{upstream}'):gsub('%s+', '')

  if vim.v.shell_error ~= 0 then
    -- No upstream set, push with -u
    vim.fn.jobstart({ 'git', 'push', '-u', 'origin', branch }, {
      on_exit = function(_, code)
        vim.schedule(function()
          if code == 0 then
            vim.notify('Pushed ' .. branch .. ' (set upstream)', vim.log.levels.INFO)
          else
            vim.notify('Push failed (exit ' .. code .. ')', vim.log.levels.ERROR)
          end
        end)
      end,
    })
  else
    vim.fn.jobstart({ 'git', 'push' }, {
      on_exit = function(_, code)
        vim.schedule(function()
          if code == 0 then
            vim.notify('Pushed to ' .. remote, vim.log.levels.INFO)
          else
            vim.notify('Push failed (exit ' .. code .. ')', vim.log.levels.ERROR)
          end
        end)
      end,
    })
  end
end

-- ── Diffview ────────────────────────────────────────────────────────────
local diffview = require('utils.lazy').add({
  src = 'https://github.com/dlyongemallo/diffview.nvim',
  cmd = {
    'DiffviewOpen',
    'DiffviewToggle',
    'DiffviewClose',
    'DiffviewFileHistory',
    'DiffviewFocusFiles',
    'DiffviewToggleFiles',
    'DiffviewRefresh',
    'DiffviewLog',
  },
  config = function()
    local actions = require('diffview.actions')

    require('diffview').setup({
      enhanced_diff_hl = true,
      view = {
        default = { winbar_info = true },
        file_history = { winbar_info = true },
        -- ours | theirs on top, merged result below; resolve with the
        -- default <leader>co/<leader>ct/<leader>cb/<leader>ca, dx; [x/]x jump
        merge_tool = { layout = 'diff3_mixed', disable_diagnostics = true },
      },
      file_panel = {
        listing_style = 'tree',
        win_config = { position = 'left', width = 32 },
      },
      -- Defaults stay on (stage: -/S/U, panel focus/toggle: <leader>e/<leader>b,
      -- cycle layout: g<C-x>, help: g?); entries below are additions.
      keymaps = {
        view = {
          { 'n', 'q', '<cmd>DiffviewClose<CR>', { desc = 'Close Diffview' } },
          { 'n', '[f', actions.select_prev_entry, { desc = 'Prev file' } },
          { 'n', ']f', actions.select_next_entry, { desc = 'Next file' } },
        },
        file_panel = {
          { 'n', 'q', '<cmd>DiffviewClose<CR>', { desc = 'Close Diffview' } },
          { 'n', '[f', actions.select_prev_entry, { desc = 'Prev file' } },
          { 'n', ']f', actions.select_next_entry, { desc = 'Next file' } },
          { 'n', 'cc', '<cmd>Neogit commit<CR>', { desc = 'Commit staged' } },
        },
        file_history_panel = {
          { 'n', 'q', '<cmd>DiffviewClose<CR>', { desc = 'Close Diffview' } },
          { 'n', '[f', actions.select_prev_entry, { desc = 'Prev file' } },
          { 'n', ']f', actions.select_next_entry, { desc = 'Next file' } },
        },
      },
    })
  end,
  keys = {
    { '<leader>gv', '<cmd>DiffviewToggle<CR>', desc = 'Toggle Diffview' },
    { '<leader>gV', open_pr_view, desc = 'PR View (Cumulative)' },
    { '<leader>gl', open_pr_history, desc = 'PR History (Commit-by-Commit)' },
    {
      '<leader>gf',
      '<cmd>DiffviewFileHistory %<CR>',
      desc = 'File History (Buffer)',
    },
    {
      '<leader>gf',
      ':DiffviewFileHistory<CR>',
      mode = 'v',
      desc = 'File History (Selection)',
    },
    {
      '<leader>gH',
      '<cmd>DiffviewFileHistory<CR>',
      desc = 'File History (Project)',
    },
    { '<leader>gD', open_diff_vs_ref, desc = 'Diff vs Ref (Merge-Base)' },
  },
})

-- ── Neogit + LazyGit ────────────────────────────────────────────────────
require('utils.lazy').add({
  src = 'https://github.com/NeogitOrg/neogit',
  deps = {
    'https://github.com/MunifTanjim/nui.nvim',
    'https://github.com/kdheepak/lazygit.nvim',
  },
  cmd = 'Neogit',
  config = function()
    -- Load diffview through its own spec so our setup() above is applied
    -- before neogit's diffview integration first uses it.
    diffview.load()

    require('neogit').setup({
      kind = 'tab',
      integrations = { diffview = true },
    })
  end,
  keys = {
    -- Branches
    { '<leader>gB', create_branch, desc = 'Create new branch' },
    -- Neogit
    {
      '<leader>gn',
      function()
        require('neogit').open({ kind = 'tab' })
      end,
      desc = 'Neogit status',
    },
    { '<leader>gp', push_upstream, desc = 'Push upstream' },
    {
      '<leader>gP',
      function()
        require('neogit').open({ 'push' })
      end,
      desc = 'Push menu',
    },
    {
      '<leader>gU',
      function()
        require('neogit').open({ 'pull' })
      end,
      desc = 'Pull',
    },
    {
      '<leader>gm',
      function()
        require('neogit').open({ 'merge' })
      end,
      desc = 'Merge',
    },
    -- LazyGit
    { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'Open LazyGit' },
  },
})
