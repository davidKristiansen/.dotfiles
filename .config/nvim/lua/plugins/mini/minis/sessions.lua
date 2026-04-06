-- SPDX-License-Identifier: MIT
-- lua/plugins/mini/minis/sessions.lua
-- Configuration for mini.sessions

--- Rename the current tmux window to the session name.
local function tmux_rename_window(session_data)
    if vim.env.TMUX and session_data and session_data.name then
        local name = session_data.name:gsub('%.vim$', '')
        vim.fn.system({ 'tmux', 'rename-window', name })
    end
end

--- Close neo-tree before writing a session so the special buffer
--- doesn't end up in the session file.
local function close_neotree()
    pcall(function() vim.cmd('Neotree close') end)
end

--- After reading a session: rename tmux window, re-trigger filetype
--- detection so plugins (treesitter, LSP, etc.) attach to restored
--- buffers, and show the starter if there are no real buffers.
local function post_read(session_data)
    tmux_rename_window(session_data)

    -- Re-trigger BufRead/FileType for all loaded buffers so lazy-loaded
    -- plugins (treesitter, LSP, gitsigns, etc.) attach properly.
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
            vim.api.nvim_buf_call(buf, function()
                vim.cmd('doautocmd BufReadPost')
                if vim.bo.filetype ~= '' then
                    vim.cmd('doautocmd FileType ' .. vim.bo.filetype)
                end
            end)
        end
    end

    -- If the only buffer is an empty unnamed one, show the starter instead
    local bufs = vim.tbl_filter(function(b)
        return vim.api.nvim_buf_is_loaded(b)
            and vim.bo[b].buflisted
            and vim.api.nvim_buf_get_name(b) ~= ''
    end, vim.api.nvim_list_bufs())

    if #bufs == 0 then
        local ok, starter = pcall(require, 'mini.starter')
        if ok then starter.open() end
    end
end

--- Auto-restore: on VimEnter, if a session matching the cwd basename
--- exists in the global sessions directory, read it automatically.
--- Skipped when nvim is opened with files/stdin or via -S.
vim.api.nvim_create_autocmd('VimEnter', {
    group = vim.api.nvim_create_augroup('mini_sessions_auto_restore', { clear = true }),
    once = true,
    callback = function()
        -- Skip if opened with file arguments or stdin
        if vim.fn.argc() > 0 then return end

        local ok, sessions = pcall(require, 'mini.sessions')
        if not ok then return end

        local name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
        if sessions.detected[name] then
            sessions.read(name)
        end
    end,
})

return {
    autoread = false,
    -- Auto-save the active session on quit so it stays current
    autowrite = true,
    -- Store global sessions in the standard Neovim data directory
    directory = vim.fn.stdpath('data') .. '/sessions',
    -- Disable local Session.vim detection (sessions live in the global dir)
    file = '',
    -- Overwrite existing session files without prompting
    force = { read = false, write = true, delete = false },
    hooks = {
        pre  = { write = close_neotree },
        post = { read = post_read },
    },
    verbose = { read = false, write = true, delete = true },
}
