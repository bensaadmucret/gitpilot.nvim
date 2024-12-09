-- lua/gitpilot/features/mirror.lua

local M = {}
local utils = require('gitpilot.utils')
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')

-- Configuration par défaut
local config = {
    mirrors = {},
    auto_sync = false,
    sync_interval = 3600, -- 1 heure par défaut
    sync_on_push = true,
    config_file = vim.fn.stdpath('data') .. '/gitpilot/mirrors.json'
}

-- Charge la configuration des mirrors
local function load_config()
    if utils.is_file(config.config_file) then
        local content = utils.read_file(config.config_file)
        if content then
            local ok, data = pcall(vim.json.decode, content)
            if ok and data then
                config = vim.tbl_deep_extend("force", config, data)
            end
        end
    end
end

-- Sauvegarde la configuration des mirrors
local function save_config()
    local dir = vim.fn.fnamemodify(config.config_file, ':h')
    if not utils.is_directory(dir) then
        vim.fn.mkdir(dir, 'p')
    end
    local content = vim.json.encode(config)
    utils.write_file(config.config_file, content)
end

-- Vérifie si un dépôt est un mirror valide
local function is_valid_mirror(url)
    local success, _ = utils.execute_command(string.format(
        "git ls-remote %s",
        utils.escape_string(url)
    ))
    return success
end

-- Ajoute un nouveau mirror
function M.add_mirror(name, url)
    if not utils.execute_command("git rev-parse --is-inside-work-tree") then
        ui.show_error(i18n.t('error.no_git_repo'))
        return false
    end

    -- Vérifie si le mirror existe déjà
    if config.mirrors[name] then
        ui.show_error(i18n.t('mirror.error.already_exists', {name = name}))
        return false
    end

    -- Vérifie si l'URL est valide
    if not is_valid_mirror(url) then
        ui.show_error(i18n.t('mirror.error.invalid_url'))
        return false
    end

    -- Ajoute le mirror comme remote
    local success, error = utils.execute_command(string.format(
        "git remote add %s %s",
        utils.escape_string(name),
        utils.escape_string(url)
    ))

    if not success then
        ui.show_error(i18n.t('mirror.error.add_failed', {error = error}))
        return false
    end

    -- Configure le mirror
    success = utils.execute_command(string.format([[
        git config remote.%s.mirror true &&
        git config remote.%s.push '+refs/heads/*:refs/heads/*' &&
        git config remote.%s.push '+refs/tags/*:refs/tags/*' &&
        git config remote.%s.push '+refs/notes/*:refs/notes/*'
    ]], name, name, name, name))

    if success then
        config.mirrors[name] = {
            url = url,
            last_sync = nil,
            enabled = true
        }
        save_config()
        ui.show_info(i18n.t('mirror.success.added', {name = name}))
        return true
    else
        -- Nettoie en cas d'échec
        utils.execute_command("git remote remove " .. utils.escape_string(name))
        ui.show_error(i18n.t('mirror.error.config_failed'))
        return false
    end
end

-- Supprime un mirror
function M.remove_mirror(name)
    if not config.mirrors[name] then
        ui.show_error(i18n.t('mirror.error.not_found', {name = name}))
        return false
    end

    local success, error = utils.execute_command(string.format(
        "git remote remove %s",
        utils.escape_string(name)
    ))

    if success then
        config.mirrors[name] = nil
        save_config()
        ui.show_info(i18n.t('mirror.success.removed', {name = name}))
        return true
    else
        ui.show_error(i18n.t('mirror.error.remove_failed', {error = error}))
        return false
    end
end

-- Active/désactive un mirror
function M.toggle_mirror(name)
    if not config.mirrors[name] then
        ui.show_error(i18n.t('mirror.error.not_found', {name = name}))
        return false
    end

    config.mirrors[name].enabled = not config.mirrors[name].enabled
    save_config()
    
    if config.mirrors[name].enabled then
        ui.show_info(i18n.t('mirror.success.enabled', {name = name}))
    else
        ui.show_info(i18n.t('mirror.success.disabled', {name = name}))
    end
    return true
end

-- Synchronise un mirror spécifique
function M.sync_mirror(name)
    if not config.mirrors[name] then
        ui.show_error(i18n.t('mirror.error.not_found', {name = name}))
        return false
    end

    if not config.mirrors[name].enabled then
        ui.show_error(i18n.t('mirror.error.disabled', {name = name}))
        return false
    end

    local success, error = utils.execute_command(string.format(
        "git push --mirror %s",
        utils.escape_string(name)
    ))

    if success then
        config.mirrors[name].last_sync = os.time()
        save_config()
        ui.show_info(i18n.t('mirror.success.synced', {name = name}))
        return true
    else
        ui.show_error(i18n.t('mirror.error.sync_failed', {name = name, error = error}))
        return false
    end
end

-- Synchronise tous les mirrors actifs
function M.sync_all_mirrors()
    local success = true
    for name, mirror in pairs(config.mirrors) do
        if mirror.enabled then
            success = M.sync_mirror(name) and success
        end
    end
    return success
end

-- Configure la synchronisation automatique
function M.configure_auto_sync(enabled, interval)
    config.auto_sync = enabled
    if interval then
        config.sync_interval = interval
    end
    save_config()
end

-- Configure la synchronisation sur push
function M.configure_sync_on_push(enabled)
    config.sync_on_push = enabled
    save_config()
end

-- Retourne la liste des mirrors
function M.list_mirrors()
    local mirrors = {}
    for name, mirror in pairs(config.mirrors) do
        table.insert(mirrors, {
            name = name,
            url = mirror.url,
            enabled = mirror.enabled,
            last_sync = mirror.last_sync
        })
    end
    return mirrors
end

-- Initialise le module
function M.setup()
    load_config()

    -- Configure le timer pour la synchronisation automatique
    if config.auto_sync then
        local timer = vim.loop.new_timer()
        timer:start(0, config.sync_interval * 1000, vim.schedule_wrap(function()
            M.sync_all_mirrors()
        end))
    end

    -- Configure l'autocmd pour la synchronisation sur push
    if config.sync_on_push then
        local group = vim.api.nvim_create_augroup('GitPilotMirror', { clear = true })
        vim.api.nvim_create_autocmd('User', {
            pattern = 'GitPilotPostPush',
            group = group,
            callback = function()
                M.sync_all_mirrors()
            end,
        })
    end
end

return M
