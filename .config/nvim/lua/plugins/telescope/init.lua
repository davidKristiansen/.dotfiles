-- SPDX-License-Identifier: MIT
local M = {}

function M.setup()
  -- 1. Ensure fzf-native is built. This is done first.
  require("plugins.telescope.fzf-native").ensure_built()

  -- 2. Setup telescope
  local ok, telescope = pcall(require, "telescope")
  if not ok then
    vim.notify("telescope not found", vim.log.levels.WARN)
    return
  end

  local builtin = require("telescope.builtin")
  local themes = require("telescope.themes")

  telescope.setup({
    defaults = {
      colorscheme = "gruvbox-material",
      layout_strategy = "bottom_pane",
      layout_config = {
        height = 25,
        prompt_position = "bottom",
      },
      sorting_strategy = "descending",
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden",
        "--glob=!.git/",
      },
      file_ignore_patterns = {
        "node_modules",
        ".git",
        "target",
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,                   -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true,    -- override the file sorter
        case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
      },
      frecency = {
        workspace = "CWD",
        show_unindexed = true,
        -- You can configure other frecency options here, for example:
        show_scores = true,
        -- ignore_patterns = {"*.git/*", "*/tmp/*"},
      },
      fyler_zoxide = {
        -- Extension configuration
      }
    }
  })

  -- 3. Load extensions
  pcall(telescope.load_extension, "fzf")
  pcall(telescope.load_extension, "frecency")
  pcall(telescope.load_extension, "fyler_zoxide")

  -- 4. Set up keymaps
  vim.keymap.set("n", "<leader>sf", "<cmd>Telescope frecency workspace=CWD<cr>", { desc = "Telescope Frecency" })
  vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Telescope Live Grep" })
  vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Telescope Buffers" })
  vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Telescope Help Tags" })
  vim.keymap.set("n", "<leader>sw",
    function() require("telescope.builtin").grep_string({ search = vim.fn.expand("<cWORD>") }) end,
    { desc = "Telescope grep CWORD" })
  vim.keymap.set("v", "<leader>sw", function()
    vim.cmd('noau normal! "vy"')
    local text = vim.fn.getreg('v')
    vim.fn.setreg('v', {})
    require("telescope.builtin").grep_string({ search = text })
  end, { desc = "Telescope grep selection" })
  vim.keymap.set("n", "*", function() builtin.current_buffer_fuzzy_find({ default_text = vim.fn.expand("<cWORD>") }) end,
    { desc = "Telescope current buffer fuzzy find CWORD" })
  vim.keymap.set("n", "/", function() builtin.current_buffer_fuzzy_find() end,
    { desc = "Telescope Live Grep (current buffer)" })
  vim.keymap.set("n", "<leader><leader>", builtin.resume, { desc = "Telescope Resume" })
  vim.keymap.set("n", "<leader>sj", builtin.jumplist, { desc = "Telescope Jumplist" })
end

return M
