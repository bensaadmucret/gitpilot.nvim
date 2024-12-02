-- lua/gitpilot/ui.lua

local M = {}
local vim = _G.vim
local i18n = require('gitpilot.i18n')

-- S'assurer que vim est disponible
if not vim then
    error("GitPilot requires Neovim")
end

function M.show_error(msg, vars)
    if vars then
        vim.notify(i18n.t(msg, vars), vim.log.levels.ERROR)
    else
        vim.notify(i18n.t(msg), vim.log.levels.ERROR)
    end
end

function M.show_info(msg, vars)
    if vars then
        vim.notify(i18n.t(msg, vars), vim.log.levels.INFO)
    else
        vim.notify(i18n.t(msg), vim.log.levels.INFO)
    end
end

function M.show_warning(msg, vars)
    if vars then
        vim.notify(i18n.t(msg, vars), vim.log.levels.WARN)
    else
        vim.notify(i18n.t(msg), vim.log.levels.WARN)
    end
end

function M.select(items, opts, on_choice)
    if type(items) ~= "table" or #items == 0 then
        M.show_error("ui.no_items")
        return
    end

    if not vim.ui or not vim.ui.select then
        M.show_error("ui.select_not_available")
        return
    end

    vim.ui.select(items, opts, function(choice)
        if choice then
            on_choice(choice)
        end
    end)
end

return M
