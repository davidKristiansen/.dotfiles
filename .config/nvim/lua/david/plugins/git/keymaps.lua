local M = {}


local debug = require("david.debug")

function M.on_attach(buffer)
  local gs = package.loaded.gitsigns
  local keys = {
    { '<leader>ga', gs.stage_hunk,                                                       desc = "Stage hunk" },
    { '<leader>gr', gs.reset_hunk,                                                       desc = "Reset hunk" },
    { '<leader>gR', gs.reset_buffer,                                                     desc = "Reset buffer" },
    { '<leader>ga', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end, desc = "Stage hunk",       mode = 'v' },
    { '<leader>gr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end, desc = "Reset hunk",       mode = 'v' },
    { '<leader>gA', gs.stage_buffer,                                                     desc = "Stage buffer" },
    { '<leader>gu', gs.undo_stage_hunk,                                                  desc = "Undo stage hunk" },
    { '<leader>gU', gs.reset_buffer,                                                     desc = "Undo stage buffer" },
    { '<leader>gp', gs.preview_hunk,                                                     desc = "Preview hunk" },
    -- { '<leader>gb', function() gs.blame_line { full = true } end, desc = "Blame line"},
    { '<leader>gb', gs.toggle_current_line_blame,                                        desc = "Blame line toggle" },
    { '<leader>gd', gs.diffthis,                                                         desc = "Diff this" },
    { ']h',         gs.next_hunk,                                                        desc = "Next hunk" },
    { '[h',         gs.prev_hunk,                                                        desc = "Previous hunk" },
    -- { '<leader>gD', function() gs.diffthis('~') end,                                     desc = "Diff this (~)" },
    -- { '<leader>gd', gs.toggle_deleted, desc = "Toggle deleted"},
    { 'ih',         ':<C-U>Gitsigns select_hunk<CR>',                                    desc = "Select hunk",      mode = { 'o', 'x' }, }
  }

  local opts = {
    buffer = buffer
  }

  for _, key in pairs(keys) do
    opts.desc = key.desc
    vim.keymap.set(key.mode or "n", key[1], key[2], opts)
  end

  debug.tprint(opts)
end

return M
-- local gs = package.loaded.gitsigns
--   local function map(mode, l, r, opts)
--     opts = opts or {}
--     opts.buffer = bufnr
--     vim.keymap.set(mode, l, r, opts)
--   end
--
--   -- Navigation
--   map('n', ']c', function()
--     if vim.wo.diff then return ']c' end
--     vim.schedule(function() gs.next_hunk() end)
--     return '<Ignore>'
--   end, { expr = true })
--
--   map('n', '[c', function()
--     if vim.wo.diff then return '[c' end
--     vim.schedule(function() gs.prev_hunk() end)
--     return '<Ignore>'
--   end, { expr = true })
--
--   -- Actions
--   map('n', '<leader>gr', gs.reset_hunk)
--   map('v', '<leader>gs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
--   map('v', '<leader>gr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
--   map('n', '<leader>gS', gs.stage_buffer)
--   map('n', '<leader>gu', gs.undo_stage_hunk)
--   map('n', '<leader>gR', gs.reset_buffer)
--   map('n', '<leader>gp', gs.preview_hunk)
--   map('n', '<leader>gb', function() gs.blame_line { full = true } end)
--   map('n', '<leader>gb', gs.toggle_current_line_blame)
--   map('n', '<leader>gd', gs.diffthis)
--   map('n', '<leader>gD', function() gs.diffthis('~') end)
--   map('n', '<leader>gd', gs.toggle_deleted)
--
--   -- Text object
--   map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
