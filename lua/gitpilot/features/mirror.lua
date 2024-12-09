-- lua/gitpilot/features/mirror.lua

local M = {}
local utils = require('gitpilot.utils')
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')
local config = require('gitpilot.config')

-- Configuration par défaut
local default_config = {
    mirrors = {},
    auto_sync = false,
    sync_interval = 3600, -- 1 heure par défaut
    sync_on_push = true,
    config_file = vim.fn.stdpath('data') .. '/gitpilot/mirrors.json',
    log_file = vim.fn.stdpath('data') .. '/gitpilot/mirrors.log',
    max_retries = 3,
    retry_delay = 5, -- 5 secondes
    timeout = 300 -- 5 minutes
}

-- Configuration actuelle
local current_config = vim.deepcopy(default_config)

-- Configure le module
function M.setup(opts)
    current_config = vim.tbl_deep_extend("force", current_config, opts or {})
    
    -- Crée le répertoire de configuration s'il n'existe pas
    local config_dir = vim.fn.fnamemodify(current_config.config_file, ":h")
    vim.fn.mkdir(config_dir, "p")
    
    -- Charge la configuration existante
    load_config()
    
    -- Configure les hooks Git si nécessaire
    if current_config.sync_on_push then
        setup_git_hooks()
    end
end

-- Charge la configuration des mirrors
local function load_config()
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

-- Sauvegarde la configuration
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
    if current_config.mirrors[name] then
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
        current_config.mirrors[name] = {
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

-- Active/désactive un mirror
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

-- Synchronise un mirror spécifique
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

-- Synchronise tous les mirrors actifs
function M.sync_all_mirrors()
    local success = true
    for name, mirror in pairs(current_config.mirrors) do
        if mirror.enabled then
            success = M.sync_mirror(name) and success
        end
    end
    return success
end

-- Configure la synchronisation automatique
function M.configure_auto_sync(enabled, interval)
    current_config.auto_sync = enabled
    if interval then
        current_config.sync_interval = interval
    end
    save_config()
end

-- Configure la synchronisation sur push
function M.configure_sync_on_push(enabled)
    current_config.sync_on_push = enabled
    save_config()
end

-- Retourne la liste des mirrors
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

-- Initialise le module
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

return M
