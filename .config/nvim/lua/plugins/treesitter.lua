-- SPDX-License-Identifier: MIT
vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
}, { confirm = false })

-- Enable treesitter highlighting and indent for all buffers with a parser
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
    callback = function(ev)
        if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})

require 'nvim-treesitter'.setup {
    -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
    install_dir = vim.fn.stdpath('data') .. '/site'
}

require 'nvim-treesitter'.install {
    'rust',
    'javascript',
    'zig',
    'python',
    'lua',
    'cpp',
    'c',
}

-- Textobjects: select
require("nvim-treesitter-textobjects").setup({
    select = { lookahead = true },
    move = { set_jumps = true },
})

local select_fn = function(capture)
    return function()
        require("nvim-treesitter-textobjects.select").select_textobject(capture, "textobjects")
    end
end

vim.keymap.set({ "x", "o" }, "af", select_fn("@function.outer"))
vim.keymap.set({ "x", "o" }, "if", select_fn("@function.inner"))
vim.keymap.set({ "x", "o" }, "ac", select_fn("@class.outer"))
vim.keymap.set({ "x", "o" }, "ic", select_fn("@class.inner"))
vim.keymap.set({ "x", "o" }, "al", select_fn("@loop.outer"))
vim.keymap.set({ "x", "o" }, "il", select_fn("@loop.inner"))
vim.keymap.set({ "x", "o" }, "ib", select_fn("@block.inner"))
vim.keymap.set({ "x", "o" }, "ab", select_fn("@block.outer"))
vim.keymap.set({ "x", "o" }, "as", select_fn("@statement.outer"))
vim.keymap.set({ "x", "o" }, "ad", select_fn("@conditional.outer"))
vim.keymap.set({ "x", "o" }, "id", select_fn("@conditional.inner"))
vim.keymap.set({ "x", "o" }, "a/", select_fn("@comment.outer"))

-- Textobjects: move
local move = require("nvim-treesitter-textobjects.move")

vim.keymap.set({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer", "textobjects") end)
vim.keymap.set({ "n", "x", "o" }, "]c", function() move.goto_next_start("@class.outer", "textobjects") end)
vim.keymap.set({ "n", "x", "o" }, "]F", function() move.goto_next_end("@function.outer", "textobjects") end)
vim.keymap.set({ "n", "x", "o" }, "]C", function() move.goto_next_end("@class.outer", "textobjects") end)
vim.keymap.set({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end)
vim.keymap.set({ "n", "x", "o" }, "[c", function() move.goto_previous_start("@class.outer", "textobjects") end)
vim.keymap.set({ "n", "x", "o" }, "[F", function() move.goto_previous_end("@function.outer", "textobjects") end)
vim.keymap.set({ "n", "x", "o" }, "[C", function() move.goto_previous_end("@class.outer", "textobjects") end)

