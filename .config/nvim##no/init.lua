-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

require("config.options")
require("config.autocmd")
require("config.keymaps")
require("config.lsp")
require("config.lazy")


vim.keymap.set("n", "<C-s>", function()
  local snacks = require("snacks")

  -- Use your pre-sorted frecent project list
  local xdg_bin_home = os.getenv("XDG_BIN_HOME") or (os.getenv("HOME") .. "/.local/bin")
  local script_path = xdg_bin_home .. "/frecent-projects.sh"
  local handle = io.popen(script_path)
  if not handle then return end

  local projects = {}
  for line in handle:lines() do
    if vim.uv.fs_stat(line) then
      table.insert(projects, line)
    end
  end
  handle:close()

  snacks.picker.select(projects, {
    prompt = "Switch to project",
    preview = "eza -TL 1 --color=always {}",
  }, function(project)
    if not project then return end
    local session = project:match("([^/]+)$"):gsub("[^%w_-]", "_")
    local in_tmux = os.getenv("TMUX") ~= nil

    if in_tmux then
      local cmd = string.format(
        'tmux has-session -t %q 2>/dev/null && tmux switch-client -t %q || (cd %q && tmux new-session -ds %q -c %q && tmux switch-client -t %q)',
        session, session, project, session, project, session
      )
      os.execute(cmd)
    else
      local cmd = string.format(
        "nohup setsid tmux new-session -A -s %q -c %q >/dev/null 2>&1 &",
        session,
        project
      )
      os.execute(cmd)
      vim.schedule(function()
        vim.cmd("qa!")
      end)
    end
  end)
end, { desc = "Switch tmux project", silent = true })
