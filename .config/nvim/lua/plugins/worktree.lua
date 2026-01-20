-- Git worktree workspace management
local M = {}

-- Helpers
local function sanitize_branch(branch) return branch:gsub("[/:]", "-") end

local function get_worktree_base()
    local bare_parent = vim.fn.fnamemodify(vim.fn.getcwd(), ":h") .. "/.bare"
    if vim.fn.isdirectory(bare_parent) == 1 then
        return vim.fn.fnamemodify(vim.fn.getcwd(), ":h") -- Use parent dir (bare repo sibling)
    else
        -- Fallback to ~/.local/share/nvim/worktrees/<sanitized-git-root>
        local git_root = vim.trim(vim.fn.system("git rev-parse --show-toplevel"))
        if vim.v.shell_error ~= 0 then return nil end
        local sanitized = git_root:gsub("/", "##slash##")
        return vim.fn.stdpath("data") .. "/worktrees/" .. sanitized
    end
end

local function normalize_path(path)
    if path:match("^[/.]") then return path end
    local base = get_worktree_base()
    if not base then return nil end
    return base .. "/" .. path
end

local function shell(cmd) return vim.fn.system(cmd), vim.v.shell_error == 0 end
local function notify(msg, level) vim.notify(msg, level or vim.log.levels.INFO) end

