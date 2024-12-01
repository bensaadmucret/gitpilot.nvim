-- Minimal init.lua for running tests
local plugin_root = vim.fn.getcwd()

-- Add current directory to package path
local path = vim.fn.getcwd()
vim.opt.runtimepath:append(path)

-- Set up test environment
local helpers = require('test.helpers')
helpers.setup()

-- Set up core vim mocks first
_G.vim = _G.vim or {}

-- Get temporary directory
local function get_tmpdir()
    return os.getenv('TMPDIR') or '/tmp'
end

-- Set up core vim components first
vim.api = vim.api or {}
vim.api.nvim_command = function() end
vim.api.nvim_create_buf = function() return 0 end
vim.api.nvim_buf_set_lines = function() end
vim.api.nvim_win_get_cursor = function() return {1, 0} end
vim.api.nvim_win_set_cursor = function() end
vim.api.nvim_win_get_width = function() return 80 end
vim.api.nvim_win_get_height = function() return 24 end
vim.api.nvim_buf_get_lines = function() return {} end
vim.api.nvim_buf_set_option = function() end
vim.api.nvim_win_set_option = function() end
vim.api.nvim_buf_get_option = function() return "" end
vim.api.nvim_win_get_option = function() return "" end

-- Set up vim.fn mocks
vim.fn = vim.fn or {}
vim.fn.stdpath = function(what)
    if what == 'data' then
        return get_tmpdir() .. '/nvim-data'
    elseif what == 'config' then
        return get_tmpdir() .. '/nvim-config'
    elseif what == 'cache' then
        return get_tmpdir() .. '/nvim-cache'
    end
end

-- Set up remaining vim.fn mocks
vim.fn = vim.tbl_extend('force', vim.fn, {
    system = function(cmd)
        return vim.env.GIT_RESPONSE or ""
    end,
    getcwd = function()
        return plugin_root
    end,
    expand = function(path)
        return path:gsub('%~', os.getenv('HOME') or '/home/user')
    end,
    getline = function() return "" end,
    line = function() return 0 end,
    bufnr = function() return 0 end,
    win_gotoid = function() return true end,
    input = function() return "" end,
    confirm = function() return 1 end
})

-- Mock vim.notify
vim.notify = function(msg, level, opts)
    local ui = require('gitpilot.ui')
    ui.notify(msg, level, opts)
end

-- Mock vim.ui.input
vim.ui = vim.ui or {}
vim.ui.input = function(opts, callback)
    local ui = require('gitpilot.ui')
    return ui.input(opts, callback)
end

-- Mock vim.ui.select
vim.ui.select = function(items, opts, callback)
    local ui = require('gitpilot.ui')
    return ui.select(items, opts, callback)
end

-- Set up vim.log.levels
vim.log = vim.log or {}
vim.log.levels = {
    ERROR = 1,
    WARN = 2,
    INFO = 3,
    DEBUG = 4,
    TRACE = 5
}

-- Set up test configuration
require('gitpilot').setup({
    ui = {
        test_mode = true,
        confirm_actions = false
    },
    i18n = {
        test_mode = true
    }
})

-- Add plugin to runtime path
vim.opt.runtimepath:append(plugin_root)
