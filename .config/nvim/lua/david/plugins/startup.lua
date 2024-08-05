return {
{
    'goolord/alpha-nvim',
    event = { "VimEnter" },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    -- init = function()
    --   vim.cmd([[
    --     autocmd User AlphaReady set showtabline=0 | autocmd BufUnload <buffer> set showtabline=2
    --   ]])
    -- end,
    config = function()
      local alpha = require("alpha")
      local dashboard = require "alpha.themes.dashboard"

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
        dashboard.button("g", "  Find word", ":Telescope live_grep <CR>"),
        dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("r", "  Recently used files", ":Telescope oldfiles <CR>"),
        dashboard.button("t", "  Find text", ":Telescope live_grep <CR>"),
        dashboard.button("s", "  Sessions", ":SessionManager load_session <CR>"),
        dashboard.button("c", "  Configuration", ":cd ~/.config/nvim/ <bar>:Telescope find_files <CR>"),
        dashboard.button("q", "󰅚  Quit NVIM", ":qa<CR>"),
      }
      local handle = io.popen('fortune $HOME/.local/share/fortune/fortunes')
      local fortune = handle:read("*a")
      handle:close()
      dashboard.section.footer.val = fortune

      dashboard.section.footer.opts.hl = "Type"
      dashboard.section.header.opts.hl = "Include"
      dashboard.section.buttons.opts.hl = "Keyword"

      dashboard.config.opts.noautocmd = true

      vim.cmd [[autocmd User AlphaReady echo 'ready']]

      alpha.setup(dashboard.config)
    end
  }
}
