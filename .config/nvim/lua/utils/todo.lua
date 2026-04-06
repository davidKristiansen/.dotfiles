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
    if line == heading then return i - 1 end
  end
  return nil
end

--- Find the last task line under a section (to append after it).
--- Returns the 0-indexed line number to insert after.
---@param lines string[]
---@param section_line integer 0-indexed line of the section heading
---@return integer insert position (0-indexed)
local function section_end(lines, section_line)
  local pos = section_line + 1
  for i = section_line + 2, #lines do
    local line = lines[i]
    -- Stop at next heading
    if line:match('^##? ') then break end
    -- Track last non-empty line in the section
    if line:match('^%s*%- %[.%]') then
      pos = i - 1 -- 0-indexed
    end
  end
  return pos
end

--- Cycle the checkbox on the current line and move it to the correct section.
---@param direction integer 1 for forward, -1 for backward
function M.cycle(direction)
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-indexed
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]

  -- Find current checkbox state
  local prefix, old_state, rest = line:match('^(%s*%- )(%[.%])(.*)')
  if not old_state then return end

  -- Find current index in cycle
  local idx
  for i, s in ipairs(states) do
    if s == old_state then idx = i; break end
  end
  if not idx then return end

  -- Cycle to next state
  local new_idx = ((idx - 1 + direction) % #states) + 1
  local new_state = states[new_idx]
  local new_line = prefix .. new_state .. rest

  -- Determine target section
  local target_heading = section_for[new_state]
  if not target_heading then return end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local target_section = find_section(lines, target_heading)

  if not target_section then
    -- No matching section, just update in place
    vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, { new_line })
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
    -- Same section, just update the checkbox
    vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, { new_line })
    return
  end

  -- Move line: delete from current position, insert at end of target section
  -- Delete current line first
  vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, {})

  -- Re-read lines after deletion (indices shifted)
  lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  target_section = find_section(lines, target_heading)
  if not target_section then return end

  local insert_at = section_end(lines, target_section) + 1
  vim.api.nvim_buf_set_lines(bufnr, insert_at, insert_at, false, { new_line })

  -- Place cursor on the moved line (clamp to buffer length)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local cursor_row = math.min(insert_at + 1, line_count)
  vim.api.nvim_win_set_cursor(0, { cursor_row, 0 })
end

return M
