return {
  {
    "smjonas/inc-rename.nvim",
    opts = {},
    cmd = {"IncRename"},
    keys = {
      -- {
      --   "<leader>rn",
      --   ":IncRename",
      --   desc = "rename"
      -- },
    },
    init = function()
      vim.keymap.set("n", "<leader>rn", function()
        return ":IncRename " .. vim.fn.expand("<cword>")
      end, { expr = true })
    end

  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      presets = {
        inc_rename = true,
      },
      messages = {
        enabled = false,
      },
      cmdline = {
        enabled = true,
        view = "cmdline", -- ensures bottom-aligned cmdline
        format = {
          IncRename = {
            view = "inc_rename_popup", -- override only this case
          },
        },
      },
      views = {
        inc_rename_popup = {
          backend = "popup",
          relative = "cursor",
          position = {
            row = 1,
            col = 0,
          },
          size = {
            width = 40,
            height = "auto",
          },
          border = {
            style = "rounded",
          },
          win_options = {
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
          },
        },
      },
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    }
  }
}
