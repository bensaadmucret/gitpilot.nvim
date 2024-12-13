-- lua/gitpilot/features/mirror.lua

local M = {}
local utils = require('gitpilot.utils')
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')
local config = require('gitpilot.config')

-- Default configuration
local default_config = {
    mirrors = {},
    auto_sync = false,
    sync_interval = 3600, -- 1 hour by default
    sync_on_push = true,
    config_file = vim.fn.stdpath('data') .. '/gitpilot/mirrors.json',
    log_file = vim.fn.stdpath('data') .. '/gitpilot/mirrors.log',
    max_retries = 3,
    retry_delay = 5, -- 5 seconds
    timeout = 300 -- 5 minutes
}

-- Current configuration
local current_config = vim.deepcopy(default_config)

function M.setup(opts)
    if opts then
        current_config = vim.tbl_deep_extend('force', current_config, opts)
    end
    
    -- Create config directory if it doesn't exist
    local config_dir = vim.fn.fnamemodify(current_config.config_file, ':h')
    vim.fn.mkdir(config_dir, 'p')
    
    -- Load existing mirrors configuration
    M.load_config()
    
    -- Setup auto-sync if enabled
    if current_config.auto_sync then
        M.setup_auto_sync()
    end
    
    -- Configure Git hooks if necessary
    if current_config.sync_on_push then
        M.setup_git_hooks()
    end
end

-- Load mirrors configuration
function M.load_config()
    if utils.is_file(current_config.config_file) then
        local content = utils.read_file(current_config.config_file)
        if content then
            local ok, data = pcall(vim.json.decode, content)
            if ok and data then
                current_config.mirrors = data.mirrors or {}
                current_config.auto_sync = data.auto_sync or default_config.auto_sync
                current_config.sync_interval = data.sync_interval or default_config.sync_interval
                current_config.sync_on_push = data.sync_on_push or default_config.sync_on_push
            end
        end
    end
end

-- Save configuration
local function save_config()
    local data = {
        mirrors = current_config.mirrors,
        auto_sync = current_config.auto_sync,
        sync_interval = current_config.sync_interval,
        sync_on_push = current_config.sync_on_push
    }
    
    local ok, json = pcall(vim.json.encode, data)
    if not ok then
        ui.error(i18n.t('mirror.error.save_config'))
        return false
    end
    
    local fd = vim.loop.fs_open(current_config.config_file, "w", 438)
    if not fd then
        ui.error(i18n.t('mirror.error.save_config'))
        return false
    end
    
    local ok = vim.loop.fs_write(fd, json)
    vim.loop.fs_close(fd)
    
    if not ok then
        ui.error(i18n.t('mirror.error.save_config'))
        return false
    end
    
    return true
end

-- Check if a repository is a valid mirror
local function is_valid_mirror(url)
    local success, _ = utils.execute_command(string.format(
        "git ls-remote %s",
        utils.escape_string(url)
    ))
    return success
end

-- Add a new mirror
function M.add_mirror(name, url)
    if not utils.execute_command("git rev-parse --is-inside-work-tree") then
        ui.show_error(i18n.t('error.no_git_repo'))
        return false
    end

    -- Check if the mirror already exists
    if current_config.mirrors[name] then
        ui.show_error(i18n.t('mirror.error.already_exists', {name = name}))
        return false
    end

    -- Check if the URL is valid
    if not is_valid_mirror(url) then
        ui.show_error(i18n.t('mirror.error.invalid_url'))
        return false
    end

    -- Add the mirror as a remote
    local success, error = utils.execute_command(string.format(
        "git remote add %s %s",
        utils.escape_string(name),
        utils.escape_string(url)
    ))

    if not success then
        ui.show_error(i18n.t('mirror.error.add_failed', {error = error}))
        return false
    end

    -- Configure the mirror
    success = utils.execute_command(string.format([[
        git config remote.%s.mirror true &&
        git config remote.%s.push '+refs/heads/*:refs/heads/*' &&
        git config remote.%s.push '+refs/tags/*:refs/tags/*' &&
        git config remote.%s.push '+refs/notes/*:refs/notes/*'
    ]], name, name, name, name))

    if success then
        current_config.mirrors[name] = {
            url = url,
            last_sync = nil,
            enabled = true
        }
        save_config()
        ui.show_info(i18n.t('mirror.success.added', {name = name}))
        return true
    else
        -- Clean up on failure
        utils.execute_command("git remote remove " .. utils.escape_string(name))
        ui.show_error(i18n.t('mirror.error.config_failed'))
        return false
    end
