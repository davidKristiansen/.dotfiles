-- SPDX-License-Identifier: MIT
-- neo-tree.nvim: file explorer + lsp-file-operations (vim.schedule).
-- lsp-file-operations must load AFTER neo-tree.

vim.schedule(function()
    vim.pack.add({
        { src = 'https://github.com/nvim-lua/plenary.nvim' },
        { src = 'https://github.com/MunifTanjim/nui.nvim' },
        { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim' },
        { src = 'https://github.com/antosha417/nvim-lsp-file-operations' },
    }, { confirm = false })

    require('neo-tree').setup({
        use_popups_for_input = false,
        enable_git_status    = true,
        window               = { mappings = { ['<C-v>'] = 'open_vsplit' } },
        filesystem           = {
            use_libuv_file_watcher = true,
            follow_current_file = {
                enabled = false,
                leave_dirs_open = false,
            },
        },
    })

    -- lsp-file-operations: must be set up after neo-tree
    local ok, lsp_file_ops = pcall(require, 'lsp-file-operations')
    if ok then
        lsp_file_ops.setup()
        -- Advertise file-operation capabilities to all LSP servers
        vim.lsp.config('*', {
            capabilities = lsp_file_ops.default_capabilities(),
        })
    end

    -- Only reveal when the current buffer is a real file on disk; otherwise
    -- (starter, terminal, [No Name], help, quickfix, …) reveal has no valid
    -- target, so fall back to a plain open/toggle.
    local function on_real_file()
        local buf = vim.api.nvim_get_current_buf()
        local name = vim.api.nvim_buf_get_name(buf)
        return vim.bo[buf].buftype == '' and name ~= '' and vim.fn.filereadable(name) == 1
    end

    -- Toggle the explorer; on open, reveal (jump to) the current file.
    -- follow_current_file is disabled, so it only jumps on open, not on every
    -- buffer switch.
    vim.keymap.set('n', '<leader>e', function()
        vim.cmd(on_real_file() and 'Neotree toggle reveal' or 'Neotree toggle')
    end, { desc = 'Explorer (reveal current file)' })

    -- Reveal current file without toggling closed (focus tree if already open).
    vim.keymap.set('n', '<leader>E', function()
        vim.cmd(on_real_file() and 'Neotree reveal' or 'Neotree focus')
    end, { desc = 'Explorer: reveal current file' })
end)
