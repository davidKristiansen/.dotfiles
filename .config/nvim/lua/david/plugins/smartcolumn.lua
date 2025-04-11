return {
	{
		"m4xshen/smartcolumn.nvim",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			disabled_filetypes = { "help", "text", "markdown" },
			colorcolumn = "120",
			scope = "window",
			editorconfig = true,
		},
	},
}
