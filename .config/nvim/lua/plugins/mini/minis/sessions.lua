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
        post = { read = tmux_rename_window },
    },
    verbose = { read = false, write = true, delete = true },
}
