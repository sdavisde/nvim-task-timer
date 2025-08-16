local config = require("task-timer.config")

local M = {}

function M.get_current_date()
  return os.date(config.options.date_format)
end

function M.get_current_time()
  if config.options.time_format == "12h" then
    return os.date("%I:%M%p"):lower()
  else
    return os.date("%H:%M")
  end
end

function M.get_current_datetime()
  return M.get_current_date() .. "@" .. M.get_current_time()
end

function M.format_time_block_start()
  return "[" .. M.get_current_datetime() .. "-]"
end

function M.format_time_block_end(start_time)
  local current_time = M.get_current_time()
  -- Extract the date and start time from the start_time string
  local date_time = start_time:match("%[(.-)%-]")
  if date_time then
    return "[" .. date_time .. "-" .. current_time .. "]"
  end
  return "[" .. M.get_current_datetime() .. "]"
end

function M.parse_time_block(text)
  -- Match pattern like [08.22.2025@14:30-15:15] or [08.22.2025@14:30-]
  local date, start_time, end_time = text:match("%[(%d+%.%d+%.%d+)@(%d+:%d+)%-(%d*:?%d*)%]")
  if date and start_time then
    return {
      date = date,
      start_time = start_time,
      end_time = end_time ~= "" and end_time or nil,
      is_active = end_time == "" or end_time == nil
    }
  end
  return nil
end

function M.calculate_duration(start_time, end_time)
  if not start_time or not end_time then
    return nil
  end

  local start_hour, start_min = start_time:match("(%d+):(%d+)")
  local end_hour, end_min = end_time:match("(%d+):(%d+)")

  if not start_hour or not end_hour then
    return nil
  end

  start_hour, start_min = tonumber(start_hour), tonumber(start_min)
  end_hour, end_min = tonumber(end_hour), tonumber(end_min)

  local start_minutes = start_hour * 60 + start_min
  local end_minutes = end_hour * 60 + end_min

  -- Handle overnight times
  if end_minutes < start_minutes then
    end_minutes = end_minutes + 24 * 60
  end

  return end_minutes - start_minutes
end

function M.format_duration(minutes)
  if not minutes then
    return "Unknown"
  end

  local hours = math.floor(minutes / 60)
  local mins = minutes % 60

  if hours > 0 then
    return string.format("%dh %dm", hours, mins)
  else
    return string.format("%dm", mins)
  end
end

function M.parse_manual_time(text)
  -- Match patterns like {30m}, {2h}, {1h30m}
  local time_str = text:match("{([^}]+)}")
  if not time_str then
    return nil
  end

  local hours = time_str:match("(%d+)h") or 0
  local minutes = time_str:match("(%d+)m") or 0

  hours = tonumber(hours)
  minutes = tonumber(minutes)

  return hours * 60 + minutes
end

function M.is_today(date_str)
  local today = M.get_current_date()
  return date_str == today
end

return M
