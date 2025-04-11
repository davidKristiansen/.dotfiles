return {
	{
		"olimorris/codecompanion.nvim",
		cmd = { "CodeCompanionChat" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			strategies = {
				chat = { adapter = "openai" },
				inline = {
					keymaps = {
						accept_change = {
							modes = { n = "<leader>aa" },
							description = "Accept the suggested change",
						},
						reject_change = {
							modes = { n = "<leader>aA" },
							description = "Reject the suggested change",
						},
					},
				},
			},
			adapters = {
				openai = function()
					return require("codecompanion.adapters").extend("openai", {
						env = {
							api_key = vim.env["OPENAI_API_KEY"],
						},
						schema = {
							model = {
								default = function()
									return "gpt-4o"
								end,
							},
						},
					})
				end,
			},
		},
		keys = {
			{ "<leader>ac", "<cmd>CodeCompanionChat toggle<cr>", desc = "Toggle Chat" },
			{ "<leader>ar", "<cmd>CodeCompanionReview<cr>", desc = "Review" },
			{ "<leader>af", "<cmd>CodeCompanionActions<cr>", desc = "Actions" },
			{ "<leader>aw", "<cmd>CodeCompanionWorkspace<CR>", desc = "Workspaces" },
		},
	},
}
