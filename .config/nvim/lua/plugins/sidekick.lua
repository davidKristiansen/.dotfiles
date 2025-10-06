-- SPDX-License-Identifier: MIT
local map = vim.keymap.set

local opts = {
  cli = {
    mux = {
      backend = "tmux",
      enabled = true,
    },
  },
}

map(
  { "n", "x", "i", "t" },
  "<c-.>",
  function() require("sidekick.cli").focus() end,
  { desc = "Sidekick Switch Focus" }
)
map(
  { "n", "v" },
  "<leader>aa",
  function() require("sidekick.cli").toggle({ focus = true }) end,
  { desc = "Sidekick Toggle CLI" }
)
map(
  { "n", "v" },
  "<leader>ac",
  function() require("sidekick.cli").toggle({ name = "copilot", focus = true }) end,
  { desc = "Sidekick Copilot Toggle" }
)
map(
  { "n", "v" },
  "<leader>ag",
  function() require("sidekick.cli").toggle({ name = "gemini", focus = true }) end,
  { desc = "Sidekick Gemini Toggle" }
)
map(
  { "n", "v" },
  "<leader>ap",
  function() require("sidekick.cli").select_prompt() end,
  { desc = "Sidekick Ask Prompt" }
)
local M = {}

function M.setup()
  local ok, sidekick = pcall(require, "sidekick")
  if ok then
    sidekick.setup(opts)
  end
end

return M
