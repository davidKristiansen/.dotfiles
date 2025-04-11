return {
	"rachartier/tiny-glimmer.nvim",
	event = "VeryLazy",
	opts = {
		-- your configuration
		disable_warnings = true,
		animations = {
			fade = {
				from_color = "#FF757F",
			},
			reverse_fade = {
				from_color = "#4FD6BE",
			},
		},
		presets = {
			pulsar = {
				enabled = false,
			},
		},
		overwrite = {
			search = {
				enabled = false,
			},
			paste = {
				enabled = true,
			},
			undo = {
				enabled = true,
			},
			redo = {
				enabled = true,
			},
		},
	},
}
