-- SPDX-License-Identifier: MIT
-- pi-nvim: Bridge between pi coding agent and Neovim (carderne/pi-nvim).
-- Keymap-triggered: loads on first <leader>p* press.

local loaded = false

local function load_pi()
    if loaded then return end
    loaded = true

    vim.pack.add({
        { src = 'https://github.com/carderne/pi-nvim' },
    })

    local ok, pi = pcall(require, 'pi-nvim')
    if not ok then return end

    pi.setup()

    -- Real keymaps
    vim.keymap.set({ 'n', 'v' }, '<leader>pp', '<Cmd>Pi<CR>', { desc = 'Pi send dialog' })
    vim.keymap.set('n', '<leader>ps', '<Cmd>PiSend<CR>', { desc = 'Pi send prompt' })
    vim.keymap.set('n', '<leader>pf', '<Cmd>PiSendFile<CR>', { desc = 'Pi send file' })
    vim.keymap.set('v', '<leader>pv', '<Cmd>PiSendSelection<CR>', { desc = 'Pi send selection' })
    vim.keymap.set('n', '<leader>pb', '<Cmd>PiSendBuffer<CR>', { desc = 'Pi send buffer' })
    vim.keymap.set('n', '<leader>pi', '<Cmd>PiPing<CR>', { desc = 'Pi ping' })
    vim.keymap.set('n', '<leader>pS', '<Cmd>PiSessions<CR>', { desc = 'Pi sessions' })
end

-- Stub keymaps (eager, for which-key discovery)
local stubs = {
    { '<leader>pp', mode = { 'n', 'v' }, desc = 'Pi send dialog' },
    { '<leader>ps', mode = { 'n' }, desc = 'Pi send prompt' },
    { '<leader>pf', mode = { 'n' }, desc = 'Pi send file' },
    { '<leader>pv', mode = { 'v' }, desc = 'Pi send selection' },
    { '<leader>pb', mode = { 'n' }, desc = 'Pi send buffer' },
    { '<leader>pi', mode = { 'n' }, desc = 'Pi ping' },
    { '<leader>pS', mode = { 'n' }, desc = 'Pi sessions' },
}

for _, stub in ipairs(stubs) do
    vim.keymap.set(stub.mode, stub[1], function()
        load_pi()
        vim.schedule(function()
            local keys = vim.api.nvim_replace_termcodes(stub[1], true, false, true)
            vim.api.nvim_feedkeys(keys, 'm', false)
        end)
    end, { desc = stub.desc })
end
