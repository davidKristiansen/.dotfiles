-- SPDX-License-Identifier: MIT
-- lua/plugins/mini/minis/sessions.lua
-- Configuration for mini.sessions

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
    verbose = { read = false, write = true, delete = true },
}
