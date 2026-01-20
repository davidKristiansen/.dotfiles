-- lua/utils/picker.lua

vim.pack.add({
    'https://github.com/nvim-tree/nvim-web-devicons',
    "https://github.com/elanmed/fzf-lua-frecency.nvim",
    { src = 'https://github.com/ibhagwan/fzf-lua', version = vim.version.range("*") },
}, { confirm = false })

local default_ignores = {
    "**/.pytest_cache/**",
    "**/__pycache__/**",
    "**/.mypy_cache/**",
    "**/.venv/**",
    "**/venv/**",
    "**/.git/**",
    "**/.idea/**",
    "**/build/**",
    "**/dist/**",
    "**/*.egg-info/**",
}

require("fzf-lua").setup({
    fzf_opts = { ['--layout'] = 'default' },
    winopts = {
        split = "belowright new",
        -- row = 1.0, -- bottom
        -- width = 1.0,
    },
    keymap = {
        fzf = {
            ["ctrl-c"] = "abort",
        },
    },
    files = {
        true, -- uncomment to inherit all the below in your custom config
        -- Pickers inheriting these actions:
        --   files, git_files, git_status, grep, lsp, oldfiles, quickfix, loclist,
        --   tags, btags, args, buffers, tabs, lines, blines
        -- `file_edit_or_qf` opens a single selection or sends multiple selection to quickfix
        -- replace `enter` with `file_edit` to open all files/bufs whether single or multiple
        -- replace `enter` with `file_switch_or_edit` to attempt a switch in current tab first
        ["enter"]  = FzfLua.actions.file_edit_or_qf,
        ["ctrl-s"] = FzfLua.actions.file_split,
        ["ctrl-v"] = FzfLua.actions.file_vsplit,
        ["ctrl-t"] = FzfLua.actions.file_tabedit,
        ["ctrl-q"] = FzfLua.actions.file_sel_to_qf,
        ["alt-Q"]  = FzfLua.actions.file_sel_to_ll,
        ["alt-i"]  = FzfLua.actions.toggle_ignore,
        ["alt-h"]  = FzfLua.actions.toggle_hidden,
        ["alt-f"]  = FzfLua.actions.toggle_follow,
    },
    grep = {
        rg_glob = true,        -- enable glob parsing
        glob_flag = "--iglob", -- case insensitive globs
        glob_separator = "%s%-%-", -- query separator pattern (lua): ' --'
        additional_args = function()
            local args = {}
            for _, g in ipairs(default_ignores) do
                table.insert(args, "--iglob")
                table.insert(args, "!" .. g)
            end
            return args
        end
    },
})
require("fzf-lua").register_ui_select()

local M = {}

local function fzf_lua_picker(items, opts)
    local fzf = require("fzf-lua")
    fzf.fzf_exec(items, {
        prompt = opts.prompt or "> ",
        actions = {
            ["default"] = function(selected)
                if selected and #selected > 0 and opts.on_choice then
                    opts.on_choice(selected[1])
                end
            end,
        },
    })
end

-- Generic pick function that can be configured to use different backends
function M.pick(items, opts)
    opts = opts or {}
    -- For now, we'll hardcode fzf-lua as the backend
    fzf_lua_picker(items, opts)
end

-- LSP functions
function M.lsp_definitions(opts)
    require("fzf-lua").lsp_definitions(opts)
end

function M.lsp_references(opts)
    require("fzf-lua").lsp_references(opts)
end

function M.lsp_implementations(opts)
    require("fzf-lua").lsp_implementations(opts)
end

function M.lsp_type_definitions(opts)
    require("fzf-lua").lsp_type_definitions(opts)
end

function M.diagnostics(opts)
    require("fzf-lua").diagnostics(opts)
end

-- General search functions
function M.files(opts)
    require('fzf-lua-frecency').frecency({
        cwd_only = true,
    })
end

function M.live_grep(opts)
    require("fzf-lua").live_grep(opts)
end

function M.buffers(opts)
    require("fzf-lua").buffers(opts)
end

function M.help_tags(opts)
    require("fzf-lua").help_tags(opts)
end

function M.grep(opts)
    require("fzf-lua").grep(opts)
end

function M.grep_last(opts)
    require("fzf-lua").grep_last(opts)
end

function M.grep_cword(opts)
    require("fzf-lua").grep_cword(opts)
end

