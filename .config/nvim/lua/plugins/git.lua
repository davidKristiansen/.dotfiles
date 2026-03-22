-- SPDX-License-Identifier: MIT
-- lua/plugins/git.lua

vim.pack.add({
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/MunifTanjim/nui.nvim" },

    { src = "https://github.com/tpope/vim-fugitive" },

    { src = "https://github.com/lewis6991/gitsigns.nvim" },
    { src = "https://github.com/NeogitOrg/neogit" },
    { src = "https://github.com/esmuellert/codediff.nvim" },
    { src = "https://github.com/kdheepak/lazygit.nvim" },
    { src = "https://github.com/kokusenz/deltaview.nvim" },
    { src = "https://github.com/sindrets/diffview.nvim" },
    { src = "https://github.com/kokusenz/delta.lua" },
    -- picker backend
    { src = "https://github.com/ibhagwan/fzf-lua" },
}, { confirm = false })

require("codediff").setup({
    keymaps = {
        view = {
            quit = "q",                    -- Close diff tab
            toggle_explorer = "<leader>b", -- Toggle explorer visibility (explorer mode only)
            next_hunk = "]h",              -- Jump to next change
            prev_hunk = "[h",              -- Jump to previous change
        },
        explorer = {
            select = "<CR>", -- Open diff for selected file
            hover = "K",     -- Show file diff preview
            refresh = "R",   -- Refresh git status
        },
    },
})

---------------------------------------------------------------------------
-- DRY helpers
---------------------------------------------------------------------------

-- Generic ref picker using the utils.picker module
local function pick_ref(opts)
    opts = opts or {}
    local refs = vim.fn.systemlist(
        "git for-each-ref --format='%(refname:short)' refs/heads refs/remotes refs/tags 2>/dev/null"
    )
    if vim.v.shell_error ~= 0 or #refs == 0 then
        vim.notify("No git refs found", vim.log.levels.WARN)
        return
    end

    require("utils.picker").pick(refs, {
        prompt = opts.prompt or "Git refs> ",
        on_choice = opts.on_choice, -- Pass the on_choice directly
    })
end

-- Branch management
local function create_branch()
    vim.ui.input({ prompt = "New branch name: " }, function(name)
        if not name or name == "" then
            vim.notify("Branch creation cancelled", vim.log.levels.INFO)
            return
        end
        local out = vim.fn.system("git checkout -b " .. vim.fn.shellescape(name))
        if vim.v.shell_error == 0 then
            vim.notify("Switched to new branch '" .. name .. "'", vim.log.levels.INFO)
            vim.cmd("redraw!")
        else
            vim.notify(out, vim.log.levels.ERROR, { title = "git checkout -b failed" })
        end
    end)
end

local function pr_view()
    pick_ref({
        prompt = "PR View (vs Base)> ",
        on_choice = function(base)
            if base then
                vim.cmd("DiffviewOpen " .. base .. "...")
            end
        end,
    })
end

local function pr_history()
    pick_ref({
        prompt = "PR History (since Base)> ",
        on_choice = function(base)
            if base then
                -- Shows all commits on current branch that aren't in base
                vim.cmd("DiffviewFileHistory " .. base .. "..HEAD")
            end
        end,
    })
end

local function toggle_diffview()
    local lib = require("diffview.lib")
    local view = lib.get_current_view()
    if view then
        vim.cmd("DiffviewClose")
    else
        vim.cmd("DiffviewOpen")
    end
end

require("deltaview").setup({
    use_nerdfonts = true
})

local actions = require("diffview.actions")
require("diffview").setup({
    enhanced_diff_hl = true,
    keymaps = {
        view = {
            ["[f"] = actions.select_prev_entry,
            ["]f"] = actions.select_next_entry,
        },
        file_panel = {
            ["j"] = actions.next_entry,
            ["k"] = actions.prev_entry,
            ["<CR>"] = actions.select_entry,
            ["[f"] = actions.select_prev_entry,
            ["]f"] = actions.select_next_entry,
        },
    },
})

-- Neogit setup with diffview integration
require("neogit").setup({
    kind = "tab",
    integrations = {
        diffview = true
    }
})

-- Gitsigns setup
require("gitsigns").setup({
    signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = " " },
        topdelete = { text = "▔" },
        changedelete = { text = "▎" },
        untracked = { text = "┆" },
    },
    on_attach = function(bufnr)
        local gitsigns = package.loaded.gitsigns
        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end
    end,
})
-- Global keymaps
local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true, desc = desc })
end

-- Diffview
map("n", "<leader>gv", toggle_diffview, "Toggle Diffview")
map("n", "<leader>gp", pr_view, "PR View (Cumulative)")
map("n", "<leader>gl", pr_history, "PR History (Commit-by-Commit)")
map("n", "<leader>gf", "<cmd>DiffviewFileHistory %<CR>", "Diffview File History (Buffer)")
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<CR>", "Diffview File History (Project)")

-- Gitsigns & Git Management
map("n", "<leader>gh", function() require("gitsigns").preview_hunk() end, "Preview hunk")
map("n", "<leader>gr", function() require("gitsigns").reset_hunk() end, "Reset hunk")
map("n", "<leader>gR", function() require("gitsigns").reset_buffer() end, "Reset buffer")
map("n", "<leader>gs", function() require("gitsigns").stage_hunk() end, "Stage hunk")
map("n", "<leader>gS", function() require("gitsigns").stage_buffer() end, "Stage buffer")
map("n", "<leader>gu", function() require("gitsigns").undo_stage_hunk() end, "Undo stage hunk")
map("n", "<leader>gt", function() require("fzf-lua").git_status() end, "Git status")
map("n", "<leader>gb", function() require("fzf-lua").git_branches() end, "Git checkout branch")
map("n", "<leader>gB", create_branch, "Create new branch")
map("n", "<leader>gd", ":CodeDiff<CR>", "Open VSCode-style Diff")
map("n", "<leader>gD", function()
    pick_ref({
        prompt = "Diff vs Ref (Merge-Base)> ",
        on_choice = function(choice)
            if choice then
                vim.cmd("DiffviewOpen " .. choice .. "...")
            end
        end,
    })
end, "Diff vs Ref (Merge-Base)")

-- Navigation
map("n", "]h", function()
    if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
    else
        require("gitsigns").nav_hunk("next")
    end
end, "Next hunk")

map("n", "[h", function()
    if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
    else
        require("gitsigns").nav_hunk("prev")
    end
end, "Prev hunk")

-- Neogit status
map("n", "<leader>gn", function() require("neogit").open({ kind = "tab" }) end, "Neogit status")
-- map("n", "<leader>gc", function() require("neogit").open({ "commit" }) end, "Commit") -- Replaced by mini.git
map("n", "<leader>gP", function() require("neogit").open({ "push" }) end, "Push")
map("n", "<leader>gU", function() require("neogit").open({ "pull" }) end, "Pull")
map("n", "<leader>gm", function() require("neogit").open({ "merge" }) end, "Merge")

-- Lazygit
map("n", "<leader>gg", ":LazyGit<CR>", "Open LazyGit")
