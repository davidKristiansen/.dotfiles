-- lua/plugins/typst.lua
-- SPDX-License-Identifier: MIT

-- typst.vim configuration (kaarmu/typst.vim)
-- Provides filetype detection, vim syntax highlighting, concealment, and :TypstWatch

vim.g.typst_conceal = 1
vim.g.typst_conceal_math = 1
vim.g.typst_conceal_emoji = 1

-- Track which PDFs we've already opened so zathura only launches once per file
local opened_pdfs = {}

--- Open the corresponding PDF in zathura (auto-reloads on rebuild).
--- Called once on first save; tinymist's exportPdf=onSave handles recompilation.
local function open_typst_pdf()
    local filepath = vim.api.nvim_buf_get_name(0)
    if not filepath:match("%.typ$") then return end

    local pdf_path = filepath:gsub("%.typ$", ".pdf")
    if opened_pdfs[pdf_path] then return end

    -- Only open if the PDF actually exists (i.e. first build succeeded)
    if vim.uv.fs_stat(pdf_path) then
        opened_pdfs[pdf_path] = true
        vim.system({ "zathura", pdf_path }, { detach = true })
    end
end

local augroup = vim.api.nvim_create_augroup("TypstPdf", { clear = true })

-- Auto-open PDF after first save
vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    pattern = "*.typ",
    callback = function()
        -- Small delay to let tinymist finish exporting
        vim.defer_fn(open_typst_pdf, 500)
    end,
})

-- :TypstOpenPdf to manually open/reopen
vim.api.nvim_create_user_command("TypstOpenPdf", function()
    local filepath = vim.api.nvim_buf_get_name(0)
    local pdf_path = filepath:gsub("%.typ$", ".pdf")
    opened_pdfs[pdf_path] = nil -- reset so it opens fresh
    open_typst_pdf()
end, { desc = "Open Typst PDF in zathura" })
