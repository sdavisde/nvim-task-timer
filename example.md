# Task Timer Example

This file demonstrates the various features of the task-timer plugin.

## Basic Tasks

- [ ] Write plugin documentation
- [x] Implement core functionality
- [ ] Add visual indicators
- [x] Create configuration system

## Tasks with Time Tracking

- [x] Research markdown parsing [08.15.2025@09:00-10:30]
  - Studied existing Neovim markdown plugins
  - Analyzed regex patterns for task detection

- [ ] Implement timestamp utilities [08.16.2025@14:00-]
  - Currently working on this task
  - Time format configuration

- [x] Code review session [08.14.2025@11:00-11:45] [08.15.2025@15:30-16:00]
  - Multiple time blocks for the same task
  - Total time: 1h 15m

## Tasks with Manual Time Entry

- [x] Team meeting {1h30m}
- [x] Quick bug fix {15m}
- [x] Research and planning {2h45m}

## Mixed Time Tracking

- [x] Feature implementation [08.13.2025@10:00-12:30] {45m} [08.14.2025@09:00-10:15]
  - Actual coding time: 2h 30m
  - Additional research: 45m  
  - Bug fixes: 1h 15m
  - Total: 4h 30m

## Project Tasks

### Frontend Development
- [x] Set up React components [08.12.2025@13:00-15:30]
- [ ] Implement user interface [08.16.2025@16:00-]
- [ ] Add responsive design
- [ ] Write component tests

### Backend Development  
- [x] Database schema design {2h}
- [x] API endpoint implementation [08.15.2025@08:00-11:00]
- [ ] Authentication system
- [ ] Data validation

### Documentation
- [ ] API documentation
- [x] User guide {1h15m}
- [ ] Installation instructions
- [x] Example files [08.16.2025@12:00-12:30]

## Usage Instructions

1. Place cursor on any task line
2. Press `<leader>ts` to start a timer
3. Press `<leader>te` to end the timer
4. Use `:TaskTimerSummary` to see task details
5. Manual time entry with `{30m}` syntax