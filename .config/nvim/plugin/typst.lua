-- SPDX-License-Identifier: MIT
-- typst.vim configuration: filetype detection, concealment, PDF viewer.
-- Loaded on FileType typst.

-- Globals must be set before the plugin loads
vim.g.typst_conceal       = 1
vim.g.typst_conceal_math  = 1
vim.g.typst_conceal_emoji = 1

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'typst',
  once = true,
  callback = function()
    vim.pack.add({
      { src = 'https://github.com/kaarmu/typst.vim' },
    }, { confirm = false })

    local opened_pdfs = {}

    local function open_typst_pdf()
      local filepath = vim.api.nvim_buf_get_name(0)
      if not filepath:match('%.typ$') then return end
      local pdf_path = filepath:gsub('%.typ$', '.pdf')
      if opened_pdfs[pdf_path] then return end
      if vim.uv.fs_stat(pdf_path) then
        opened_pdfs[pdf_path] = true
        vim.system({ 'zathura', pdf_path }, { detach = true })
      end
    end

    local augroup = vim.api.nvim_create_augroup('TypstPdf', { clear = true })

    vim.api.nvim_create_autocmd('BufWritePost', {
      group    = augroup,
      pattern  = '*.typ',
      callback = function() vim.defer_fn(open_typst_pdf, 500) end,
    })

    vim.api.nvim_create_user_command('TypstOpenPdf', function()
      local filepath = vim.api.nvim_buf_get_name(0)
      local pdf_path = filepath:gsub('%.typ$', '.pdf')
      opened_pdfs[pdf_path] = nil
      open_typst_pdf()
    end, { desc = 'Open Typst PDF in zathura' })
  end,
})
