local parser = require("task-timer.parser")
local timestamp = require("task-timer.timestamp")
local config = require("task-timer.config")

local M = {}

function M.start_timer()
  local current_task = parser.find_current_task()
  
  if not current_task then
    vim.notify("No task found. Place cursor on or under a task line (- [ ] or - [x])", vim.log.levels.WARN)
    return
  end
  
  -- Check if there's already an active time block
  if parser.has_active_time_block(current_task.line) then
    vim.notify("Task already has an active time block", vim.log.levels.WARN)
    return
  end
  
  -- Add the new time block to the end of the line
  local new_line = current_task.line .. " " .. timestamp.format_time_block_start()
  vim.api.nvim_buf_set_lines(0, current_task.line_num - 1, current_task.line_num, false, {new_line})
  
  vim.notify("Timer started for task", vim.log.levels.INFO)
  
  if config.options.auto_save then
    vim.cmd("silent! write")
  end
end

function M.end_timer()
  local current_task = parser.find_current_task()
  
  if not current_task then
    vim.notify("No task found. Place cursor on or under a task line (- [ ] or - [x])", vim.log.levels.WARN)
    return
  end
  
  local active_block = parser.get_active_time_block(current_task.line)
  if not active_block then
    vim.notify("No active time block found for this task", vim.log.levels.WARN)
    return
  end
  
  -- Replace the active time block with a completed one
  local completed_block = timestamp.format_time_block_end(active_block.text)
  local new_line = current_task.line:gsub(vim.pesc(active_block.text), completed_block)
  vim.api.nvim_buf_set_lines(0, current_task.line_num - 1, current_task.line_num, false, {new_line})
  
  -- Calculate and show duration
  local parsed = timestamp.parse_time_block(completed_block)
  if parsed and parsed.end_time then
    local duration = timestamp.calculate_duration(parsed.start_time, parsed.end_time)
    if duration then
      vim.notify(string.format("Timer ended. Duration: %s", timestamp.format_duration(duration)), vim.log.levels.INFO)
      
      -- Check for long task warning
      if duration > config.options.long_task_threshold then
        vim.notify(string.format("Long task detected! (%s)", timestamp.format_duration(duration)), vim.log.levels.WARN)
      end
    end
  end
  
  if config.options.auto_save then
    vim.cmd("silent! write")
  end
end

function M.resume_timer()
  local current_task = parser.find_current_task()
  
  if not current_task then
    vim.notify("No task found. Place cursor on or under a task line (- [ ] or - [x])", vim.log.levels.WARN)
    return
  end
  
  -- Check if there's already an active time block
  if parser.has_active_time_block(current_task.line) then
    vim.notify("Task already has an active time block", vim.log.levels.WARN)
    return
  end
  
  -- Add a new time block (same as start_timer)
  M.start_timer()
end

function M.show_task_summary()
  local current_task = parser.find_current_task()
  
  if not current_task then
    vim.notify("No task found. Place cursor on or under a task line (- [ ] or - [x])", vim.log.levels.WARN)
    return
  end
  
  local context = parser.get_task_context(current_task.line_num)
  local total_time = parser.calculate_total_time(context)
  
  local summary = {
    "Task Summary:",
    "=============",
    "",
    "Task: " .. current_task.line:gsub("^%s*", ""),
    "Total time: " .. timestamp.format_duration(total_time),
    ""
  }
  
  -- Show time blocks
  local time_blocks = parser.find_time_blocks(current_task.line)
  if #time_blocks > 0 then
    table.insert(summary, "Time blocks:")
    for _, block in ipairs(time_blocks) do
      local status = block.parsed.is_active and " (ACTIVE)" or ""
      local duration = ""
      if block.parsed.end_time then
        local dur = timestamp.calculate_duration(block.parsed.start_time, block.parsed.end_time)
        duration = " - " .. timestamp.format_duration(dur)
      end
      table.insert(summary, "  " .. block.text .. duration .. status)
    end
    table.insert(summary, "")
  end
  
  -- Show manual time entries
  local manual_entries = parser.find_manual_time_entries(current_task.line)
  if #manual_entries > 0 then
    table.insert(summary, "Manual time entries:")
    for _, entry in ipairs(manual_entries) do
      table.insert(summary, "  " .. entry.text .. " - " .. timestamp.format_duration(entry.minutes))
    end
    table.insert(summary, "")
  end
  
  -- Show in a floating window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, summary)
  
  local width = 60
  local height = #summary + 2
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Task Timer Summary ",
    title_pos = "center"
  }
  
  vim.api.nvim_open_win(buf, true, opts)
  
  -- Close on any key press
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf })
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf })
  vim.keymap.set("n", "<CR>", "<cmd>close<cr>", { buffer = buf })
end

return M