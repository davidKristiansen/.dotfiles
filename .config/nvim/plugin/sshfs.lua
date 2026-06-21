-- SPDX-License-Identifier: MIT
-- sshfs.nvim: remote filesystem. Loaded on the entry commands (:SSHConnect /
-- :SSHConfig); the first one you type registers the full set of SSH* commands.
-- (Other SSH* commands only operate on an active connection, so stubbing the
-- two entry points is sufficient.)

require('utils.lazy').add({
  src = 'https://github.com/uhs-robert/sshfs.nvim',
  cmd = { 'SSHConnect', 'SSHConfig' },
  config = function()
    require('sshfs').setup({
      host_paths = { ['EUDC2'] = '/srv/traefik' },
    })
  end,
})
