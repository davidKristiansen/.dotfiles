-- SPDX-License-Identifier: MIT
-- overseer.nvim: task runner and job management.

local loaded = false

local function load_overseer()
  if loaded then return end
  loaded = true

  vim.pack.add({
    { src = 'https://github.com/stevearc/overseer.nvim' },
  }, { confirm = false })

  local ok, overseer = pcall(require, 'overseer')
  if not ok then return end

  overseer.setup({})

  -- Real keymaps
  vim.keymap.set('n', '<leader>or', '<cmd>OverseerRun<cr>', { desc = 'Overseer: Run task' })
  vim.keymap.set('n', '<leader>ot', '<cmd>OverseerToggle<cr>', { desc = 'Overseer: Toggle task list' })
  vim.keymap.set('n', '<leader>oa', '<cmd>OverseerTaskAction<cr>', { desc = 'Overseer: Task action' })
  vim.keymap.set('n', '<leader>ol', function()
    local tasks = overseer.list_tasks({ recent_first = true })
    if #tasks > 0 then
      overseer.run_action(tasks[1], 'restart')
    else
      vim.notify('No overseer tasks found', vim.log.levels.WARN)
    end
  end, { desc = 'Overseer: Restart last task' })
end

-- Stub keymaps (eager, for which-key discovery)
local stubs = {
  { '<leader>or', desc = 'Overseer: Run task' },
  { '<leader>ot', desc = 'Overseer: Toggle task list' },
  { '<leader>oa', desc = 'Overseer: Task action' },
  { '<leader>ol', desc = 'Overseer: Restart last task' },
}

for _, stub in ipairs(stubs) do
  vim.keymap.set('n', stub[1], function()
    load_overseer()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(stub[1], true, true, true), 'mit', false)
  end, { desc = stub.desc })
end
