-- SPDX-License-Identifier: MIT

-- Trim trailing whitespace
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

-- Prevent Neovim from adding a trailing newline to the pack lockfile.
-- vim.pack writes the file without one; fixeol adds it back, causing a
-- perpetual one-line diff.
vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "nvim-pack-lock.json",
    callback = function()
        vim.bo.fixeol = false
    end,
})

-- Auto-create directories on save + stable backupext
vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("auto_create_dir", { clear = true }),
    callback = function(ev)
        local file = vim.loop.fs_realpath(ev.match) or ev.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
        local backup = vim.fn.fnamemodify(file, ":p:~:h"):gsub("[/\\]", "%%")
        vim.go.backupext = backup
    end,
})

-- Restore last position
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local ok, mark = pcall(vim.api.nvim_buf_get_mark, 0, '"')
        if ok and mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Hybrid numbers
--
-- Treat certain buffers as "special" (never toggle numbers there)
local function is_special()
    local bt = vim.bo.buftype
    if bt == "nofile" or bt == "terminal" then return true end
    -- respect per-buffer opt-out flag
    if vim.b.hybrid_numbers_disable then return true end
    -- treat Fyler as special by filetype
    return vim.bo.filetype == "Fyler"
end

-- Hard rule for Fyler: kill signs + numbers and keep gitsigns away
vim.api.nvim_create_autocmd("FileType", {
    pattern = "Fyler",
    callback = function()
        vim.b.hybrid_numbers_disable = true -- guard both autocmds below
        vim.b.gitsigns_disable = true   -- prevent gitsigns attach
        vim.opt_local.signcolumn = "no"
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
    end,
})

-- When entering/focusing/leaving insert, etc: toggle hybrid numbers
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter", "TermOpen" }, {
    group = vim.api.nvim_create_augroup("hybrid_numbers_on", { clear = true }),
    callback = function()
        if is_special() then
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            return
        end
        vim.opt_local.number = true
        vim.opt_local.relativenumber = (vim.api.nvim_get_mode().mode ~= "i")
    end,
})

vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave", "TermClose" }, {
    group = vim.api.nvim_create_augroup("hybrid_numbers_off", { clear = true }),
    callback = function()
        if is_special() then return end
        vim.opt_local.number = true
        vim.opt_local.relativenumber = false
    end,
})

-- Yank flash (built-in, replaces tiny-glimmer.nvim)
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 200, on_visual = true })
  end,
})

-- Dynamic colorcolumn — only shown when a line exceeds the limit
--
-- The column width is read from the attached LSP server (e.g. ruff
-- lineLength) and falls back to vim.b.colorcolumn_limit or 88.
local cc_group = vim.api.nvim_create_augroup("dynamic_colorcolumn", { clear = true })

--- Resolve the line-length limit for the current buffer.
--- Priority: buffer-local override > LSP server setting > 88.
local function get_line_limit(bufnr)
    bufnr = bufnr or 0
    -- Buffer-local override (user can `:let b:colorcolumn_limit = 120`)
    local override = vim.b[bufnr].colorcolumn_limit
    if override then return override end

    -- Query attached LSP clients for a line-length setting
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    for _, client in ipairs(clients) do
        local s = client.settings or {}
        -- ruff: settings.lineLength
        if s.lineLength then return s.lineLength end
        -- ruff (nested): settings.ruff.lineLength
        if s.ruff and s.ruff.lineLength then return s.ruff.lineLength end
        -- pylsp / pycodestyle: settings.pylsp.plugins.pycodestyle.maxLineLength
        local pylsp = s.pylsp
        if pylsp and pylsp.plugins and pylsp.plugins.pycodestyle then
            local ml = pylsp.plugins.pycodestyle.maxLineLength
            if ml then return ml end
        end
        -- rust_analyzer doesn't expose a line width, but rustfmt uses
        -- max_width; not typically available via LSP settings.
    end

    return 88
end

--- Check visible lines and toggle colorcolumn accordingly.
local function update_colorcolumn()
    if vim.bo.buftype ~= "" then return end -- skip special buffers
    local limit = get_line_limit(0)
    local top = vim.fn.line("w0")
    local bot = vim.fn.line("w$")
    local exceeded = false
    for lnum = top, bot do
        local line = vim.fn.getline(lnum)
        if vim.fn.strdisplaywidth(line) > limit then
            exceeded = true
            break
        end
    end
    local want = exceeded and tostring(limit) or ""
    if vim.wo.colorcolumn ~= want then
        vim.wo.colorcolumn = want
    end
end

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI", "WinScrolled" }, {
    group = cc_group,
    callback = update_colorcolumn,
})

-- Re-evaluate when an LSP server attaches (line limit may change)
vim.api.nvim_create_autocmd("LspAttach", {
    group = cc_group,
    callback = function()
        -- Small delay so the server's settings are fully populated
        vim.defer_fn(update_colorcolumn, 100)
    end,
})

-- UV workspace setup
vim.api.nvim_create_autocmd("DirChanged", {
    group = vim.api.nvim_create_augroup("uv_workspace", { clear = true }),
    callback = function()
        local cwd = vim.fn.getcwd()
        local pyproject = cwd .. "/pyproject.toml"
        local venv = cwd .. "/.venv"

        -- Check if pyproject.toml exists (uv workspace indicator)
        if vim.fn.filereadable(pyproject) == 1 then
            -- Run uv sync in background if .venv doesn't exist
            if vim.fn.isdirectory(venv) == 0 then
                vim.notify("UV workspace detected, running uv sync...", vim.log.levels.INFO)
                vim.fn.jobstart({ "uv", "sync" }, {
                    cwd = cwd,
                    on_exit = function(_, exit_code)
                        if exit_code == 0 then
                            vim.notify("uv sync completed successfully", vim.log.levels.INFO)
                            vim.env.VIRTUAL_ENV = venv
                            vim.env.PATH = venv .. "/bin:" .. vim.env.PATH
                        else
                            vim.notify("uv sync failed with exit code: " .. exit_code, vim.log.levels.ERROR)
                        end
                    end,
                })
            else
                -- .venv exists, just activate it
                vim.env.VIRTUAL_ENV = venv
                vim.env.PATH = venv .. "/bin:" .. vim.env.PATH
            end
        end
    end,
})
