-- lua/gitpilot/ui/init.lua

local M = {}

local utils = require('gitpilot.utils')
local i18n = require('gitpilot.i18n')

-- Safe notify function that works in both test and real environments
function M.notify(msg, level)
    if utils.is_test_env() then
        return true
    end
    
    level = level or vim.log.levels.INFO
    vim.notify(msg, level)
    return true
end

-- Select from a list of items
function M.select(items, opts, on_choice)
    if not items or #items == 0 then
        return nil, i18n.t("ui.no_items")
    end

    opts = opts or {}
    if utils.is_test_env() then
        -- Mock selection in test environment
        if on_choice then
            on_choice(items[1], 1)
        end
        return items[1]
    end

    if not vim.ui or not vim.ui.select then
        return nil, i18n.t("ui.select_not_available")
    end

    vim.ui.select(items, opts, function(choice, idx)
        if on_choice then
            on_choice(choice, idx)
        end
    end)
end

-- Confirm dialog
function M.confirm(msg, opts)
    if utils.is_test_env() then
        return true
    end

    opts = vim.tbl_extend('force', {
        prompt = msg,
        default = true
    }, opts or {})

    return vim.fn.confirm(opts.prompt, "&Yes\n&No", 1, "Question") == 1
end

-- Input dialog
function M.input(opts)
    if utils.is_test_env() then
        return "test_input"
    end

    opts = opts or {}
    local result = nil
    
    vim.ui.input(opts, function(input)
        result = input
    end)
    
    return result
end

return M
