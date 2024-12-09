-- lua/gitpilot/ui.lua

local utils = require('gitpilot.utils')
local i18n = require('gitpilot.i18n')

local M = {}

-- Notification levels
M.levels = {
    ERROR = "error",
    WARNING = "warn",
    INFO = "info",
    DEBUG = "debug"
}

-- Local configuration
local config = {
    use_icons = true,
    icons = {
        error = "❌ ",
        warning = "⚠️ ",
        info = "ℹ️ ",
        success = "✅ ",
        question = "❓ "
    },
    window = {
        width = 60,
        height = 20,
        border = "rounded",
        title = true,
        footer = true
    },
    confirm = {
        yes_text = "confirm.yes",
        no_text = "confirm.no",
        default = false
    }
}

-- Menu items storage
local menu_items = {}

-- Module initialization
function M.setup(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})
end

-- Internal function to format message
local function format_message(msg, level)
    if not config.use_icons then
        return msg
    end
    
    local icon = ""
    if level == M.levels.ERROR then
        icon = config.icons.error
    elseif level == M.levels.WARNING then
        icon = config.icons.warning
    elseif level == M.levels.INFO then
        icon = config.icons.info
    elseif level == "success" then
        icon = config.icons.success
    elseif level == "question" then
        icon = config.icons.question
    end
    
    return icon .. msg
end

-- Add a menu item
function M.add_menu_item(item)
    if not item or not item.label or not item.action then
        error("Menu item must have a label and an action")
        return
    end
    table.insert(menu_items, item)
end

-- Get all menu items
function M.get_menu_items()
    return menu_items
end

-- Display a message with notification
function M.show_message(msg, level)
    if not msg then return false end
    
    level = level or M.levels.INFO
    
    if utils.is_test_env() then
        return true
    end
    
    if vim and vim.notify then
        local notify_level = vim.log.levels[level:upper()] or vim.log.levels.INFO
        vim.notify(format_message(msg, level), notify_level)
        return true
    end
    
    return false
end

-- Display an error message
function M.show_error(msg)
    return M.show_message(msg, M.levels.ERROR)
end

-- Display a warning message
function M.show_warning(msg)
    return M.show_message(msg, M.levels.WARNING)
end

-- Display a success message
function M.show_success(msg)
    return M.show_message(format_message(msg, "success"), M.levels.INFO)
end

-- Selection from a list of items
function M.select(items, opts, callback)
    if not items or #items == 0 then
        return nil
    end
    
    opts = vim.tbl_deep_extend("force", {
        prompt = i18n.t("ui.select_prompt"),
        format_item = function(item) return item end,
        kind = "gitpilot"
    }, opts or {})
    
    if utils.is_test_env() then
        if callback then
            callback(items[1])
        end
        return items[1]
    end
    
    if vim and vim.ui and vim.ui.select then
        vim.ui.select(items, opts, function(choice)
            if callback then
                callback(choice)
            end
        end)
    end
end

-- User input request
function M.input(opts, callback)
    opts = vim.tbl_deep_extend("force", {
        prompt = i18n.t("ui.input_prompt"),
        default = "",
        completion = "file"
    }, opts or {})
    
    if utils.is_test_env() then
        if callback then
            callback("test_input")
        end
        return "test_input"
    end
    
    if vim and vim.ui and vim.ui.input then
        vim.ui.input(opts, function(input)
            if callback then
                callback(input)
            end
        end)
    end
end

-- Display a confirmation window
function M.confirm(opts)
    opts = vim.tbl_deep_extend("force", {
        prompt = i18n.t("confirm.prompt"),
        callback = function(confirmed) end,
        default = config.confirm.default
    }, opts or {})
    
    if utils.is_test_env() then
        opts.callback(true)
        return
    end
    
    local choices = {
        format_message(i18n.t(config.confirm.yes_text), "success"),
        format_message(i18n.t(config.confirm.no_text), "error")
    }
    
    M.select(choices, {
        prompt = format_message(opts.prompt, "question"),
        format_item = function(item) return item end
    }, function(choice)
        if choice then
            opts.callback(choice == choices[1])
        else
            opts.callback(false)
        end
    end)
end

-- Display a floating window
function M.float_window(content, opts)
    opts = vim.tbl_deep_extend("force", {
        width = config.window.width,
        height = config.window.height,
        border = config.window.border,
        title = config.window.title and " GitPilot " or nil,
        footer = config.window.footer and " Press q to close " or nil
    }, opts or {})
    
    if utils.is_test_env() then
        return true
    end
    
    -- Create the buffer
    local buf = vim.api.nvim_create_buf(false, true)
    if not buf then return false end
    
    -- Configure the buffer
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    
    -- Calculate dimensions
    local win_width = vim.api.nvim_get_option("columns")
    local win_height = vim.api.nvim_get_option("lines")
    
    local width = math.min(opts.width, win_width - 4)
    local height = math.min(opts.height, win_height - 4)
    
    local row = math.floor((win_height - height) / 2)
    local col = math.floor((win_width - width) / 2)
    
    -- Configure the window
    local win_opts = {
        relative = 'editor',
        row = row,
        col = col,
        width = width,
        height = height,
        style = 'minimal',
        border = opts.border,
        title = opts.title,
        footer = opts.footer
    }
    
    -- Create the window
    local win = vim.api.nvim_open_win(buf, true, win_opts)
    if not win then return false end
    
    -- Configure mappings
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', {
        noremap = true,
        silent = true
    })
    
    return true
end

return M
