-- lua/gitpilot/features/backup_scheduler.lua

local M = {}
local backup = require('gitpilot.features.backup')
local utils = require('gitpilot.utils')
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')

-- Configuration par défaut
local config = {
    enabled = false,
    schedule = {
        on_branch_switch = true,
        on_commit = false,
        on_push = true,
        on_pull = false,
        daily = false,
        weekly = false,
        max_backups = 10,
        retain_days = 30,
    },
    last_backup = nil,
    backup_dir = vim.fn.stdpath('data') .. '/gitpilot/scheduled_backups'
}

-- Charge la configuration
local function load_config()
    local config_file = vim.fn.stdpath('data') .. '/gitpilot/backup_schedule.json'
    if utils.is_file(config_file) then
        local content = utils.read_file(config_file)
        if content then
            local ok, data = pcall(vim.json.decode, content)
            if ok and data then
                config = vim.tbl_deep_extend("force", config, data)
            end
        end
    end
end

-- Sauvegarde la configuration
local function save_config()
    local config_file = vim.fn.stdpath('data') .. '/gitpilot/backup_schedule.json'
    local dir = vim.fn.fnamemodify(config_file, ':h')
    if not utils.is_directory(dir) then
        vim.fn.mkdir(dir, 'p')
    end
    local content = vim.json.encode(config)
    utils.write_file(config_file, content)
end

-- Nettoie les anciens backups
local function cleanup_old_backups()
    if not utils.is_directory(config.backup_dir) then
        return
    end

    local files = vim.fn.glob(config.backup_dir .. '/*.bundle', true, true)
    local now = os.time()
    local max_age = config.schedule.retain_days * 24 * 60 * 60

    -- Trie les fichiers par date de modification
    local file_times = {}
    for _, file in ipairs(files) do
        local stat = vim.loop.fs_stat(file)
        if stat then
            table.insert(file_times, {
                file = file,
                mtime = stat.mtime.sec
            })
        end
    end
    table.sort(file_times, function(a, b) return a.mtime > b.mtime end)

    -- Supprime les fichiers trop anciens ou au-delà de la limite
    for i, file_info in ipairs(file_times) do
        local should_delete = false
        
        -- Vérifie l'âge du fichier
        if now - file_info.mtime > max_age then
            should_delete = true
        end
        
        -- Vérifie le nombre maximum de backups
        if i > config.schedule.max_backups then
            should_delete = true
        end
        
        if should_delete then
            os.remove(file_info.file)
        end
    end
end

-- Vérifie si un backup est nécessaire
local function should_backup()
    if not config.enabled then
        return false
    end

    -- Vérifie si le répertoire est un dépôt git
    if not utils.execute_command("git rev-parse --is-inside-work-tree") then
        return false
    end

    -- Vérifie la date du dernier backup
    if config.last_backup then
        local now = os.time()
        local last = config.last_backup
        
        if config.schedule.daily and (now - last) < (24 * 60 * 60) then
            return false
        end
        
        if config.schedule.weekly and (now - last) < (7 * 24 * 60 * 60) then
            return false
        end
    end

    return true
end

-- Crée un backup planifié
local function create_scheduled_backup(reason)
    if not should_backup() then
        return
    end

    -- Crée le répertoire de backup si nécessaire
    if not utils.is_directory(config.backup_dir) then
        vim.fn.mkdir(config.backup_dir, 'p')
    end

    -- Obtient la branche courante
    local success, branch = utils.execute_command("git branch --show-current")
    if not success then
        return
    end

    -- Crée le backup
    local timestamp = os.date(backup.config.backup_format)
    local backup_name = string.format("scheduled_%s_%s_%s.bundle",
        reason,
        branch,
        timestamp
    )
    local backup_path = config.backup_dir .. '/' .. backup_name

    success = backup.backup_branch(branch)
    if success then
        config.last_backup = os.time()
        save_config()
        cleanup_old_backups()
    end
end

-- Configure les autocmd pour les événements
local function setup_events()
    local group = vim.api.nvim_create_augroup('GitPilotBackupScheduler', { clear = true })

    -- Backup lors du changement de branche
    if config.schedule.on_branch_switch then
        vim.api.nvim_create_autocmd('User', {
            pattern = 'GitPilotPostBranchSwitch',
            group = group,
            callback = function()
                create_scheduled_backup('branch_switch')
            end,
        })
    end

    -- Backup lors d'un commit
    if config.schedule.on_commit then
        vim.api.nvim_create_autocmd('User', {
            pattern = 'GitPilotPostCommit',
            group = group,
            callback = function()
                create_scheduled_backup('commit')
            end,
        })
    end

    -- Backup lors d'un push
    if config.schedule.on_push then
        vim.api.nvim_create_autocmd('User', {
            pattern = 'GitPilotPostPush',
            group = group,
            callback = function()
                create_scheduled_backup('push')
            end,
        })
    end

    -- Backup lors d'un pull
    if config.schedule.on_pull then
        vim.api.nvim_create_autocmd('User', {
            pattern = 'GitPilotPostPull',
            group = group,
            callback = function()
                create_scheduled_backup('pull')
            end,
        })
    end
end

-- Configure le timer pour les backups périodiques
local function setup_timer()
    local timer = vim.loop.new_timer()
    if not timer then
        return
    end

    -- Vérifie toutes les heures si un backup est nécessaire
    timer:start(0, 3600000, vim.schedule_wrap(function()
        if config.schedule.daily or config.schedule.weekly then
            create_scheduled_backup('periodic')
        end
    end))
end

-- Initialise le planificateur
function M.setup(opts)
    if opts then
        config = vim.tbl_deep_extend("force", config, opts)
    end
    
    load_config()
    setup_events()
    setup_timer()
end

-- Active/désactive la planification
function M.toggle()
    config.enabled = not config.enabled
    save_config()
    if config.enabled then
        ui.show_info(i18n.t('schedule.enabled'))
    else
        ui.show_info(i18n.t('schedule.disabled'))
    end
end

-- Met à jour la configuration
function M.update_config(new_config)
    config.schedule = vim.tbl_deep_extend("force", config.schedule, new_config)
    save_config()
    setup_events()
end

-- Retourne la configuration actuelle
function M.get_config()
    return vim.deepcopy(config.schedule)
end

return M
