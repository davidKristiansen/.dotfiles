-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

-- lua/plugins/snacks/init.lua
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = function()
    local enabled_snacks = {
      bigfile = true,
      explorer = true,
      indent = true,
      input = true,
      picker = true,
      notifier = true,
      quickfile = true,
      scope = true,
      scroll = true,
      statuscolumn = true,
      words = true,
      dashboard = true,
      scratch = true,
    }

    local snacks_opts = {}

    for name, is_enabled in pairs(enabled_snacks) do
      local ok, module = pcall(require, "plugins.snacks.snack." .. name)
      if ok and type(module) ~= "table" then
        vim.notify("snacks: config for '" .. name .. "' must return a table, got " .. type(module),
          vim.log.levels.WARN
        )
      end
      local config = (type(module) == "table") and module or {}
      snacks_opts[name] = vim.tbl_deep_extend("force", config, {
        enabled = is_enabled,
      })
    end


    return snacks_opts
  end,
  config = function(_, opts)
    require("snacks").setup(opts)
    require("plugins.snacks.keymaps")
  end,
  keys = function()
    return require("plugins.snacks.keymaps")
  end,
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map(
          "<leader>uc")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.indent():map("<leader>ug")
        Snacks.toggle.dim():map("<leader>uD")
      end,
    })
  end,
}
