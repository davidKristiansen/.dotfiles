return {
  {
    "zbirenbaum/copilot.lua",
    cmd = { "Copilot" },
    opts = {
      panel = { enabled = false },
      suggestion = { enabled = false },
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
      "zbirenbaum/copilot.lua",
    },
    build = "make tiktoken",
    opts = {
      picker = function()
        require('fzf-lua').register_ui_select()
      end,
      provider = "copilot", -- explicitly use Copilot backend
      model = "gpt-4o",     -- pick at runtime too
      auto_insert_mode = true,
      -- window = { layout = "float", width = 0.6, height = 0.8 },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "copilot-chat",
        callback = function(ev)
          -- ensure Copilot’s own chat <Tab> can work
          vim.keymap.set("i", "<Tab>", function()
            -- fall back to regular key so CopilotChat sees it
            return "<Tab>"
          end, { buffer = ev.buf, expr = true })

          -- optional: if you use copilot.lua ghost text, avoid collisions
          -- (assumes you mapped accept to <C-l> globally)
        end,
      })
    end,

  }
}
