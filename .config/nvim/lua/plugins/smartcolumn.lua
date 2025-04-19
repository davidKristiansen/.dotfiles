-- SPDX-License-Identifier: MIT
-- Copyright David Kristiansen

return {
	{
		"m4xshen/smartcolumn.nvim",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			disabled_filetypes = { "help", "text", "markdown", "codecompanion" },
			colorcolumn = "120",
			scope = "window",
			editorconfig = true,
		},
	},
}
