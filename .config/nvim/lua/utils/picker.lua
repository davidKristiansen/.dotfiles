-- lua/utils/picker.lua
-- Pure library of picker functions backed by fzf-lua.
-- Plugin installation and fzf-lua setup live in plugin/03-fzf-lua.lua.

--- Send selected fzf-lua items to opencode as context files.
--- Designed as an fzf-lua action: fn(selected, opts)
local function opencode_send(selected, opts)
    if not selected or #selected == 0 then return end
    local ok, context = pcall(require, "opencode.context")
    if not ok then
        vim.notify("opencode.nvim not available", vim.log.levels.WARN)
        return
    end

    local core_ok, core = pcall(require, "opencode.core")
    if core_ok then
        core.open({ new_session = false, focus = "input", start_insert = true })
    end

    for _, item in ipairs(selected) do
        local path = require("fzf-lua.path").entry_to_file(item, opts).path
        if path then
            context.add_file(path)
        end
    end
end

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
    require("fzf-lua").diagnostics_document(opts)
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

    fzf.fzf_exec(cmd, {
        prompt = opts.prompt or "Zoxide> ",
        actions = {
            ["default"] = function(selected)
                if selected and #selected > 0 then
                    local path = selected[1]
                    path = path:match("^%s*(.-)%s*$")
                    vim.cmd("cd " .. vim.fn.fnameescape(path))
                    print("Changed directory to: " .. path)
                end
            end
        },
    })
end

function M.current_buffer_lines(opts)
    opts = opts or {}
    local current_buf = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(current_buf)
    local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
    local formatted_lines = {}

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

--- Expose opencode_send as a reusable action for custom picker calls.
--- Usage: require("utils.picker").opencode_send
M.opencode_send = opencode_send

--- Build display labels for sessions: "display_name  /decoded/path"
local function session_display_list(names, detected)
    local h = _G._session_helpers
    table.sort(names, function(a, b) return detected[a].modify_time > detected[b].modify_time end)
    local display = {}
    local lookup = {}
    for _, name in ipairs(names) do
        local display_name = h.get_display_name(name)
        local path = h.session_name_to_path(name)
        local label = display_name .. '  ' .. path
        table.insert(display, label)
        lookup[label] = name
    end
    return display, lookup
end

--- Unified session picker: enter=open, ctrl-s=save, ctrl-x=delete.
--- "Open" writes the current session, changes cwd, and restarts nvim
--- so VimEnter auto-restores the target session cleanly.
function M.sessions()
    local sessions = require('mini.sessions')
    local h = _G._session_helpers
    local detected = sessions.detected
    local names = vim.tbl_keys(detected)
    local display, lookup = session_display_list(names, detected)

    require('fzf-lua').fzf_exec(display, {
        prompt = 'Sessions> ',
        fzf_opts = {
            ['--header'] = 'enter=open │ ctrl-s=save │ ctrl-x=delete',
        },
        actions = {
            ['default'] = function(selected)
                if not (selected and selected[1] and lookup[selected[1]]) then return end
                sessions.read(lookup[selected[1]])
            end,
            ['ctrl-s'] = {
                fn = function()
                    local session_name = h.path_to_session_name(vim.fn.getcwd())
                    if h.has_display_name(session_name) then
                        sessions.write(session_name)
                        return
                    end
                    local default = h.default_display_name()
                    vim.ui.input({ prompt = 'Session name: ', default = default }, function(name)
                        if not name or name == '' then return end
                        h.set_display_name(session_name, name)
                        sessions.write(session_name)
                    end)
                end,
            },
            ['ctrl-x'] = function(selected)
                if selected and selected[1] and lookup[selected[1]] then
                    local session_name = lookup[selected[1]]
                    sessions.delete(session_name, { force = true })
                    if h.remove_display_name then
                        h.remove_display_name(session_name)
                    end
                end
            end,
        },
    })
end

return M
