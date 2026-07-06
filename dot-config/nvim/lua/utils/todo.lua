-- SPDX-License-Identifier: MIT
-- utils.todo: Checkbox cycling + auto-move for todo.md files.
--
-- Expects a markdown file with sections:
--   ## Inbox, ## In Progress, ## Waiting, ## Done
--
-- Checkbox states and their target sections:
--   [ ]  -> Inbox
--   [/]  -> In Progress
--   [>]  -> Waiting
--   [x]  -> Done

local M = {}

-- Ordered checkbox states for cycling
local states = { '[ ]', '[/]', '[>]', '[x]' }

-- Map checkbox state -> section heading
local section_for = {
  ['[ ]'] = '## Inbox',
  ['[/]'] = '## In Progress',
  ['[>]'] = '## Waiting',
  ['[x]'] = '## Done',
}

--- Find the line number (0-indexed) of a section heading.
---@param lines string[]
---@param heading string
---@return integer? line number (0-indexed) or nil
local function find_section(lines, heading)
  for i, line in ipairs(lines) do
    if line == heading then
      return i - 1
    end
  end
  return nil
end

--- Find the last content line under a section (to append after it).
--- Returns the 0-indexed line number to insert after.
---@param lines string[]
---@param section_line integer 0-indexed line of the section heading
---@return integer insert position (0-indexed)
local function section_end(lines, section_line)
  local pos = section_line + 1
  for i = section_line + 2, #lines do
    local line = lines[i]
    if line:match('^##? ') then
      break
    end
    if line:match('%S') then
      pos = i - 1 -- 0-indexed
    end
  end
  return pos
end

--- Get the indentation level of a line (number of leading spaces).
---@param line string
---@return integer
local function indent_of(line)
  local spaces = line:match('^(%s*)')
  return #spaces
end

--- Collect the parent line + all more-indented child lines below it.
--- Returns 0-indexed range [row, row_end) and the list of lines.
---@param bufnr integer
---@param row integer 0-indexed row of the parent task
---@return integer row_start, integer row_end, string[] block
local function collect_block(bufnr, row)
  local all_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local parent_indent = indent_of(all_lines[row + 1])
  local row_end = row + 1
  for i = row + 2, #all_lines do
    local line = all_lines[i]
    -- Stop at lines with same or lesser indent (or headings, or blank lines
    -- that are followed by non-child content)
    if line:match('^##? ') then
      break
    end
    if indent_of(line) <= parent_indent and line:match('%S') then
      break
    end
    -- Blank lines: include if the next non-blank line is still a child
    if not line:match('%S') then
      -- Peek ahead for a child line
      local has_child = false
      for j = i + 1, #all_lines do
        if all_lines[j]:match('%S') then
          has_child = indent_of(all_lines[j]) > parent_indent
          break
        end
      end
      if not has_child then
        break
      end
    end
    row_end = i - 1 -- 0-indexed
  end
  local block = vim.api.nvim_buf_get_lines(bufnr, row, row_end + 1, false)
  return row, row_end + 1, block
end

--- Update checkbox states in child lines to match the new parent state.
---@param block string[] lines (first is parent, rest are children)
---@param new_state string e.g. '[x]'
---@return string[] updated block
local function propagate_state(block, new_state)
  local result = {}
  for i, line in ipairs(block) do
    if i == 1 then
      table.insert(result, line) -- parent already updated by caller
    else
      local p, _, r = line:match('^(%s*%- )(%[.%])(.*)')
      if p then
        table.insert(result, p .. new_state .. r)
      else
        table.insert(result, line)
      end
    end
  end
  return result
end

--- Core: change a task's state and move it (with children) to the target section.
---@param row integer 0-indexed cursor row
---@param new_state string target checkbox state
local function apply_state(row, new_state)
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]

  local prefix, old_state, rest = line:match('^(%s*%- )(%[.%])(.*)')
  if not old_state then
    return
  end
  if old_state == new_state then
    return
  end

  -- Collect parent + children
  local _, row_end, block = collect_block(bufnr, row)

  -- Update parent line
  block[1] = prefix .. new_state .. rest
  -- Propagate state to children
  block = propagate_state(block, new_state)

  local target_heading = section_for[new_state]
  if not target_heading then
    vim.api.nvim_buf_set_lines(bufnr, row, row_end, false, block)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local target_section = find_section(lines, target_heading)

  if not target_section then
    vim.api.nvim_buf_set_lines(bufnr, row, row_end, false, block)
    return
  end

  -- Check if already in the correct section
  local current_section = nil
  for i = row, 0, -1 do
    if lines[i + 1]:match('^## ') then
      current_section = i
      break
    end
  end

  if current_section == target_section then
    vim.api.nvim_buf_set_lines(bufnr, row, row_end, false, block)
    return
  end

  -- Delete block from current position
  vim.api.nvim_buf_set_lines(bufnr, row, row_end, false, {})

  -- Re-read and find target
  lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  target_section = find_section(lines, target_heading)
  if not target_section then
    return
  end

  local insert_at = section_end(lines, target_section) + 1
  vim.api.nvim_buf_set_lines(bufnr, insert_at, insert_at, false, block)

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local cursor_row = math.min(insert_at + 1, line_count)
  vim.api.nvim_win_set_cursor(0, { cursor_row, 0 })
end

--- Cycle the checkbox on the current line and move it to the correct section.
---@param direction integer 1 for forward, -1 for backward
function M.cycle(direction)
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]

  local _, old_state = line:match('^(%s*%- )(%[.%])')
  if not old_state then
    return
  end

  local idx
  for i, s in ipairs(states) do
    if s == old_state then
      idx = i
      break
    end
  end
  if not idx then
    return
  end

  local new_idx = ((idx - 1 + direction) % #states) + 1
  apply_state(row, states[new_idx])
end

--- Set the checkbox to a specific state and move to the correct section.
---@param state string one of '[ ]', '[/]', '[>]', '[x]'
function M.set(state)
  if not section_for[state] then
    return
  end
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  apply_state(row, state)
end

return M