end

-- Remove a mirror
function M.remove_mirror(name)
    if not current_config.mirrors[name] then
        ui.show_error(i18n.t('mirror.error.not_found', {name = name}))
        return false
    end

    local success, error = utils.execute_command(string.format(
        "git remote remove %s",
        utils.escape_string(name)
    ))

    if success then
        current_config.mirrors[name] = nil
        save_config()
        ui.show_info(i18n.t('mirror.success.removed', {name = name}))
        return true
    else
        ui.show_error(i18n.t('mirror.error.remove_failed', {error = error}))
        return false
    end
end

-- Enable/disable a mirror
function M.toggle_mirror(name)
    if not current_config.mirrors[name] then
        ui.show_error(i18n.t('mirror.error.not_found', {name = name}))
        return false
    end

    current_config.mirrors[name].enabled = not current_config.mirrors[name].enabled
    save_config()
    
    if current_config.mirrors[name].enabled then
        ui.show_info(i18n.t('mirror.success.enabled', {name = name}))
    else
        ui.show_info(i18n.t('mirror.success.disabled', {name = name}))
    end
    return true
end

-- Synchronize a specific mirror
function M.sync_mirror(name)
    if not current_config.mirrors[name] then
        ui.show_error(i18n.t('mirror.error.not_found', {name = name}))
        return false
    end

    if not current_config.mirrors[name].enabled then
        ui.show_error(i18n.t('mirror.error.disabled', {name = name}))
        return false
    end

    local success, error = utils.execute_command(string.format(
        "git push --mirror %s",
        utils.escape_string(name)
    ))

    if success then
        current_config.mirrors[name].last_sync = os.time()
        save_config()
        ui.show_info(i18n.t('mirror.success.synced', {name = name}))
        return true
    else
        ui.show_error(i18n.t('mirror.error.sync_failed', {name = name, error = error}))
        return false
    end
end

-- Synchronize all active mirrors
function M.sync_all_mirrors()
    local success = true
    for name, mirror in pairs(current_config.mirrors) do
        if mirror.enabled then
            success = M.sync_mirror(name) and success
        end
    end
    return success
end

-- Configure automatic synchronization
function M.configure_auto_sync(enabled, interval)
    current_config.auto_sync = enabled
    if interval then
        current_config.sync_interval = interval
    end
    save_config()
end

-- Configure synchronization on push
function M.configure_sync_on_push(enabled)
    current_config.sync_on_push = enabled
    save_config()
end

-- Return the list of mirrors
function M.list_mirrors()
    local mirrors = {}
    for name, mirror in pairs(current_config.mirrors) do
        table.insert(mirrors, {
            name = name,
            url = mirror.url,
            enabled = mirror.enabled,
            last_sync = mirror.last_sync
        })
    end
    return mirrors
end

-- Initialize the module
function M.setup_git_hooks()
    local group = vim.api.nvim_create_augroup('GitPilotMirror', { clear = true })
    vim.api.nvim_create_autocmd('User', {
        pattern = 'GitPilotPostPush',
        group = group,
        callback = function()
            M.sync_all_mirrors()
        end,
    })
end

function M.setup_auto_sync()
    local group = vim.api.nvim_create_augroup('GitPilotMirrorAutoSync', { clear = true })
    vim.api.nvim_create_autocmd('User', {
        pattern = 'GitPilotAutoSync',
        group = group,
        callback = function()
            M.sync_all_mirrors()
        end,
    })
    vim.api.nvim_create_autocmd('VimEnter', {
        group = group,
        callback = function()
            local timer_opts = {}
            timer_opts.recurring = -1  -- Use recurring instead of repeat
            vim.fn.timer_start(current_config.sync_interval * 1000, function()
                vim.api.nvim_notify('GitPilotMirrorAutoSync', vim.lsp.log_levels.INFO, {}, {})
            end, timer_opts)
        end,
    })
end

return M
