# Tests for GitPilot.nvim

## Prerequisites

To run the tests, you need:
1. Neovim (0.5 or later)
2. [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

## Running Tests

From the root of the project, run:
```bash
nvim --headless -c "PlenaryBustedDirectory test/gitpilot/ {minimal_init = 'test/minimal_init.lua'}"
```

## Test Structure

- `test/gitpilot/`: Contains all test files
- Each test file is suffixed with `_spec.lua`
- Tests are organized to mirror the plugin's structure
