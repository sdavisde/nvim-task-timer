-- Prevent loading the plugin twice
if vim.g.loaded_task_timer then
  return
end
vim.g.loaded_task_timer = 1

-- Only load in markdown files by default
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Set up the plugin with default configuration if not already done
    if not vim.g.task_timer_setup then
      require("task-timer").setup()
      vim.g.task_timer_setup = 1
    end
  end,
})