-- Minimal init.lua for running tests
local plugin_root = vim.fn.getcwd()
vim.opt.rtp:append(plugin_root)
vim.opt.rtp:append(plugin_root .. '/deps/plenary.nvim')

-- Set up test environment
vim.env.GITPILOT_TEST = "1"

-- Mock vim.notify if it doesn't exist
if not vim.notify then
    vim.notify = function() end
end

-- Mock vim.log.levels if they don't exist
vim.log = vim.log or {}
vim.log.levels = vim.log.levels or {
    ERROR = 1,
    WARN = 2,
    INFO = 3,
}
