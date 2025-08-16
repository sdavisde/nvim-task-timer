local config = require("task-timer.config")
local commands = require("task-timer.commands")
local visual = require("task-timer.visual")

local M = {}

function M.setup(opts)
  config.setup(opts)

  -- Set up keymaps
  vim.keymap.set("n", config.options.keymaps.start_timer, commands.start_timer, { desc = "Start task timer" })
  vim.keymap.set("n", config.options.keymaps.end_timer, commands.end_timer, { desc = "End task timer" })
  vim.keymap.set("n", config.options.keymaps.resume_timer, commands.resume_timer, { desc = "Resume task timer" })

  -- Set up user commands
  vim.api.nvim_create_user_command("TaskTimerStart", commands.start_timer, { desc = "Start task timer" })
  vim.api.nvim_create_user_command("TaskTimerEnd", commands.end_timer, { desc = "End task timer" })
  vim.api.nvim_create_user_command("TaskTimerResume", commands.resume_timer, { desc = "Resume task timer" })
  vim.api.nvim_create_user_command("TaskTimerSummary", commands.show_task_summary, { desc = "Show task summary" })

  -- Set up visual indicators
  visual.setup_autocommands()
end

-- Export commands for direct access
M.start_timer = commands.start_timer
M.end_timer = commands.end_timer
M.resume_timer = commands.resume_timer
M.show_summary = commands.show_task_summary
M.get_statusline_info = visual.get_statusline_info

return M
