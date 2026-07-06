-- SPDX-License-Identifier: MIT
-- bigfile: disable heavy features for large files (custom, no plugin).

local bigfile_threshold = 2 * 1024 * 1024 -- 2 MiB

vim.api.nvim_create_autocmd('BufReadPre', {
  group = vim.api.nvim_create_augroup('bigfile', { clear = true }),
  callback = function(ev)
    local path = ev.match
    local ok, stat = pcall(vim.uv.fs_stat, path)
    if not ok or not stat or stat.size < bigfile_threshold then
      return
    end

    vim.b[ev.buf].bigfile = true

    -- Disable heavy buffer-local features
    vim.opt_local.swapfile = false
    vim.opt_local.foldmethod = 'manual'
    vim.opt_local.undolevels = -1
    vim.opt_local.undoreload = 0
    vim.opt_local.list = false

    -- Disable syntax and filetype plugins (defer so BufReadPost sees it)
    vim.api.nvim_create_autocmd('BufReadPost', {
      buffer = ev.buf,
      once = true,
      callback = function()
        vim.cmd('syntax clear')
        vim.opt_local.syntax = ''
        -- Detach treesitter if loaded
        pcall(vim.treesitter.stop, ev.buf)
        -- Detach LSP clients
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = ev.buf })) do
          vim.lsp.buf_detach_client(ev.buf, client.id)
        end
        vim.notify(
          'bigfile: disabled heavy features for ' .. vim.fn.fnamemodify(path, ':t'),
          vim.log.levels.INFO
        )
      end,
    })
  end,
})