function M.grep_cWORD(opts)
    require("fzf-lua").grep_cWORD(opts)
end

function M.grep_visual(opts)
    require("fzf-lua").grep_visual(opts)
end

function M.grep_project(opts)
    require("fzf-lua").grep_project(opts)
end

function M.grep_curbuf(opts)
    require("fzf-lua").grep_curbuf(opts)
end

function M.grep_quickfix(opts)
    require("fzf-lua").grep_quickfix(opts)
end

function M.grep_loclist(opts)
    require("fzf-lua").grep_loclist(opts)
end

function M.lgrep_curbuf(opts)
    require("fzf-lua").lgrep_curbuf(opts)
end

function M.lgrep_quickfix(opts)
    require("fzf-lua").lgrep_quickfix(opts)
end

function M.lgrep_loclist(opts)
    require("fzf-lua").lgrep_loclist(opts)
end

function M.live_grep_resume(opts)
    require("fzf-lua").live_grep_resume(opts)
end

function M.live_grep_glob(opts)
    require("fzf-lua").live_grep_glob(opts)
end

function M.live_grep_native(opts)
    require("fzf-lua").live_grep_native(opts)
end

function M.grep_string(opts)
    require("fzf-lua").grep(opts)
end

function M.oldfiles(opts)
    require("fzf-lua").oldfiles({
        include_current_session = true,
    })
end

function M.resume(opts)
    require("fzf-lua").resume(opts)
end

function M.jumplist(opts)
    require("fzf-lua").jumplist(opts)
end

function M.zoxide(opts)
    opts = opts or {}
    local cmd = "zoxide query -l"
    local fzf = require("fzf-lua")

    -- We use fzf-lua's fzf_exec directly to run the command and handle output
    fzf.fzf_exec(cmd, {
        prompt = opts.prompt or "Zoxide> ",
        actions = {
            ["default"] = function(selected)
                if selected and #selected > 0 then
                    local path = selected[1]
                    -- Strip whitespace if any
                    path = path:match("^%s*(.-)%s*$")
                    vim.cmd("cd " .. vim.fn.fnameescape(path))
                    print("Changed directory to: " .. path)
                end
            end
        },
    })
end

-- For current_buffer_fuzzy_find, fzf-lua doesn't have a direct equivalent.
-- We can use `fzf-lua.lines` and pass the current buffer's lines.
-- Or, for a simpler approach, we can use `live_grep` with a specific buffer.
-- Let's try to replicate the behavior of `current_buffer_fuzzy_find` with `fzf-lua.lines`.
-- `current_buffer_fuzzy_find` is used with `default_text` (CWORD) or without.
-- For now, I'll create a generic `current_buffer_lines` function.
function M.current_buffer_lines(opts)
    opts = opts or {}
    local current_buf = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(current_buf)
    local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
    local formatted_lines = {}

    -- Prepend line numbers to ensure uniqueness and allow direct jumping
    for i, line in ipairs(lines) do
        table.insert(formatted_lines, string.format("%d\t%s", i, line))
    end

    require("fzf-lua").fzf_exec(formatted_lines, {
        prompt = opts.prompt or "Buffer lines> ",
        default_text = opts.default_text,
        fzf_opts = {
            ["--exact"] = "",
            ["--delimiter"] = "\t",
            ["--nth"] = "2..",
            ["--multi"] = ""
        },
        actions = {
            ["default"] = function(selected)
                if selected and #selected > 0 then
                    -- Parse the line number from the selected item "lnum\tcontent"
                    local lnum = tonumber(selected[1]:match("^(%d+)\t"))
                    if lnum then
                        vim.api.nvim_win_set_cursor(0, { lnum, 0 })
                        vim.cmd("normal! zz")
                    end
                end
            end,
            ["ctrl-q"] = {
                fn = function(selected)
                    if not selected or #selected == 0 then return end
                    local qf_list = {}
                    for _, item in ipairs(selected) do
                        local lnum_str, text = item:match("^(%d+)\t(.*)$")
                        if lnum_str then
                            table.insert(qf_list, {
                                filename = filename,
                                lnum = tonumber(lnum_str),
                                text = text,
                                bufnr = current_buf
                            })
                        end
                    end
                    vim.fn.setqflist(qf_list)
                    vim.cmd("copen")
                end,
                prefix = "select-all",
            },
        },
    })
end

return M
