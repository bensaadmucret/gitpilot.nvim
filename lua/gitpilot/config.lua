local M = {}

-- Default configuration
M.defaults = {
    git = {
        cmd = 'git',
        timeout = 5000,
    },
    test_mode = false,
    data_dir = vim.fn.stdpath and vim.fn.stdpath('data') or (os.getenv('HOME') .. '/.local/share/nvim'),
}

-- Current configuration (initialized with defaults)
M.current = vim.tbl_deep_extend('force', {}, M.defaults)

-- Setup function to override defaults
M.setup = function(opts)
    if opts then
        M.current = vim.tbl_deep_extend('force', M.current, opts)
    end
end

-- Get current configuration
M.get = function()
    return M.current
end

-- Enable test mode
M.enable_test_mode = function()
    M.current.test_mode = true
end

-- Disable test mode
M.disable_test_mode = function()
    M.current.test_mode = false
end

return M
