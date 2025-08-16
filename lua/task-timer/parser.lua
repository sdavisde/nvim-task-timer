local timestamp = require("task-timer.timestamp")

local M = {}

function M.is_task_line(line)
  -- Match lines that start with "- [ ]" or "- [x]" (with optional leading whitespace)
  return line:match("^%s*%- %[[ x]%]") ~= nil
end

function M.is_completed_task(line)
  return line:match("^%s*%- %[x%]") ~= nil
end

function M.get_task_indent(line)
  local indent = line:match("^(%s*)")
  return #indent
end

function M.find_time_blocks(line)
  local blocks = {}
  -- Find all time block patterns in the line
  for block in line:gmatch("%[%d+%.%d+%.%d+@%d+:%d+%-[%d:]*%]") do
    local parsed = timestamp.parse_time_block(block)
    if parsed then
      table.insert(blocks, {
        text = block,
        parsed = parsed
      })
    end
  end
  return blocks
end

function M.find_manual_time_entries(line)
  local entries = {}
  for entry in line:gmatch("{[^}]+}") do
    local minutes = timestamp.parse_manual_time(entry)
    if minutes then
      table.insert(entries, {
        text = entry,
        minutes = minutes
      })
    end
  end
  return entries
end

function M.get_active_time_block(line)
  local time_blocks = M.find_time_blocks(line)
  for _, block in ipairs(time_blocks) do
    if block.parsed.is_active then
      return block
    end
  end
  return nil
end

function M.has_active_time_block(line)
  return M.get_active_time_block(line) ~= nil
end

function M.find_current_task()
  local current_line = vim.api.nvim_get_current_line()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local line_num = cursor_pos[1]

  -- Check if current line is a task
  if M.is_task_line(current_line) then
    return {
      line_num = line_num,
      line = current_line,
      indent = M.get_task_indent(current_line)
    }
  end

  -- Look backwards for the nearest task at the same or lower indent level
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local current_indent = M.get_task_indent(current_line)

  for i = line_num - 1, 1, -1 do
    local line = lines[i]
    if M.is_task_line(line) then
      local task_indent = M.get_task_indent(line)
      if task_indent <= current_indent then
        return {
          line_num = i,
          line = line,
          indent = task_indent
        }
      end
    end
  end

  return nil
end

function M.get_task_context(line_num)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local task_line = lines[line_num]
  local task_indent = M.get_task_indent(task_line)

  local context = {
    main_task = { line_num = line_num, line = task_line },
    sub_tasks = {},
    notes = {}
  }

  -- Find sub-tasks and notes (lines with greater indentation)
  for i = line_num + 1, #lines do
    local line = lines[i]
    local indent = M.get_task_indent(line)

    if indent <= task_indent and line:match("%S") then
      -- Found a line at same or lower indentation that's not empty - stop here
      break
    elseif indent > task_indent then
      if M.is_task_line(line) then
        table.insert(context.sub_tasks, { line_num = i, line = line })
      else
        table.insert(context.notes, { line_num = i, line = line })
      end
    end
  end

  return context
end

function M.calculate_total_time(context)
  local total_minutes = 0

  -- Check main task
  local time_blocks = M.find_time_blocks(context.main_task.line)
  for _, block in ipairs(time_blocks) do
    if block.parsed.end_time then
      local duration = timestamp.calculate_duration(block.parsed.start_time, block.parsed.end_time)
      if duration then
        total_minutes = total_minutes + duration
      end
    end
  end

  -- Check manual time entries
  local manual_entries = M.find_manual_time_entries(context.main_task.line)
  for _, entry in ipairs(manual_entries) do
    total_minutes = total_minutes + entry.minutes
  end

  -- Check sub-tasks
  for _, sub_task in ipairs(context.sub_tasks) do
    local sub_blocks = M.find_time_blocks(sub_task.line)
    for _, block in ipairs(sub_blocks) do
      if block.parsed.end_time then
        local duration = timestamp.calculate_duration(block.parsed.start_time, block.parsed.end_time)
        if duration then
          total_minutes = total_minutes + duration
        end
      end
    end

    local sub_manual = M.find_manual_time_entries(sub_task.line)
    for _, entry in ipairs(sub_manual) do
      total_minutes = total_minutes + entry.minutes
    end
  end

  return total_minutes
end

return M
