-- Overseer template provider for poethepoet tasks from pyproject.toml.
-- Detects whether to run via `uv run poe` or plain `poe`.

local function get_pyproject(opts)
  return vim.fs.find('pyproject.toml', { upward = true, type = 'file', path = opts.dir })[1]
end

--- Check if the project uses uv (has uv.lock or [tool.uv] in pyproject.toml)
---@param project_dir string
---@return boolean
local function uses_uv(project_dir)
  -- Fast check: uv.lock exists
  if vim.uv.fs_stat(project_dir .. '/uv.lock') then
    return true
  end
  return false
end

--- Parse poe tasks from pyproject.toml content.
--- Handles [tool.poe.tasks.<name>] sections and inline table entries.
---@param content string
---@return string[]
local function parse_poe_tasks(content)
  local tasks = {}
  local in_poe_tasks = false

  for line in content:gmatch('[^\r\n]+') do
    -- Match [tool.poe.tasks.TASKNAME] or [tool.poe.tasks.TASKNAME.* ]
    local section_task = line:match('^%[tool%.poe%.tasks%.([%w_%-]+)%]')
    if section_task then
      tasks[section_task] = true
      in_poe_tasks = false
    elseif line:match('^%[tool%.poe%.tasks%]') then
      in_poe_tasks = true
    elseif in_poe_tasks then
      -- End of section
      if line:match('^%[') then
        in_poe_tasks = false
      else
        -- Inline task: name = "..." or name = {cmd = ...} or name.cmd = ...
        local task_name = line:match('^(%w[%w_%-]*)%s*=')
        if task_name then
          tasks[task_name] = true
        end
      end
    end
  end

  local result = {}
  for name in pairs(tasks) do
    table.insert(result, name)
  end
  table.sort(result)
  return result
end

return {
  cache_key = function(opts)
    return get_pyproject(opts)
  end,
  generator = function(opts, cb)
    local pyproject = get_pyproject(opts)
    if not pyproject then
      return cb('No pyproject.toml found')
    end

    local content = vim.fn.readfile(pyproject)
    if not content or #content == 0 then
      return cb('Could not read pyproject.toml')
    end

    local text = table.concat(content, '\n')

    -- Check if poe tasks are defined at all
    if not text:find('%[tool%.poe') then
      return cb('No [tool.poe.tasks] section found')
    end

    local cwd = vim.fs.dirname(pyproject)
    local task_names = parse_poe_tasks(text)

    if #task_names == 0 then
      return cb('No poe tasks found in pyproject.toml')
    end

    -- Determine command prefix
    local use_uv = uses_uv(cwd)
    local cmd_prefix = use_uv and { 'uv', 'run', 'poe' } or { 'poe' }
    local display_prefix = use_uv and 'uv run poe' or 'poe'

    local ret = {}
    for _, name in ipairs(task_names) do
      table.insert(ret, {
        name = string.format('%s %s', display_prefix, name),
        builder = function()
          local cmd = vim.list_extend({}, cmd_prefix)
          table.insert(cmd, name)
          return {
            cmd = cmd,
            cwd = cwd,
          }
        end,
      })
    end

    cb(ret)
  end,
}
