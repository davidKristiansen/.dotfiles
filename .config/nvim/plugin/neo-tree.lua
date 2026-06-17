---@diagnostic disable: duplicate-index
---@diagnostic disable: duplicate-index
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
        filesystem           = { use_libuv_file_watcher = true },
        window               = { mappings = { ['<C-v>'] = 'open_vsplit' } },
        filesystem           = {
            follow_current_file = {
                enabled = true,
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

    vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<CR>', { desc = 'Explorer' })
end)
