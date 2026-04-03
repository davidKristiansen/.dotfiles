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

--- After reading a session: rename tmux window, reopen neo-tree if the
--- cwd has a visible tree state, and show the starter if there are no
--- real buffers.
local function post_read(session_data)
    tmux_rename_window(session_data)

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

return {
    -- Don't auto-restore; use the starter 's' action or :lua MiniSessions.select()
    autoread = false,
    -- Auto-save the active session on quit so it stays current
    autowrite = true,
    -- Store global sessions in the standard Neovim data directory
    directory = vim.fn.stdpath('data') .. '/sessions',
    -- Also detect a local Session.vim in the cwd
    file = 'Session.vim',
    -- Overwrite existing session files without prompting
    force = { read = false, write = true, delete = false },
    hooks = {
        pre  = { write = close_neotree },
        post = { read = post_read },
    },
    verbose = { read = false, write = true, delete = true },
}
