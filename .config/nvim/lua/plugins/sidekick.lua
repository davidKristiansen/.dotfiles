-- SPDX-License-Identifier: MIT
vim.pack.add({
  { src = "https://github.com/folke/sidekick.nvim" },
}, { confirm = false })

local map = vim.keymap.set

require("sidekick").setup({
  cli = {
    mux = {
      backend = "tmux",
      enabled = true,
    },
    prompts = {
      refactor = "Please refactor {this} to be more maintainable",
      security = "Review {file} for security vulnerabilities",
      custom = function(ctx)
        return "Current file: " .. ctx.buf .. " at line " .. ctx.row
      end,
    },
  },
})

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
map(
  { "n" },
  "<leader>an",
  function()
    local nes = require("sidekick.nes")
    nes.enable(not nes.enabled)
  end,
  { desc = "Sidekick Toggle NES" }
)

map(
  { "x", "n" },
  "<leader>at",
  function() require("sidekick.cli").send({ msg = "{this}" }) end,
  { desc = "Send This" }
)
map(
  { "x" },
  "<leader>aT",
  function() require("sidekick.cli").send({ msg = "please translate this {selection}" }) end,
  { desc = "Translate" }
)

map(
  { "x" },
  "<leader>av",
  function() require("sidekick.cli").send({ msg = "{selection}" }) end,
  { desc = "Send Visual Selection" }
)
map(
  { "n", "x" },
  "<leader>ap",
  function() require("sidekick.cli").prompt() end,
  { desc = "Sidekick Select Prompt" }
)
map(
  { "n", "x", "i", "t" },
  "<c-.>",
  function() require("sidekick.cli").focus() end,
  { desc = "Sidekick Switch Focus" }
)

map(
  { "n" },
  "<TAB>",
  function() require("sidekick").nes_jump_or_apply() end,
  { desc = "Apply suggestion" }
)

map(
  { "n" },
  "<C-G>",
  function() require("sidekick.nes").clear() end,
  { desc = "Clear suggestion" }
)
