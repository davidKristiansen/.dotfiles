---@diagnostic disable: trailing-space
---@diagnostic disable: trailing-space
-- SPDX-License-Identifier: MIT
-- fzf-lua: fuzzy finder (used by many downstream plugins).

vim.schedule(function()
    vim.pack.add({
        { src = 'https://github.com/ibhagwan/fzf-lua',                      version = vim.version.range('*') },
        { src = 'https://github.com/otavioschwanck/fzf-lua-enchanted-files' },
    }, { confirm = false })

    --- Send selected fzf-lua items to opencode as context files.
    local function opencode_send(selected, opts)
        if not selected or #selected == 0 then return end
        local ok, context = pcall(require, 'opencode.context')
        if not ok then
            vim.notify('opencode.nvim not available', vim.log.levels.WARN)
            return
        end
        local core_ok, core = pcall(require, 'opencode.core')
        if core_ok then
            core.open({ new_session = false, focus = 'input', start_insert = true })
        end
        for _, item in ipairs(selected) do
            local path = require('fzf-lua.path').entry_to_file(item, opts).path
            if path then context.add_file(path) end
        end
    end

    local default_ignores = {
        '**/.pytest_cache/**', '**/__pycache__/**', '**/.mypy_cache/**',
        '**/.venv/**', '**/venv/**', '**/.git/**', '**/.idea/**',
        '**/build/**', '**/dist/**', '**/*.egg-info/**',
    }

    require('fzf-lua').setup({
        fzf_opts = { ['--layout'] = 'default' },
        winopts  = {
            height = 0.40,
            width  = 1.00,
            row    = 1.00,
            col    = 0.50,
        },
        keymap   = { fzf = { ['ctrl-c'] = 'abort' } },
        actions  = {
            files = {
                true,
                ['enter']  = FzfLua.actions.file_edit_or_qf,
                ['ctrl-s'] = FzfLua.actions.file_split,
                ['ctrl-v'] = FzfLua.actions.file_vsplit,
                ['ctrl-t'] = FzfLua.actions.file_tabedit,
                ['ctrl-q'] = FzfLua.actions.file_sel_to_qf,
                ['alt-Q']  = FzfLua.actions.file_sel_to_ll,
                ['alt-i']  = FzfLua.actions.toggle_ignore,
                ['alt-h']  = FzfLua.actions.toggle_hidden,
                ['alt-f']  = FzfLua.actions.toggle_follow,
                ['ctrl-a'] = opencode_send,
            },
        },
        grep     = {
            rg_glob         = true,
            glob_flag       = '--iglob',
            glob_separator  = '%s%-%-',
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
end)
