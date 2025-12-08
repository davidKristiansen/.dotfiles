local fzf = require('fzf-lua')
local fn = vim.fn
local ffi = vim.F.npcall(require, "ffi")

if ffi then
  pcall(function()
    ffi.cdef [[
      int execl(const char *, const char *, ...);
    ]]
  end)
end

local function posix_exec(cmd, ...)
  local _is_win = fn.has("win32") == 1 or fn.has("win64") == 1
  if type(cmd) ~= "string" or _is_win or not ffi then return end
  ffi.C.execl(cmd, cmd, ...)
end

local function quit() vim.cmd.quit() end

fzf.setup({
  { "cli" },

  -- Visual and layout options
  winopts = {
    preview = { flip_columns = 130 }
  },
  fzf_opts = {
    ['--layout'] = 'default',
    ["--tmux"] = "bottom,40%",
    ["--height"] = "70%",
    ["--border-label-pos"] = "4:bottom",
    ["--border"] = os.getenv("TMUX") and "rounded" or "horizontal",
  },
  hls = {
    title = "diffAdd",
    title_flags = "Visual",
    header_bind = "Directory",
    header_text = "WarningMsg",
    live_prompt = "ErrorMsg",
  },
  previewers = {
    bat = { theme = "gruvbox-dark" }
  },

  actions = {
    files = {
      ["esc"] = quit,
      ["ctrl-c"] = quit,
      ["enter"] = function(s, o)
        local entries = vim.tbl_map(
          function(e) return fzf.path.entry_to_file(e, o) end, s)
        entries = vim.tbl_map(function(e)
          e.path = fzf.path.relative_to(e.path, vim.uv.cwd())
          return e
        end, entries)

        if ffi and #entries == 1 then
          posix_exec(fn.exepath("nvim"), entries[1].path,
            entries[1].line and ("+" .. entries[1].line) or nil,
            entries[1].col and ("+norm! %s|"):format(entries[1].col) or nil)
        elseif ffi and #entries > 1 then
          local file = fn.tempname()
          fn.writefile(vim.tbl_map(function(e)
            local text = e.stripped:match(":%d+:%d?%d?%d?%d?:?(.*)$") or ""
            return ("%s:%d:%d: %s"):format(e.path, e.line or 1, e.col or 1, text)
          end, entries), file)
          posix_exec(fn.exepath("nvim"), "-q", file)
        end

        io.stdout:write(vim.json.encode(entries) .. "\n")
        quit()
      end,
    }
  },

  grep = {
    prompt = false,
    fzf_opts = { ["--history"] = vim.fs.joinpath(vim.fn.stdpath("data"), "fzf_search_hist") },
  },

  zoxide = {
    actions = {
      ["enter"] = function(s)
        local entries = vim.tbl_map(function(e) return { path = e:match("[^\t]+$") } end, s)
        io.stdout:write(vim.json.encode(entries) .. "\n")
        vim.cmd.quit()
      end
    },
  },
})
