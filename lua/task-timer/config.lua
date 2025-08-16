local M = {}

M.defaults = {
  time_format = "24h", -- "24h" or "12h"
  date_format = "%m.%d.%Y", -- strftime format
  long_task_threshold = 120, -- minutes
  auto_save = true,
  keymaps = {
    start_timer = "<leader>ts",
    end_timer = "<leader>te",
    resume_timer = "<leader>tr",
  },
  visual = {
    active_highlight = "TaskTimerActive",
    completed_highlight = "TaskTimerCompleted",
    today_highlight = "TaskTimerToday",
  },
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})

  -- Set up highlight groups
  vim.api.nvim_set_hl(0, "TaskTimerActive", { fg = "#ffaa00", bold = true })
  vim.api.nvim_set_hl(0, "TaskTimerCompleted", { fg = "#00aa00" })
  vim.api.nvim_set_hl(0, "TaskTimerToday", { fg = "#0088ff" })
end

return M
