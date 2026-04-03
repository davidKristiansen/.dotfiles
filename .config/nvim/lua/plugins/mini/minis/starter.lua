-- SPDX-License-Identifier: MIT
-- lua/plugins/mini/minis/starter.lua
-- Configuration for mini.starter with logo and keybind-consistent actions

--- Build a list of recent file items from v:oldfiles.
--- @param n_files integer  Maximum number of items to return.
--- @param cwd_only boolean Only include files under the current working directory.
local function recent_files(n_files, cwd_only)
    local oldfiles = vim.v.oldfiles
    if #oldfiles == 0 then
        return {}
    end

    local items = {}
    local n_added = 0
    local cwd = vim.fn.getcwd()
    local cwd_with_sep = cwd == '/' and cwd or (cwd .. '/')
    local section = cwd_only and 'Recent files (cwd)' or 'Recent files'

    for _, path in ipairs(oldfiles) do
        if
            vim.fn.filereadable(path) == 1
            and vim.fn.isdirectory(path) == 0
            and (not cwd_only or vim.startswith(path, cwd_with_sep))
        then
            local name = vim.fn.fnamemodify(path, cwd_only and ':.' or ':~')
            local action = function()
                vim.cmd('bdelete')
                vim.cmd(('edit %s'):format(vim.fn.fnameescape(path)))
            end
            table.insert(items, { name = name, action = action, section = section })
            n_added = n_added + 1
            if n_added == n_files then
                break
            end
        end
    end

    return items
end

--- @return boolean
local function in_git_repo()
    return vim.fn.isdirectory('.git') == 1
        or vim.fn.system('git rev-parse --is-inside-work-tree 2>/dev/null'):find('true') ~= nil
end

local logo = {
    "░░░░░░░░░░░░░░░░░",
    "░░░▄░▀▄░░░▄▀░▄░░░",
    "░░░█▄███████▄█░░░",
    "░░░███▄███▄███░░░",
    "░░░▀█████████▀░░░",
    "░░░░▄▀░░░░░▀▄░░░░",
    "░░░░░░░░░░░░░░░░░",
}

--- Highlight the logo in yellow (gruvbox accent).
local function highlight_logo(buf, logo_lines)
    local ns = vim.api.nvim_create_namespace('starter_logo_hl')
    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local first_logo_line = logo_lines[1]:gsub('^%s*', ''):gsub('%s*$', '')
    local start_idx
    for i, line in ipairs(lines) do
        if line:gsub('^%s*', ''):gsub('%s*$', '') == first_logo_line then
            start_idx = i - 1
            break
        end
    end
    if not start_idx then
        return
    end

    vim.api.nvim_set_hl(0, 'StarterLogo', { fg = '#d79921' })
    for i = 1, #logo_lines do
        local row = start_idx + i - 1
        if lines[row + 1] then
            vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
                end_row = row,
                end_col = #lines[row + 1],
                hl_group = 'StarterLogo',
            })
        end
    end
end

vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniStarterOpened',
    callback = function(args)
        highlight_logo(args.buf or vim.api.nvim_get_current_buf(), logo)
    end,
})

--- Create a picker item — launches a floating picker on top of the starter.
--- The starter stays underneath; if the user cancels, they land back on it.
local function picker_item(name, section, fn)
    return { name = name, section = section, action = fn }
end

--- Create an item that navigates away from the starter (opens a file/buffer).
--- Closes the starter first so we don't leave it lingering.
local function nav_item(name, section, fn)
    return {
        name = name,
        section = section,
        action = function()
            vim.cmd('bdelete')
            fn()
        end,
    }
end

local function cmd_item(name, section, cmd)
    return { name = name, section = section, action = cmd }
end

return {
    evaluate_single = true,
    header = table.concat(logo, '\n'),
    items = (function()
        local items = {}

        -- Recent file sections
        vim.list_extend(items, recent_files(5, true))
        vim.list_extend(items, recent_files(3, false))

        -- Quick actions — shortcut key is the FIRST char so mini.starter
        -- query-by-prefix works. Keys match the rightmost char of the real
        -- keybinding (e.g. <leader>sf -> f).
        -- Pickers float on top of the starter; cancel returns to it.
        table.insert(items, picker_item('f  Find files', 'Actions', function() require('utils.picker').files() end))
        table.insert(items, picker_item('g  Live grep', 'Actions', function() require('utils.picker').live_grep() end))
        table.insert(items, picker_item('o  Recent files', 'Actions', function() require('utils.picker').oldfiles() end))
        table.insert(items, picker_item('b  Buffers', 'Actions', function() require('utils.picker').buffers() end))
        table.insert(items, picker_item('e  Explorer', 'Actions', function()
            -- Trigger the <leader>e stub which handles lazy-loading neo-tree
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<leader>e', true, false, true), 'm', false)
        end))
        table.insert(items, picker_item('s  Sessions', 'Actions', function()
            local detected = require('mini.sessions').detected
            local names = vim.tbl_keys(detected)
            if #names == 0 then
                vim.notify('No sessions detected', vim.log.levels.INFO)
                return
            end
            -- Sort by most recently modified
            table.sort(names, function(a, b) return detected[a].modify_time > detected[b].modify_time end)
            require('fzf-lua').fzf_exec(names, {
                prompt = 'Sessions> ',
                actions = {
                    ['default'] = function(selected)
                        if selected and selected[1] then
                            require('mini.sessions').read(selected[1])
                        end
                    end,
                },
            })
        end))
        if in_git_repo() then
            table.insert(items, picker_item('t  Git status', 'Actions', function() require('fzf-lua').git_status() end))
        end
        table.insert(items, cmd_item('q  Quit', 'Actions', 'qa'))

        return items
    end)(),
    footer = function()
        return ('Loaded %d modules'):format(#vim.tbl_keys(package.loaded))
    end,
    content_hooks = {
        require("mini.starter").gen_hook.aligning('center', 'center'),
        require("mini.starter").gen_hook.padding(3, 2),
    },
}
