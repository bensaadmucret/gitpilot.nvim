-- lua/gitpilot/menu.lua

local M = {}
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')
local utils = require('gitpilot.utils')
local actions = require('gitpilot.actions')

-- Configuration
local config = {
    use_icons = true,
    confirm_actions = true,
    auto_refresh = true
}

-- Menu state
local current_menu = 'main'

-- Icons
local icons = {
    branch = '🌿',
    commit = '📝',
    remote = '🔄',
    tag = '🏷️',
    stash = '📦',
    search = '🔍',
    rebase = '♻️',
    backup = '💾',
    back = '⬅️',
    help = '❓'
}

function M.setup(opts)
    config = vim.tbl_extend('force', config, opts or {})
end

function M.get_current_menu()
    return current_menu
end

local function get_menu_title(menu_type)
    local title = i18n.t('menu.' .. menu_type .. '_title')
    if menu_type == 'main' then
        local success, branch = utils.execute_command('git branch --show-current')
        if success and branch then
            title = title .. ' (' .. branch .. ')'
        end
    end
    return title
end

-- Add icon to menu item if configured
local function add_icon(text, icon)
    if not text then return "" end
    if config.use_icons and icon then
        return icon .. " " .. text
    end
    return text
end

local function get_menu_items(menu_type)
    local items = {}
    
    if menu_type == 'main' then
        table.insert(items, add_icon(i18n.t('menu.branches'), icons.branch))
        table.insert(items, add_icon(i18n.t('menu.commits'), icons.commit))
        table.insert(items, add_icon(i18n.t('menu.remotes'), icons.remote))
        table.insert(items, add_icon(i18n.t('menu.tags'), icons.tag))
        table.insert(items, add_icon(i18n.t('menu.stash'), icons.stash))
        table.insert(items, add_icon(i18n.t('menu.search'), icons.search))
        table.insert(items, add_icon(i18n.t('menu.rebase'), icons.rebase))
        table.insert(items, add_icon(i18n.t('menu.backup'), icons.backup))
        table.insert(items, add_icon(i18n.t('menu.pull_requests'), icons.remote))
        table.insert(items, add_icon(i18n.t('menu.help'), icons.help))
    elseif menu_type == 'branch' then
        table.insert(items, add_icon(i18n.t('branch.create_new'), icons.branch))
        table.insert(items, add_icon(i18n.t('branch.checkout'), icons.branch))
        table.insert(items, add_icon(i18n.t('branch.merge'), icons.branch))
        table.insert(items, add_icon(i18n.t('branch.delete'), icons.branch))
        table.insert(items, add_icon(i18n.t('branch.push'), icons.branch))
        table.insert(items, add_icon(i18n.t('branch.pull'), icons.branch))
        table.insert(items, add_icon(i18n.t('branch.rebase'), icons.branch))
        table.insert(items, add_icon(i18n.t('branch.refresh'), icons.branch))
        table.insert(items, add_icon(i18n.t('menu.back'), icons.back))
    elseif menu_type == 'commit' then
        table.insert(items, add_icon(i18n.t('commit.create'), icons.commit))
        table.insert(items, add_icon(i18n.t('menu.back'), icons.back))
    elseif menu_type == 'help' then
        table.insert(items, add_icon(i18n.t('help.commit'), icons.commit))
        table.insert(items, add_icon(i18n.t('help.branch'), icons.branch))
        table.insert(items, add_icon(i18n.t('help.stash'), icons.stash))
        table.insert(items, add_icon(i18n.t('help.rebase'), icons.rebase))
        table.insert(items, add_icon(i18n.t('help.tag'), icons.tag))
        table.insert(items, add_icon(i18n.t('menu.back'), icons.back))
    end
    
    return items
end

local function handle_menu_selection(menu_type, selected, context)
    if not selected then
        return
    end
    
    -- Remove icon if present
    local text = selected:gsub('^[^ ]* ', '')
    
    -- Handle back navigation
    if text == i18n.t('menu.back') then
        current_menu = 'main'
        vim.schedule(function()
            M.show_main_menu(context)
        end)
        return
    end
    
    -- Handle menu item selection
    local action = nil
    
    if menu_type == 'main' then
        if text == i18n.t('menu.branches') then
            current_menu = 'branch'
            vim.schedule(function()
                M.show_menu('branch', context)
            end)
            return
        elseif text == i18n.t('menu.commits') then
            current_menu = 'commit'
            vim.schedule(function()
                M.show_menu('commit', context)
            end)
            return
        elseif text == i18n.t('menu.pull_requests') then
            require('gitpilot.features.pull_request_ui').show_pull_requests()
            return
        elseif text == i18n.t('menu.help') then
            current_menu = 'help'
            vim.schedule(function()
                M.show_help_menu(context)
            end)
            return
        end
    elseif menu_type == 'branch' then
        if text == i18n.t('branch.create_new') then
            action = 'create'
        elseif text == i18n.t('branch.checkout') then
            action = 'checkout'
        elseif text == i18n.t('branch.merge') then
            action = 'merge'
        elseif text == i18n.t('branch.delete') then
            action = 'delete'
        elseif text == i18n.t('branch.push') then
            action = 'push'
        elseif text == i18n.t('branch.pull') then
            action = 'pull'
        elseif text == i18n.t('branch.rebase') then
            action = 'rebase'
        elseif text == i18n.t('branch.refresh') then
            action = 'refresh'
        end
    elseif menu_type == 'commit' then
        if text == i18n.t('commit.create') then
            action = 'create'
        end
    elseif menu_type == 'help' then
        if text == i18n.t('help.commit') then
            require('gitpilot.features.help').show_help('commit')
        elseif text == i18n.t('help.branch') then
            require('gitpilot.features.help').show_help('branch')
        elseif text == i18n.t('help.stash') then
            require('gitpilot.features.help').show_help('stash')
        elseif text == i18n.t('help.rebase') then
            require('gitpilot.features.help').show_help('rebase')
        elseif text == i18n.t('help.tag') then
            require('gitpilot.features.help').show_help('tag')
        end
    end
    
    if action then
        actions.handle_action(menu_type, action, context)
    end
end

function M.show_main_menu(context)
    current_menu = 'main'
    local items = get_menu_items('main')
    local opts = {
        title = get_menu_title('main'),
        callback = function(selected)
            handle_menu_selection('main', selected, context)
        end
    }
    ui.float_window(items, opts)
end

function M.show_menu(menu_type, context)
    if not menu_type then
        return
    end
    
    local items = get_menu_items(menu_type)
    if not items or #items == 0 then
        ui.show_error(i18n.t('error.invalid_menu'))
        return
    end
    
    local opts = {
        title = get_menu_title(menu_type),
        callback = function(selected)
            handle_menu_selection(menu_type, selected, context)
        end
    }
    
    ui.float_window(items, opts)
end

function M.show_help_menu(context)
    current_menu = 'help'
    local items = get_menu_items('help')
    local opts = {
        title = i18n.t("help.menu_title"),
        callback = function(selected)
            handle_menu_selection('help', selected, context)
        end
    }
    ui.float_window(items, opts)
end

return M
