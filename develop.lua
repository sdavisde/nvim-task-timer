-- Simple test that creates the functions inline
-- Run with :luafile simple-test.lua

print("Setting up simple task timer test...")

-- Simple config
local config = {
  time_format = "24h",
  date_format = "%m.%d.%Y",
  long_task_threshold = 120,
}

-- Simple timestamp functions
local function get_current_date()
  return os.date("%m.%d.%Y")
end

local function get_current_time()
  return os.date("%H:%M")
end

local function format_time_block_start()
  return "[" .. get_current_date() .. "@" .. get_current_time() .. "-]"
end

local function format_time_block_end(start_block)
  local start_date_time = start_block:match("%[(.-)%-]")
  if start_date_time then
    local end_date_time = get_current_date() .. "@" .. get_current_time()
    return "[" .. start_date_time .. " - " .. end_date_time .. "]"
  end
  return "[" .. get_current_date() .. "@" .. get_current_time() .. "]"
end

-- Simple parser functions
local function is_task_line(line)
  return line:match("^%s*%- %[[ x]%]") ~= nil
end

local function find_active_time_block(line)
  -- Look for pattern like [MM.DD.YYYY@HH:MM-] (active block ends with just -)
  local block = line:match("%[%d+%.%d+%.%d+@%d+:%d+%-]")
  return block
end

local function find_current_task()
  local current_line = vim.api.nvim_get_current_line()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local line_num = cursor_pos[1]

  if is_task_line(current_line) then
    return { line_num = line_num, line = current_line }
  end

  -- Look backwards for a task
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for i = line_num - 1, 1, -1 do
    local line = lines[i]
    if is_task_line(line) then
      return { line_num = i, line = line }
    end
  end

  return nil
end

-- Simple command functions
local function start_timer()
  local current_task = find_current_task()

  if not current_task then
    vim.notify("No task found. Place cursor on or under a task line (- [ ] or - [x])", vim.log.levels.WARN)
    return
  end

  -- Check if there's already an active time block
  if find_active_time_block(current_task.line) then
    vim.notify("Task already has an active time block", vim.log.levels.WARN)
    return
  end

  -- Add the new time block to the end of the line
  local new_line = current_task.line .. " " .. format_time_block_start()
  vim.api.nvim_buf_set_lines(0, current_task.line_num - 1, current_task.line_num, false, {new_line})

  vim.notify("Timer started for task", vim.log.levels.INFO)
end

local function end_timer()
  local current_task = find_current_task()

  if not current_task then
    vim.notify("No task found. Place cursor on or under a task line (- [ ] or - [x])", vim.log.levels.WARN)
    return
  end

  local active_block = find_active_time_block(current_task.line)
  if not active_block then
    vim.notify("No active time block found for this task", vim.log.levels.WARN)
    return
  end

  -- Replace the active time block with a completed one
  local completed_block = format_time_block_end(active_block)
  local new_line = current_task.line:gsub(vim.pesc(active_block), completed_block)
  vim.api.nvim_buf_set_lines(0, current_task.line_num - 1, current_task.line_num, false, {new_line})

  vim.notify("Timer ended for task", vim.log.levels.INFO)
end

-- Create user commands
vim.api.nvim_create_user_command("TaskTimerStart", start_timer, { desc = "Start task timer" })
vim.api.nvim_create_user_command("TaskTimerEnd", end_timer, { desc = "End task timer" })

-- Create keymaps
vim.keymap.set("n", "<leader>ts", start_timer, { desc = "Start task timer" })
vim.keymap.set("n", "<leader>te", end_timer, { desc = "End task timer" })

print("✓ Simple task timer loaded!")
print("Commands: :TaskTimerStart, :TaskTimerEnd")
print("Keymaps: <leader>ts, <leader>te")
print("")
print("Start format: " .. format_time_block_start())
print("End format will be: [MM.DD.YYYY@HH:MM - MM.DD.YYYY@HH:MM]")
print("Now open test.md and try the commands!")