local function get_branches()
    local output = vim.fn.systemlist("git branch -a --format='%(refname:short)'")
    if vim.v.shell_error ~= 0 then return nil end
    local branches, seen = {}, {}
    for _, b in ipairs(output) do
        if not b:match("HEAD") and not seen[b] then
            branches[#branches + 1], seen[b] = b, true
        end
    end
    return branches
end

local function get_unique_branch_names()
    local all_branches = get_branches()
    if not all_branches then return nil end
    local unique, seen = {}, {}
    for _, b in ipairs(all_branches) do
        -- Strip origin/ prefix to get base name
        local base = b:match("^origin/(.+)") or b
        if not seen[base] then
            unique[#unique + 1], seen[base] = base, true
        end
    end
    return unique
end

local function get_worktrees()
    vim.fn.system("git worktree prune")
    local output = vim.fn.system("git worktree list --porcelain")
    if vim.v.shell_error ~= 0 then return nil end

    local worktrees, current, cwd = {}, {}, vim.fn.getcwd()
    for line in output:gmatch("[^\r\n]+") do
        if line:match("^worktree ") then
            if current.path and not vim.fn.fnamemodify(current.path, ":t"):match("^%.") and vim.fn.isdirectory(current.path) == 1 then
                current.is_current = current.path == cwd
                worktrees[#worktrees + 1] = current
            end
            current = { path = line:match("^worktree (.+)"), branch = "(detached)" }
        elseif line:match("^branch ") then
            current.branch = line:match("refs/heads/(.+)")
        end
    end
    if current.path and not vim.fn.fnamemodify(current.path, ":t"):match("^%.") and vim.fn.isdirectory(current.path) == 1 then
        current.is_current = current.path == cwd
        worktrees[#worktrees + 1] = current
    end
    return worktrees
end

local function sync_tmux(path)
    if not vim.env.TMUX then return end
    -- Only sync panes that are at a shell prompt (pane_current_command is a shell)
    local shells = { bash = true, zsh = true, fish = true, sh = true }
    local panes = vim.fn.systemlist("tmux list-panes -F '#{pane_id}:#{pane_current_command}'")
    local current = vim.fn.system("tmux display-message -p '#{pane_id}'"):gsub("%s+", "")

    for _, pane_info in ipairs(panes) do
        local pane_id, cmd = pane_info:match("^(%%[%d]+):(.+)$")
        if pane_id and pane_id ~= current and shells[cmd] then
            vim.fn.system(("tmux send-keys -t %s 'cd %s' C-m"):format(pane_id, path:gsub("'", "'\\''")))
        end
    end
end

local function switch_to_worktree(path)
    local modified = vim.tbl_filter(function(b) return vim.bo[b].modified and vim.api.nvim_buf_get_name(b) ~= "" end,
        vim.api.nvim_list_bufs())
    if #modified > 0 then
        notify("Unsaved changes. Save or discard first.", vim.log.levels.WARN)
        return false
    end
    vim.cmd("cd " .. vim.fn.fnameescape(path))
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
            local name = vim.api.nvim_buf_get_name(buf)
            if name ~= "" and vim.fn.filereadable(name) == 0 then vim.api.nvim_buf_delete(buf, {}) end
        end
    end
    vim.cmd("checktime | edit .")
    sync_tmux(path)
    return true
end

local function create_and_switch(cmd, path, msg)
    local output, ok = shell(cmd)
    if ok then
        local abs = vim.fn.fnamemodify(path, ":p")
        if switch_to_worktree(abs) then notify(msg .. abs) end
    else
        notify("Failed:\n" .. output, vim.log.levels.ERROR)
    end
end

function M.switch()
    local branches = get_unique_branch_names()
    local worktrees = get_worktrees()
    if not branches or not worktrees then return notify("Git operation failed", vim.log.levels.ERROR) end

    local wt_map = {}
    for _, wt in ipairs(worktrees) do wt_map[wt.branch] = wt end

    -- Calculate max branch width for alignment
    local max_w = 0
    for _, b in ipairs(branches) do max_w = math.max(max_w, #b) end

    local home, cwd = vim.env.HOME, vim.fn.getcwd()
    local items = {}

    -- Add existing worktrees first
    for _, wt in ipairs(worktrees) do
        local rel = wt.path:sub(1, #home) == home and ("~" .. wt.path:sub(#home + 1)) or wt.path
        local marker = wt.is_current and "[current] " or "          "
        local padded_branch = wt.branch .. string.rep(" ", max_w - #wt.branch)
        items[#items + 1] = { branch = wt.branch, path = wt.path, exists = true, display = marker .. padded_branch .. "  " .. rel }
    end
    for _, b in ipairs(branches) do
        if not wt_map[b] then
            local padded_branch = b .. string.rep(" ", max_w - #b)
            items[#items + 1] = { branch = b, exists = false, display = "          " .. padded_branch .. "  (no worktree)" }
        end
    end

    require("fzf-lua").fzf_exec(vim.tbl_map(function(i) return i.display end, items), {
        prompt = "Switch worktree> ",
        actions = {
            ["default"] = function(sel)
                if not sel or #sel == 0 then return end
                local item = vim.tbl_filter(function(i) return i.display == sel[1] end, items)[1]
                if not item then return end

                if not item.exists then
                    vim.ui.input({ prompt = "Worktree directory: ", default = sanitize_branch(item.branch) },
                        function(dir)
                            if not dir or dir == "" then return end
                            local path = normalize_path(dir)
                            if not path then return notify("Failed to determine worktree base", vim.log.levels.ERROR) end
                            -- Prefer local branch if exists, otherwise use origin/branch
                            local target = item.branch
                            local check_local = vim.fn.system("git rev-parse --verify " .. vim.fn.shellescape(target) .. " 2>/dev/null")
                            if vim.v.shell_error ~= 0 then
                                -- Local doesn't exist, try origin/
                                target = "origin/" .. item.branch
                            end
                            create_and_switch(
                            ("git worktree add %s %s"):format(vim.fn.shellescape(path), vim.fn.shellescape(target)),
                                path, "Created and switched: ")
                        end)
                elseif item.path ~= cwd then
                    if switch_to_worktree(item.path) then notify("Switched to: " .. item.path) end
                end
            end,
        },
    })
end

function M.create()
    vim.ui.input({ prompt = "Branch name: " }, function(branch)
        if not branch or branch == "" then return end
        vim.fn.system("git rev-parse --verify " .. vim.fn.shellescape(branch) .. " 2>/dev/null")
        if vim.v.shell_error == 0 then
            return notify("Branch '" .. branch .. "' already exists", vim.log.levels.ERROR)
        end

        vim.ui.input({ prompt = "Worktree directory: ", default = sanitize_branch(branch) }, function(dir)
            if not dir or dir == "" then return end
            local path = normalize_path(dir)
            if not path then return notify("Failed to determine worktree base", vim.log.levels.ERROR) end
            local branches = get_branches()
            if not branches then return notify("Failed to list branches", vim.log.levels.ERROR) end

            -- Sort: origin/default first
            local default_br = vim.trim(vim.fn.system(
            "git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'"))
            if default_br == "" then default_br = "main" end
            table.sort(branches, function(a, b)
                local rd = "origin/" .. default_br
                if a == rd then return true end; if b == rd then return false end
                if a == default_br then return true end; if b == default_br then return false end
                local ar, br = a:match("^origin/"), b:match("^origin/")
                if ar and not br then return true end; if br and not ar then return false end
                return a < b
            end)

            -- Format branch names with type indicator
            local max_w = 0
            for _, b in ipairs(branches) do max_w = math.max(max_w, #b) end
            local display_items = vim.tbl_map(function(b)
                local type_label = b:match("^origin/") and "(remote)" or "(local)"
                local padded_branch = b .. string.rep(" ", max_w - #b)
                return padded_branch .. "  " .. type_label
            end, branches)

            require("fzf-lua").fzf_exec(display_items, {
                prompt = "Base branch> ",
                actions = {
                    ["default"] = function(sel)
                        if not sel or #sel == 0 then return end
                        -- Extract branch name from display (remove type label)
                        local base_branch = sel[1]:match("^(%S+)")
                        local cmd = ("git worktree add -b %s %s %s"):format(vim.fn.shellescape(branch),
                            vim.fn.shellescape(path), vim.fn.shellescape(base_branch))
                        local output, ok = shell(cmd)
                        if ok then
                            notify("Created branch: " .. branch)
                            vim.defer_fn(function()
                                vim.ui.select({ "Yes", "No" }, { prompt = "Switch to new worktree?" }, function(c)
                                    if c == "Yes" then create_and_switch("true", path, "Switched to: ") end
                                end)
                            end, 50)
                        else
                            notify("Failed:\n" .. output, vim.log.levels.ERROR)
                        end
                    end,
                },
            })
        end)
    end)
end

function M.delete()
    local worktrees = get_worktrees()
    if not worktrees then return notify("Git operation failed", vim.log.levels.ERROR) end

    local cwd = vim.fn.getcwd()
    worktrees = vim.tbl_filter(function(wt) return wt.path ~= cwd end, worktrees)
    if #worktrees == 0 then return notify("No other worktrees to delete") end

    -- Calculate max branch width for alignment
    local max_w = 0
    for _, wt in ipairs(worktrees) do max_w = math.max(max_w, #wt.branch) end
    
    local home = vim.env.HOME
    local items = vim.tbl_map(function(wt)
        local rel = wt.path:sub(1, #home) == home and ("~" .. wt.path:sub(#home + 1)) or wt.path
        local padded_branch = wt.branch .. string.rep(" ", max_w - #wt.branch)
        return padded_branch .. "  " .. rel
    end, worktrees)

    require("fzf-lua").fzf_exec(items, {
        prompt = "Delete worktree> ",
        actions = {
            ["default"] = function(sel)
                if not sel or #sel == 0 then return end
                local idx = vim.fn.index(items, sel[1]) + 1
                local wt = worktrees[idx]
                vim.defer_fn(function()
                    vim.ui.select({ "Yes", "No" }, { prompt = "Delete '" .. wt.branch .. "'?" }, function(c)
                        if c ~= "Yes" then return end
                        local _, ok = shell("git worktree remove " .. vim.fn.shellescape(wt.path))
                        if not ok then _, ok = shell("git worktree remove --force " .. vim.fn.shellescape(wt.path)) end
                        if ok then
                            notify("Deleted worktree: " .. wt.path)
                            vim.defer_fn(function()
                                vim.ui.select({ "Yes", "No" }, { prompt = "Delete branch '" .. wt.branch .. "'?" },
                                    function(d)
                                        if d == "Yes" then
                                            local out, bok = shell("git branch -D " .. vim.fn.shellescape(wt.branch))
                                            notify(bok and ("Deleted branch: " .. wt.branch) or ("Failed:\n" .. out),
                                                bok and vim.log.levels.INFO or vim.log.levels.WARN)
                                        end
                                    end)
                            end, 50)
                        else
                            notify("Failed to delete worktree", vim.log.levels.ERROR)
                        end
                    end)
                end, 50)
            end,
        },
    })
end

function M.prune()
    vim.fn.system("git worktree prune"); notify("Pruned stale worktree entries")
end

function M.setup()
    local cmds = { switch = M.switch, s = M.switch, create = M.create, c = M.create, delete = M.delete, d = M.delete, prune =
    M.prune, p = M.prune }
    vim.api.nvim_create_user_command("Worktree", function(opts)
        local fn = cmds[opts.fargs[1]]
        if fn then fn() else notify("Usage: :Worktree {switch|create|delete|prune}", vim.log.levels.WARN) end
    end, {
        nargs = "+",
        complete = function(_, line)
            local a = vim.split(line, "%s+"); return #a == 2 and
            vim.tbl_filter(function(c) return vim.startswith(c, a[2]) end, { "switch", "create", "delete", "prune" }) or
            {}
        end,
        desc = "Manage git worktrees"
    })
    vim.keymap.set("n", "<leader>ws", M.switch, { desc = "Worktree switch" })
    vim.keymap.set("n", "<leader>wc", M.create, { desc = "Worktree create" })
    vim.keymap.set("n", "<leader>wd", M.delete, { desc = "Worktree delete" })
end

M.setup()
return M
