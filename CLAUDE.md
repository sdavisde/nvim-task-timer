# nvim-task-timer Development Notes

## Project Overview
A Neovim plugin for time tracking in markdown files with automatic timestamping, visual indicators, and task context awareness.

## Implementation Status
✅ **COMPLETED**
- [x] Plugin structure (lua/, plugin/, doc/)
- [x] Core modules (config, timestamp, parser, commands, visual)
- [x] Time tracking commands (`<leader>ts`, `<leader>te`)
- [x] Timestamp formatting (`[MM.DD.YYYY@HH:MM - MM.DD.YYYY@HH:MM]`)
- [x] Task detection and parsing
- [x] Visual highlighting system
- [x] Manual time entry support (`{30m}`, `{2h15m}`)
- [x] Configuration system
- [x] User commands (`:TaskTimerStart`, `:TaskTimerEnd`, etc.)
- [x] Documentation (help file, README, examples)
- [x] Development script (`develop.lua`)

## Known Issues Fixed During Development
1. **Module loading problems** - Complex require() dependencies failed
   - **Solution**: Created simplified `develop.lua` with inline functions
2. **Timestamp format inconsistency** - Generated wrong date format
   - **Solution**: Fixed to use `MM.DD.YYYY@HH:MM` format consistently
3. **Active timer detection** - Couldn't find active time blocks
   - **Solution**: Proper regex patterns for `[date@time-]` format

## Architecture

### Core Files
- `lua/task-timer/init.lua` - Main plugin interface
- `lua/task-timer/config.lua` - Configuration management
- `lua/task-timer/timestamp.lua` - Time/date utilities
- `lua/task-timer/parser.lua` - Markdown task parsing
- `lua/task-timer/commands.lua` - User commands implementation
- `lua/task-timer/visual.lua` - Highlighting and visual indicators
- `plugin/task-timer.lua` - Plugin entry point
- `doc/task-timer.txt` - Vim help documentation

### Key Functions
- `find_current_task()` - Detect task context from cursor position
- `format_time_block_start()` - Generate `[MM.DD.YYYY@HH:MM-]`
- `format_time_block_end()` - Complete to `[start - end]` format
- `find_active_time_block()` - Detect incomplete timers
- `setup_autocommands()` - Visual highlighting triggers

## Testing Approach
**Primary**: Use `develop.lua` for reliable testing
- Run `:luafile develop.lua` in Neovim
- Test on markdown files with task syntax
- Simplified implementation without module dependencies

## Future Improvements

### High Priority
- [ ] Fix module loading in main plugin structure
- [ ] Add proper error handling for edge cases
- [ ] Implement duration calculations and display
- [ ] Add time summary/reporting features

### Medium Priority
- [ ] Export/import time data
- [ ] Integration with external time tracking tools
- [ ] Multiple timer support per task
- [ ] Task completion detection and auto-stop
- [ ] Time estimation vs actual tracking

### Low Priority
- [ ] Time tracking analytics/charts
- [ ] Team collaboration features
- [ ] Custom timestamp formats
- [ ] Pomodoro timer integration
- [ ] Calendar integration

## Technical Debt
1. **Module loading system** - Main plugin has complex dependency issues
2. **Error handling** - Limited error cases covered
3. **Testing** - No automated tests, only manual testing script
4. **Performance** - No optimization for large files
5. **Documentation** - API docs could be more comprehensive

## Development Commands
```vim
" Load development version
:luafile develop.lua

" Test on example file
:edit test.md
:edit example.md

" Available commands after loading
:TaskTimerStart
:TaskTimerEnd
:TaskTimerSummary
```

## File Structure
```
nvim-task-timer/
├── lua/task-timer/
│   ├── init.lua          # Main interface
│   ├── config.lua        # Configuration
│   ├── timestamp.lua     # Time utilities
│   ├── parser.lua        # Markdown parsing
│   ├── commands.lua      # User commands
│   └── visual.lua        # Highlighting
├── plugin/
│   └── task-timer.lua    # Plugin entry
├── doc/
│   └── task-timer.txt    # Help docs
├── develop.lua           # Working test script
├── test.md              # Test file
├── example.md           # Example usage
└── README.md            # Documentation
```

## Configuration Example
```lua
require("task-timer").setup({
  time_format = "24h",
  date_format = "%m.%d.%Y", 
  long_task_threshold = 120,
  auto_save = true,
  keymaps = {
    start_timer = "<leader>ts",
    end_timer = "<leader>te",
    resume_timer = "<leader>tr",
  },
})
```

## Timestamp Formats
- **Active**: `[08.16.2025@14:30-]`
- **Completed**: `[08.16.2025@14:30 - 08.16.2025@15:15]`
- **Manual**: `{30m}`, `{2h15m}`, `{1h30m}`

## Plugin Loading Notes
The main plugin structure works in theory but has module dependency issues in practice. The `develop.lua` script provides a working implementation by defining all functions inline without external dependencies. For production use, the module loading system needs to be debugged and fixed.

## Last Updated
August 16, 2025 - Initial implementation completed