return {
	{
		"ellisonleao/gruvbox.nvim",
		version = false,
		lazy = false,
		priority = 1000,
		config = function()
			local palette = require("gruvbox").palette
			require("gruvbox").setup({
				undercurl = true,
				underline = true,
				bold = true,
				italic = {
					strings = true,
					comments = true,
					operators = false,
					folds = true,
				},
				strikethrough = true,
				invert_selection = false,
				invert_signs = false,
				invert_tabline = false,
				invert_intend_guides = false,
				inverse = true, -- invert background for search, diffs, statuslines and errors
				contrast = "hard", -- can be "hard", "soft" or empty string
				palette_overrides = {},
				overrides = {
					-- ColorColumn = { bg = "none" },
					SignColumn = { bg = "none" },
					WinBar = { bg = "none" },
					WinBarNC = { bg = "none" },
					TabLineFill = { bg = "none" },
					TabLine = { bg = "none" },
					TabLineSel = { bg = "none" },
					StatusLine = { bg = "none" },
					StatusLineNC = { bg = "none" },
					CursorLine = { bg = "none" },
					Comments = {
						undercurl = true,
					},
				},
				dim_inactive = false,
				transparent_mode = false,
			})
			vim.cmd([[
                set background=dark
                colorscheme gruvbox
                highlight! link StatusLine Normal
                highlight! link StatusLineNC NormalNC
            ]])
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function()
					-- Markdown-specific heading highlights
					vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", { fg = "#fb4934", bg = "", bold = true })
					vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", { fg = "#fabd2f", bg = "", bold = true })
					vim.api.nvim_set_hl(0, "@markup.heading.3.markdown", { fg = "#b8bb26", bg = "", bold = true })
					vim.api.nvim_set_hl(0, "@markup.heading.4.markdown", { fg = "#8ec07c", bg = "", bold = true })
					vim.api.nvim_set_hl(0, "@markup.heading.5.markdown", { fg = "#83a598", bg = "", bold = true })
					vim.api.nvim_set_hl(0, "@markup.heading.6.markdown", { fg = "#d3869b", bg = "", bold = true })

					-- DiffAdd and other Diff groups specifically for Markdown
					vim.api.nvim_set_hl(0, "DiffAdd", { fg = "", bg = "" })
					vim.api.nvim_set_hl(0, "DiffChange", { fg = "", bg = "" })
					vim.api.nvim_set_hl(0, "DiffDelete", { fg = "", bg = "" })
				end,
			})
		end,
	},
	{
		"folke/todo-comments.nvim",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
		keys = {
			{ "<leader>st", "<cmd>TodoTelescope<cr>", desc = "TODO's" },
		},
	},
}
