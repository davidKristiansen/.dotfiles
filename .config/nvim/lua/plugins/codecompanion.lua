return {
  {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanionChat" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      display = { chat = { show_settings = true } },
      strategies = {
        chat = { adapter = "openai" },
        inline = {
          -- adapter = "gemini",
          keymaps = {
            accept_change = {
              modes = { n = "<leader>aa" },
              description = "Accept the suggested change",
            },
            reject_change = {
              modes = { n = "<leader>aA" },
              description = "Reject the suggested change",
            },
          },
        },
      },
      adapters = {
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            env = {
              api_key = vim.env["GEMINI_API_KEY"],
            },
            schema = {
              model = {
                default = function()
                  return "gemini-2.5-pro-exp-03-25"
                end
              }
            }
          })
        end,
        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            env = {
              api_key = vim.env["OPENAI_API_KEY"],
            },
            schema = {
              model = {
                default = function()
                  return "o4-mini"
                end,
              },
            },
          })
        end,
      },
    },
    keys = {
      { "<leader>ac", "<cmd>CodeCompanionChat toggle<cr>", desc = "Toggle Chat" },
      { "<leader>ar", "<cmd>CodeCompanionReview<cr>",      desc = "Review" },
      { "<leader>af", "<cmd>CodeCompanionActions<cr>",     desc = "Actions" },
      { "<leader>aw", "<cmd>CodeCompanionWorkspace<CR>",   desc = "Workspaces" },
    },
  },
}
