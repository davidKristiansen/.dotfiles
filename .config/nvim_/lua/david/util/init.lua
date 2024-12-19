local M = {}

M.root_patterns = {
  ".git",
  "lua",
  "clang-format.txt",
  "pyproject.toml"
}

function M.get_root()
  ---@type string?
  local path = vim.api.nvim_buf_get_name(0)
  path = path ~= "" and vim.loop.fs_realpath(path) or nil
  ---@type string[]
  local roots = {}
  if path then
    for _, client in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
      local workspace = client.config.workspace_folders
      local paths = workspace and vim.tbl_map(function(ws)
        return vim.uri_to_fname(ws.uri)
      end, workspace) or client.config.root_dir and { client.config.root_dir } or {}
      for _, p in ipairs(paths) do
        local r = vim.loop.fs_realpath(p)
        if path:find(r, 1, true) then
          roots[#roots + 1] = r
        end
      end
    end
  end
  table.sort(roots, function(a, b)
    return #a > #b
  end)
  ---@type string?
  local root = roots[1]
  if not root then
    path = path and vim.fs.dirname(path) or vim.loop.cwd()
    ---@type string?
    root = vim.fs.find(M.root_patterns, { path = path, upward = true })[1]
    root = root and vim.fs.dirname(root) or vim.loop.cwd()
  end
  ---@cast root string
  return root
end

function M.telescope(builtin, opts)
  local params = { builtin = builtin, opts = opts }
  return function()
    builtin = params.builtin
    opts = params.opts
    opts = vim.tbl_deep_extend("force", { cwd = M.get_root() }, opts or {})
    if builtin == "files" then
      if vim.loop.fs_stat((opts.cwd or vim.loop.cwd()) .. "/.git") then
        opts.show_untracked = true
        builtin = "git_files"
      else
        builtin = "find_files"
      end
    end
    if opts.cwd and opts.cwd ~= vim.loop.cwd() then
      opts.attach_mappings = function(_, map)
        map("i", "<a-c>", function()
          local action_state = require("telescope.actions.state")
          local line = action_state.get_current_line()
          M.telescope(
            params.builtin,
            vim.tbl_deep_extend("force", {}, params.opts or {}, { cwd = false, default_text = line })
          )()
        end)
        return true
      end
    end

    require("telescope.builtin")[builtin](opts)
  end
end

function M.tprint (tbl, indent)
  if not indent then indent = 0 end
  local toprint = string.rep(" ", indent) .. "{\r\n"
  indent = indent + 2
  for k, v in pairs(tbl) do
    toprint = toprint .. string.rep(" ", indent)
    if (type(k) == "number") then
      toprint = toprint .. "[" .. k .. "] = "
    elseif (type(k) == "string") then
      toprint = toprint  .. k ..  "= "
    end
    if (type(v) == "number") then
      toprint = toprint .. v .. ",\r\n"
    elseif (type(v) == "string") then
      toprint = toprint .. "\"" .. v .. "\",\r\n"
    elseif (type(v) == "table") then
      toprint = toprint .. M.tprint(v, indent + 2) .. ",\r\n"
    else
      toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
    end
  end
  toprint = toprint .. string.rep(" ", indent-2) .. "}"
  return toprint
end

---@param string string
---@param idx number
---@return string
---@return number?
local function get_to_line_end(string, idx)
  local newline = string:find("\n", idx, true)
  local to_end = newline and string:sub(idx, newline - 1) or string:sub(idx)
  return to_end, newline
end

---Splice out an inclusive range from a string
---@param string string
---@param start_idx number
---@param end_idx? number
---@return string
local function str_splice(string, start_idx, end_idx)
  local new_content = string:sub(1, start_idx - 1)
  if end_idx then
    return new_content .. string:sub(end_idx + 1)
  else
    return new_content
  end
end

---@param string string
---@param idx number
---@param needle string
---@return number?
local function str_rfind(string, idx, needle)
  for i = idx, 1, -1 do
    if string:sub(i, i - 1 + needle:len()) == needle then
      return i
    end
  end
end

---Decodes a json string that may contain comments or trailing commas
---@param content string
---@return any
M.decode_json = function(content)
  local ok, data = pcall(vim.json.decode, content, { luanil = { object = true } })
  while not ok do
    local char = data:match("invalid token at character (%d+)$")
    if char then
      local to_end, newline = get_to_line_end(content, char)
      if to_end:match("^//") then
        content = str_splice(content, char, newline)
        goto continue
      end
    end

    char = data:match("Expected object key string but found [^%s]+ at character (%d+)$")
    char = char or data:match("Expected value but found T_ARR_END at character (%d+)")
    if char then
      local comma_idx = str_rfind(content, char, ",")
      if comma_idx then
        content = str_splice(content, comma_idx, comma_idx)
        goto continue
      end
    end

    error(data)
    ::continue::
    ok, data = pcall(vim.json.decode, content, { luanil = { object = true } })
  end
  return data
end

return M
