-- SPDX-License-Identifier: MIT
-- Git integration: gitsigns (vim.schedule), heavy plugins (keymap-triggered).
-- Split loading: gitsigns + fugitive load early, neogit/diffview/etc load on demand.

-- ── Gitsigns + Fugitive (vim.schedule) ─────────────────────────────────
vim.schedule(function()
    vim.pack.add({
        { src = 'https://github.com/nvim-lua/plenary.nvim' },
        { src = 'https://github.com/tpope/vim-fugitive' },
        { src = 'https://github.com/lewis6991/gitsigns.nvim' },
        { src = 'https://github.com/ibhagwan/fzf-lua' },
    }, { confirm = false })

    require('gitsigns').setup({
        signs = {
            add          = { text = '▎' },
            change       = { text = '▎' },
            delete       = { text = '▁' },
            topdelete    = { text = '▔' },
            changedelete = { text = '▎' },
            untracked    = { text = '▎' },
        },
        on_attach = function(bufnr) end,
    })

    local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true, desc = desc })
    end

    -- Gitsigns-only keymaps
    map('n', '<leader>gh', function() require('gitsigns').preview_hunk() end, 'Preview hunk')
    map('n', '<leader>gr', function() require('gitsigns').reset_hunk() end, 'Reset hunk')
    map('n', '<leader>gR', function() require('gitsigns').reset_buffer() end, 'Reset buffer')
    map('n', '<leader>gs', function() require('gitsigns').stage_hunk() end, 'Stage hunk')
    map('n', '<leader>gS', function() require('gitsigns').stage_buffer() end, 'Stage buffer')
    map('n', '<leader>gu', function() require('gitsigns').undo_stage_hunk() end, 'Undo stage hunk')

    -- fzf-lua git keymaps (fzf-lua already loading via vim.schedule)
    map('n', '<leader>gt', function() require('fzf-lua').git_status() end, 'Git status')
    map('n', '<leader>gb', function() require('fzf-lua').git_branches() end, 'Git checkout branch')


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
end)

-- ── Heavy git plugins (keymap-triggered) ────────────────────────────────
local git_loaded = false

local function load_git_heavy()
    if git_loaded then return end
    git_loaded = true

    vim.pack.add({
        { src = 'https://github.com/MunifTanjim/nui.nvim' },
        { src = 'https://github.com/NeogitOrg/neogit' },
        { src = 'https://github.com/kdheepak/lazygit.nvim' },
        { src = 'https://github.com/dlyongemallo/diffview.nvim' },
    }, { confirm = false })

    local actions = require('diffview.actions')
    require('diffview').setup({
        enhanced_diff_hl = true,
        keymaps = {
            view = {
                ['[f'] = actions.select_prev_entry,
                [']f'] = actions.select_next_entry,
            },
            file_panel = {
                ['j']    = actions.next_entry,
                ['k']    = actions.prev_entry,
                ['<CR>'] = actions.select_entry,
                ['[f']   = actions.select_prev_entry,
                [']f']   = actions.select_next_entry,
            },
        },
    })

    require('neogit').setup({
        kind         = 'tab',
        integrations = { diffview = true },
    })

    -- DRY helpers
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
            prompt    = opts.prompt or 'Git refs> ',
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

    local function toggle_diffview()
        local lib  = require('diffview.lib')
        local view = lib.get_current_view()
        if view then vim.cmd('DiffviewClose') else vim.cmd('DiffviewOpen') end
    end

    -- Real keymaps (override stubs)
    local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true, desc = desc })
    end

    map('n', '<leader>gv', toggle_diffview, 'Toggle Diffview')
    map('n', '<leader>gp', function()
        pick_ref({
            prompt    = 'PR View (vs Base)> ',
            on_choice = function(base) if base then vim.cmd('DiffviewOpen ' .. base .. '...') end end,
        })
    end, 'PR View (Cumulative)')
    map('n', '<leader>gl', function()
        pick_ref({
            prompt    = 'PR History (since Base)> ',
            on_choice = function(base) if base then vim.cmd('DiffviewFileHistory ' .. base .. '..HEAD') end end,
        })
    end, 'PR History (Commit-by-Commit)')
    map('n', '<leader>gf', '<cmd>DiffviewFileHistory %<CR>', 'Diffview File History (Buffer)')
    map('n', '<leader>gH', '<cmd>DiffviewFileHistory<CR>', 'Diffview File History (Project)')
    map('n', '<leader>gD', function()
        pick_ref({
            prompt    = 'Diff vs Ref (Merge-Base)> ',
            on_choice = function(choice) if choice then vim.cmd('DiffviewOpen ' .. choice .. '...') end end,
        })
    end, 'Diff vs Ref (Merge-Base)')
    map('n', '<leader>gB', create_branch, 'Create new branch')
    map('n', '<leader>gn', function() require('neogit').open({ kind = 'tab' }) end, 'Neogit status')
    map('n', '<leader>gP', function() require('neogit').open({ 'push' }) end, 'Push')
    map('n', '<leader>gU', function() require('neogit').open({ 'pull' }) end, 'Pull')
    map('n', '<leader>gm', function() require('neogit').open({ 'merge' }) end, 'Merge')
    map('n', '<leader>gg', ':LazyGit<CR>', 'Open LazyGit')
end

-- Stub keymaps for heavy git plugins: load on first press, then replay
local heavy_stubs = {
    { '<leader>gv', 'Toggle Diffview' },
    { '<leader>gp', 'PR View (Cumulative)' },
    { '<leader>gl', 'PR History (Commit-by-Commit)' },
    { '<leader>gf', 'Diffview File History (Buffer)' },
    { '<leader>gH', 'Diffview File History (Project)' },
    { '<leader>gD', 'Diff vs Ref (Merge-Base)' },
    { '<leader>gB', 'Create new branch' },
    { '<leader>gn', 'Neogit status' },
    { '<leader>gP', 'Push' },
    { '<leader>gU', 'Pull' },
    { '<leader>gm', 'Merge' },
    { '<leader>gg', 'Open LazyGit' },
}

for _, stub in ipairs(heavy_stubs) do
    local lhs, desc = stub[1], stub[2]
    vim.keymap.set('n', lhs, function()
        load_git_heavy()
        local keys = vim.api.nvim_replace_termcodes(lhs, true, false, true)
        vim.api.nvim_feedkeys(keys, 'm', false)
    end, { desc = desc })
end
