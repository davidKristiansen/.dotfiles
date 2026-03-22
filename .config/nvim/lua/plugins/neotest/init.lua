-- SPDX-License-Identifier: MIT


vim.pack.add({
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-neotest/nvim-nio" },
    { src = "https://github.com/nvim-neotest/neotest" },
    { src = "https://github.com/nvim-neotest/neotest-python" },
    { src = "https://github.com/alfaix/neotest-gtest" },
    { src = "https://github.com/antoinemadec/FixCursorHold.nvim" },
}, { confirm = false })

local test_base = "/Project/50.Testing/30.IntegrationTest"
-- Only Python files go through neotest-python
require("neotest").setup({
    discovery = {
        filter_dir = function(name)
            if name:match("^%d%d%-%d%d%-%d%d_") then return false end
            return not ({
                [".git"] = true, [".venv"] = true, [".venv.devcontainer"] = true,
                ["99.Artifacts"] = true, ["bazel-bin"] = true, ["bazel-out"] = true,
                ["bazel-testlogs"] = true, ["bazel-Project"] = true,
                node_modules = true, __pycache__ = true,
            })[name]
        end,
    },
    adapters = {
        (function()
            local ok, gtest = pcall(require, "neotest-gtest")
            if ok then
                return gtest.setup({
                    is_test_file = function(p)
                        if p:find("/build/") then return false end
                    end
                })
            end
        end)(),
        require("neotest-python")({
            python = "/Project/.venv.devcontainer/bin/python3",
            pytest_discover_instances = true,
            args = { "-s", "-v", "-p", "no:macpyver", "-p", "no:macpyver_native" },
            is_test_file = function(p)
                if p:find("/build/") then return false end
                if p:find("/99%.Artifacts/") then return false end
                return p:match("/test_.*%.py$") or p:sub(-8) == "_test.py" or p:sub(-7) == "test_.py"
            end,
        }),
    },
    status = { virtual_text = false, signs = true },
    output = { open_on_run = true },
    output_panel = { open = "botright split | resize 15" },
    signs = {
        enabled = true,
        passed = "✓",
        failed = "✗",
        running = "●",
        skipped = "○",
    },
    strategies = {
        integrated = {
            width = 180,
            height = 40,
        },
    },
})


local neotest = require("neotest")
local map = vim.keymap.set

-- Summary panel
map("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = "Neotest: Toggle summary" })

-- Run nearest test (file-aware)
map("n", "<leader>tr", function() neotest.run.run() end, { desc = "Neotest: Run nearest" })

-- Run current file
map("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Neotest: Run file" })

-- Run entire project (cwd)
map("n", "<leader>ta", function() neotest.run.run(vim.loop.cwd()) end, { desc = "Neotest: Run all (cwd)" })

-- Jump to next/prev failed
map("n", "<leader>tn", function() neotest.jump.next({ status = "failed" }) end, { desc = "Neotest: Next failed" })
map("n", "<leader>tp", function() neotest.jump.prev({ status = "failed" }) end, { desc = "Neotest: Prev failed" })

-- Run all marked in summary
map("n", "<leader>tm", function() neotest.summary.run_marked() end, { desc = "Neotest: Run marked" })

-- Open output panel (full log)
map("n", "<leader>to", function() neotest.output_panel.open() end, { desc = "Neotest: Open output panel" })

-- Auto-open output panel when running tests
vim.api.nvim_create_autocmd("User", {
    pattern = "NeotestRunStarted",
    callback = function()
        neotest.output_panel.open()
    end,
})

require("plugins.neotest.auto")
