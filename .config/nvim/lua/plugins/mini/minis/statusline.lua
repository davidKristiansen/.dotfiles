-- SPDX-License-Identifier: MIT
-- Temporary stub for mini.statusline (will be replaced with full config).

vim.api.nvim_create_autocmd("RecordingEnter", {
    callback = function()
        vim.cmd("redrawstatus!")
        vim.defer_fn(function()
            vim.cmd("redrawstatus!")
        end, 100)
    end
})

return {
    content = {
        active = function()
            local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
            local git           = MiniStatusline.section_git({ trunc_width = 40 })
            local diff          = MiniStatusline.section_diff({ trunc_width = 75 })
            local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75 })
            local lsp           = MiniStatusline.section_lsp({ trunc_width = 75 })
            local filename      = vim.fn.expand('%:t')
            local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
            local location      = MiniStatusline.section_location({ trunc_width = 75 })
            -- local fmt_mode      = fmt.status_icon()


            -- Macro indicator (shows when recording a macro)
            local macro = ''
            local reg   = vim.fn.reg_recording()
            if reg ~= '' then
                macro = '● ' .. reg
            end

            return MiniStatusline.combine_groups({
                { hl = mode_hl,                 strings = { mode, macro } },
                { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp } },
                '%<',
                { hl = 'MiniStatuslineFilename', strings = {} },
                '%=',
                { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
                { hl = mode_hl,                  strings = { location } },
            })
        end,
        inactive = nil,
    },
    use_icons = true,
}

