local last_picker = nil

local function remember_picker(fn, ...)
  local args = { ... }
  last_picker = function()
    fn(unpack(args))
  end
  fn(unpack(args))
end

local function resume_last_picker()
  if last_picker then
    last_picker()
  else
    require("fzf-lua-enchanted-files").files({ prompt = "Files❯ " })
  end
end

return {
  "ibhagwan/fzf-lua",
  dependencies = {
    "otavioschwanck/fzf-lua-enchanted-files",
    config = function()
      vim.g.fzf_lua_enchanted_files = { max_history_per_cwd = 50 }
    end
  },
  config = true,

  keys = function()
    local fzf = require("fzf-lua")
    local enchanted = require("fzf-lua-enchanted-files")

    return {
      { "<leader><leader>", resume_last_picker, desc = "Resume Last Picker" },
      { "<leader>fb", function() remember_picker(fzf.buffers) end, desc = "Buffers" },
      { "<leader>ff", function() remember_picker(enchanted.files, { prompt = "Files❯ " }) end, desc = "Find Files" },
      { "<leader>fc", function() remember_picker(fzf.files, { cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
      { "<leader>fg", function() remember_picker(fzf.git_files) end, desc = "Find Git Files" },
      { "<leader>fr", function() remember_picker(fzf.oldfiles) end, desc = "Recent Files" },
      { "<leader>/", function() remember_picker(fzf.live_grep) end, desc = "Grep" },
      { "<leader>sg", function() remember_picker(fzf.live_grep) end, desc = "Grep" },
      {
        "<leader>sw",
        function()
          if vim.fn.mode() == "v" then
            remember_picker(fzf.grep_visual)
          else
            remember_picker(fzf.grep_cword)
          end
        end,
        desc = "Grep Word Under Cursor/Selection",
        mode = { "n", "x" }
      },
      { "<leader>s/", function() remember_picker(fzf.search_history) end,        desc = "Search History" },
      { "<leader>sc", function() remember_picker(fzf.command_history) end,       desc = "Command History" },
      { "<leader>:",  function() remember_picker(fzf.command_history) end,       desc = "Command History" },
      { '<leader>s"', function() remember_picker(fzf.registers) end,             desc = "Registers" },
      { "<leader>sj", function() remember_picker(fzf.jumps) end,                 desc = "Jumps" },
      { "<leader>sm", function() remember_picker(fzf.marks) end,                 desc = "Marks" },
      { "<leader>sk", function() remember_picker(fzf.keymaps) end,               desc = "Keymaps" },
      { "<leader>sh", function() remember_picker(fzf.help_tags) end,             desc = "Help Tags" },
      { "<leader>sM", function() remember_picker(fzf.man_pages) end,             desc = "Man Pages" },
      { "<leader>sd", function() remember_picker(fzf.diagnostics_workspace) end, desc = "Workspace Diagnostics" },
      { "<leader>sD", function() remember_picker(fzf.diagnostics_document) end,  desc = "Buffer Diagnostics" },
      { "<leader>sR", function() remember_picker(fzf.resume) end,                desc = "Resume Last Picker" },
    }
  end,
}
