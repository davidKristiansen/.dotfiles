-- SPDX-License-Identifier: MIT
-- Git worktree workspace management. Self-contained module (no external plugin);
-- setup() only registers :Worktree + <leader>w* keymaps whose handlers require
-- fzf-lua lazily, so it is cheap to set up eagerly.
require('utils.worktree').setup()
