local parser = require("task-timer.parser")
local timestamp = require("task-timer.timestamp")
local config = require("task-timer.config")

local M = {}
local namespace_id = vim.api.nvim_create_namespace("task_timer")

function M.clear_highlights(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(buf, namespace_id, 0, -1)
end

function M.highlight_time_blocks(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  
  -- Clear existing highlights
  M.clear_highlights(buf)
  
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  
  for line_num, line in ipairs(lines) do
    if parser.is_task_line(line) then
      local time_blocks = parser.find_time_blocks(line)
      
      for _, block in ipairs(time_blocks) do
        local start_col = line:find(vim.pesc(block.text), 1, true)
        if start_col then
          start_col = start_col - 1 -- Convert to 0-based indexing
          local end_col = start_col + #block.text
          local highlight_group
          
          if block.parsed.is_active then
            highlight_group = config.options.visual.active_highlight
          elseif timestamp.is_today(block.parsed.date) then
            highlight_group = config.options.visual.today_highlight
          else
            highlight_group = config.options.visual.completed_highlight
          end
          
          vim.api.nvim_buf_add_highlight(
            buf,
            namespace_id,
            highlight_group,
            line_num - 1, -- Convert to 0-based line indexing
            start_col,
            end_col
          )
        end
      end
      
      -- Highlight manual time entries
      local manual_entries = parser.find_manual_time_entries(line)
      for _, entry in ipairs(manual_entries) do
        local start_col = line:find(vim.pesc(entry.text), 1, true)
        if start_col then
          start_col = start_col - 1
          local end_col = start_col + #entry.text
          
          vim.api.nvim_buf_add_highlight(
            buf,
            namespace_id,
            config.options.visual.completed_highlight,
            line_num - 1,
            start_col,
            end_col
          )
        end
      end
    end
  end
end

function M.setup_autocommands()
  local group = vim.api.nvim_create_augroup("TaskTimerVisual", { clear = true })
  
  -- Update highlights when buffer content changes
  vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost", "TextChanged", "TextChangedI"}, {
    group = group,
    pattern = "*.md",
    callback = function()
      M.highlight_time_blocks()
    end,
  })
  
  -- Clear highlights when leaving buffer
  vim.api.nvim_create_autocmd("BufLeave", {
    group = group,
    pattern = "*.md",
    callback = function()
      M.clear_highlights()
    end,
  })
end

function M.get_statusline_info()
  local current_task = parser.find_current_task()
  if not current_task then
    return ""
  end
  
  local active_block = parser.get_active_time_block(current_task.line)
  if active_block then
    local parsed = timestamp.parse_time_block(active_block.text)
    if parsed then
      return string.format(" 🕐 %s", parsed.start_time)
    end
  end
  
  return ""
end

return M