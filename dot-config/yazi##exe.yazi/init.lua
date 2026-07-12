local gruvbox = require("yatline-gruvbox"):setup("dark")
local user = os.getenv("USER") or os.getenv("LOGNAME")


-- Plugins
require("full-border"):setup({
	type = ui.Border.PLAIN,
})

require("zoxide"):setup({
	update_db = true,
})

require("session"):setup({
	sync_yanked = true,
})


require("git"):setup{
    order = 1500
}

require("bookmarks"):setup({
	last_directory = { enable = false, persist = false, mode="dir" },
	persist = "all",
	desc_format = "full",
	file_pick_mode = "hover",
	custom_desc_input = false,
	show_keys = true,
	notify = {
		enable = false,
		timeout = 1,
		message = {
			new = "New bookmark '<key>' -> '<folder>'",
			delete = "Deleted bookmark in '<key>'",
			delete_all = "Deleted all bookmarks",
		},
	},
})

require("yatline"):setup({
  theme = gruvbox,

  section_separator = {
    open = "",
    close = "",
  },

  part_separator = {
    open = " ",
    close = " ",
  },

  inverse_separator = {
    open = "",
    close = "",
  },

  padding = {
    inner = 1,
    outer = 0,
  },

  show_background = false,
  display_header_line = false,
  display_status_line = true,

  status_line = {
    left = {
      section_a = {
        {
          type = "string",
          custom = false,
          name = "tab_mode",
        },
      },

      section_b = {
        {
          type = "coloreds",
          custom = false,
          name = "githead",
        },
      },

      section_c = {
        {
          type = "string",
          custom = false,
          name = "hovered_name",
          params = { true, 50, 20, true },
        },
      },
    },

    right = {
      section_c = {
        {
          type = "string",
          custom = false,
          name = "hovered_size",
        },
        {
          type = "coloreds",
          custom = false,
          name = "permissions",
        },
      },

      section_b = {
        {
          type = "string",
          custom = false,
          name = "cursor_position",
        },
      },

      section_a = {
        {
          type = "string",
          custom = false,
          name = "cursor_percentage",
        },
      },
    },
  },
})

-- This must be after require("yatline"):setup(...)
require("yatline-githead"):setup({
    theme = gruvbox
})
