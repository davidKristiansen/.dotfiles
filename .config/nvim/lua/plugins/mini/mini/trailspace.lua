vim.api.nvim_create_autocmd("User", {
  pattern = "SnacksDashboardOpened",
  callback = function(args)
    vim.b[args.buf].minitrailspace_disable = true
  end,
})

return {
  -- Highlight only in normal buffers (ones with empty 'buftype'). This is
  -- useful to not show trailing whitespace where it usually doesn't matter.
  only_in_normal_buffers = true,
}
