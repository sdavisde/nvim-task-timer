# nvim-task-timer

A Neovim plugin for tracking time on tasks in markdown files with automatic timestamping and visual indicators.

## ✨ Features

- **Automatic timestamping** - Start and end timers with simple keybinds
- **Visual indicators** - Highlight active, completed, and today's time blocks
- **Duration calculation** - See how long you spent on each task
- **Manual time entry** - Quick entry with `{30m}` or `{2h15m}` syntax
- **Smart context detection** - Works with nested tasks and sub-notes
- **Configurable formats** - 12h/24h time, custom date formats
- **Long task warnings** - Get notified about tasks exceeding thresholds

## 📋 Usage

Works with standard markdown task syntax:

```markdown
- [ ] Write documentation [08.16.2025@14:30 - 08.16.2025@15:15]
- [x] Code review {45m}
- [ ] Current task [08.16.2025@16:00-]
```

### Basic Workflow

1. Place cursor on or under a task line
2. Press `<leader>ts` to start timer
3. Press `<leader>te` to end timer  
4. View automatically generated timestamps

### Time Formats

- **Active timer**: `[08.16.2025@14:30-]`
- **Completed timer**: `[08.16.2025@14:30 - 08.16.2025@15:15]`
- **Manual entry**: `{30m}`, `{2h15m}`

## 🚀 Installation

### lazy.nvim

```lua
{
  "your-username/nvim-task-timer",
  ft = "markdown",
  config = function()
    require("task-timer").setup()
  end,
}
```

### packer.nvim

```lua
use {
  "your-username/nvim-task-timer",
  ft = "markdown",
  config = function()
    require("task-timer").setup()
  end,
}
```

### vim-plug

```vim
Plug 'your-username/nvim-task-timer'
```

## ⚙️ Configuration

```lua
require("task-timer").setup({
  time_format = "24h",          -- "24h" or "12h"
  date_format = "%m.%d.%Y",     -- strftime format
  long_task_threshold = 120,    -- minutes for warnings
  auto_save = true,             -- auto-save after operations
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
})
```

## 🎯 Commands

| Command | Description |
|---------|-------------|
| `:TaskTimerStart` | Start timer for current task |
| `:TaskTimerEnd` | End timer for current task |
| `:TaskTimerResume` | Resume/start timer (same as start) |
| `:TaskTimerSummary` | Show task summary in floating window |

## ⌨️ Default Keymaps

| Keymap | Action |
|--------|--------|
| `<leader>ts` | Start timer |
| `<leader>te` | End timer |
| `<leader>tr` | Resume timer |

## 🎨 Highlighting

Time blocks are automatically highlighted:
- 🟠 **Active timers** - Orange highlight
- 🟢 **Completed timers** - Green highlight  
- 🔵 **Today's timers** - Blue highlight

## 📊 Statusline Integration

Add current timer to your statusline:

```lua
-- In your statusline config
local function task_timer_status()
  return require("task-timer").get_statusline_info()
end
```

## 📚 Examples

### Basic Task Tracking
```markdown
- [ ] Write plugin documentation [08.16.2025@09:00 - 08.16.2025@10:30]
- [x] Code review session [08.15.2025@14:00 - 08.15.2025@14:45]
- [ ] Bug investigation [08.16.2025@15:00-]
```

### Mixed Time Tracking
```markdown
- [x] Feature implementation [08.15.2025@10:00 - 08.15.2025@12:00] {1h30m}
  - Initial coding: 2h
  - Additional research: 1h30m
  - Total: 3h30m
```

### Project Organization
```markdown
## Frontend Development
- [x] Component setup [08.14.2025@09:00 - 08.14.2025@11:30]
- [ ] API integration [08.16.2025@14:00-]
- [ ] Testing {45m}

## Documentation  
- [x] User guide {2h15m}
- [ ] API docs [08.16.2025@16:00-]
```

## 🔧 Development

For development and testing, use the included development script:

```vim
:luafile develop.lua
```

This loads a simplified version for testing without full plugin installation.

## 📝 Requirements

- Neovim 0.8.0+
- Markdown files (`.md`)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details.

## 🙏 Acknowledgments

Inspired by time tracking needs in markdown-based project management and note-taking workflows.