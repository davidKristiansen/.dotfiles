return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "FzfLua" },
    opts = {},
    keys = {
      { "<leader>,",       "<cmd>FzfLua buffers<cr>",               desc = "Switch Buffer" },
      -- { "/", "<cmd>FzfLua grep<cr>",                        desc = "Grep (root dir)" },
      { "<leader>/",       "<cmd>FzfLua grep<cr>",                  desc = "Grep (root dir)" },
      { "<leader>:",       "<cmd>FzfLua command_history<cr>",       desc = "Command History" },
      { "<leader><space>", "<cmd>FzfLua resume<cr>",                desc = "Smart Open" },
      -- find
      { "<leader>fb",      "<cmd>FzfLua buffers<cr>",               desc = "Buffers" },
      { "<leader>ff",      "<cmd>FzfLua files<cr>",                 desc = "Find Files (root dir)" },
      -- { "<leader>fF", Util.telescope("files", { cwd = false }),             desc = "Find Files (cwd)" },
      { "<leader>fr",      "<cmd>FzfLua oldfiles<cr>",              desc = "Recent" },
      -- git
      { "<leader>gc",      "<cmd>FzfLua git_commits<CR>",           desc = "commits" },
      { "<leader>gs",      "<cmd>FzfLua git_status<CR>",            desc = "status" },
      { "<leader>gB",      "<cmd>FzfLua git_branches<CR>",          desc = "status" },
      -- search
      { '<leader>s"',      "<cmd>FzfLua registers<cr>",             desc = "Registers" },
      { "<leader>sa",      "<cmd>FzfLua autocommands<cr>",          desc = "Auto Commands" },
      -- { "<leader>sb",      "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
      { "<leader>sc",      "<cmd>FzfLua command_history<cr>",       desc = "Command History" },
      { "<leader>sC",      "<cmd>FzfLua commands<cr>",              desc = "Commands" },
      { "<leader>sd",      "<cmd>FzfLua diagnostics_document<cr>",  desc = "Document diagnostics" },
      { "<leader>sD",      "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace diagnostics" },
      { "<leader>sg",      "<cmd>FzfLua live_grep_glob<cr>",        desc = "Grep (root dir)" },
      -- { "<leader>sG", Util.telescope("live_grep", { cwd = false }), desc = "Grep (cwd)" },
      { "<leader>sh",      "<cmd>FzfLua helptags<cr>",              desc = "Help Pages" },
      { "<leader>sH",      "<cmd>FzfLua highlights<cr>",            desc = "Search Highlight Groups" },
      { "<leader>sk",      "<cmd>FzfLua keymaps<cr>",               desc = "Key Maps" },
      { "<leader>sM",      "<cmd>FzfLua manpages<cr>",              desc = "Man Pages" },
      { "<leader>sm",      "<cmd>FzfLua marks<cr>",                 desc = "Jump to Mark" },
      { "<leader>sr",      "<cmd>FzfLua lsp_references<cr>",        desc = "References" },
      -- { "<leader>sR",      "<cmd>Telescope resume<cr>",             desc = "Resume" },
      { "<leader>ca",      vim.lsp.buf.code_action,                 desc = "Code Action" },
      { "<leader>sw",      "<cmd>FzfLua grep_cword<cr>",            desc = "Word (root dir)" },
      -- { "<leader>sW", Util.telescope("grep_string", { cwd = false, word_match = "-w" }), desc = "Word (cwd)" },
      -- {
      --   "<leader>sw",
      --   Util.telescope("grep_string"),
      --   mode = "v",
      --   desc =
      --   "Selection (root dir)"
      -- },
      -- {
      --   "<leader>sW",
      --   Util.telescope("grep_string", { cwd = false }),
      --   mode = "v",
      --   desc =
      --   "Selection (cwd)"
      -- },
      -- -- {
      -- --   "<leader>uC",
      -- --   Util.telescope("colorscheme", { enable_preview = true }),
      -- --   desc =
      -- --   "Colorscheme with preview"
      -- -- },
      -- {
      --   "<leader>ss",
      --   Util.telescope("lsp_document_symbols", {
      --     symbols = {
      --       "Class",
      --       "Function",
      --       "Method",
      --       "Constructor",
      --       "Interface",
      --       "Module",
      --       "Struct",
      --       "Trait",
      --       "Field",
      --       "Property",
      --     },
      --   }),
      --   desc = "Goto Symbol",
      -- },
      -- {
      --   "<leader>sS",
      --   Util.telescope("lsp_dynamic_workspace_symbols", {
      --     symbols = {
      --       "Class",
      --       "Function",
      --       "Method",
      --       "Constructor",
      --       "Interface",
      --       "Module",
      --       "Struct",
      --       "Trait",
      --       "Field",
      --       "Property",
      --     },
      --   }),
      --   desc = "Goto Symbol (Workspace)",
      -- },
    }
  }
}
