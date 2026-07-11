-- SPDX-License-Identifier: MIT
-- overseer.nvim: task runner and job management (keymap-triggered, <leader>r*).

require('utils.lazy').add({
  src = 'https://github.com/stevearc/overseer.nvim',
  config = function()
    require('overseer').setup({})
  end,
  keys = {
    { '<leader>rr', '<cmd>OverseerRun<cr>', desc = 'Overseer: Run task' },
    { '<leader>rt', '<cmd>OverseerToggle<cr>', desc = 'Overseer: Toggle task list' },
    { '<leader>ra', '<cmd>OverseerTaskAction<cr>', desc = 'Overseer: Task action' },
    {
      '<leader>rl',
      function()
        local overseer = require('overseer')
        local tasks = overseer.list_tasks({ recent_first = true })
        if #tasks > 0 then
          overseer.run_action(tasks[1], 'restart')
        else
          vim.notify('No overseer tasks found', vim.log.levels.WARN)
        end
      end,
      desc = 'Overseer: Restart last task',
    },
  },
})
