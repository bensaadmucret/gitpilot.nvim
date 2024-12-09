-- lua/gitpilot/features/backup_ui.lua

local M = {}
local backup = require('gitpilot.features.backup')
local ui = require('gitpilot.ui')
local utils = require('gitpilot.utils')
local i18n = require('gitpilot.i18n')
local config = require('gitpilot.config')

-- Configuration par défaut
local default_config = {
    window = {
        width = 0.8,
        height = 0.6,
        border = "rounded"
    },
    confirm_actions = true
}

-- Configuration actuelle
local current_config = vim.deepcopy(default_config)

-- Configure le module
function M.setup(opts)
    current_config = vim.tbl_deep_extend("force", current_config, opts or {})
    
    -- Configure le module de backup
    backup.setup({
        backup_dir = config.get("backup.directory"),
        auto_backup = config.get("backup.auto_backup"),
        backup_on_switch = config.get("backup.backup_on_switch"),
        max_backups = config.get("backup.max_backups"),
        include_stashes = config.get("backup.include_stashes"),
        backup_format = config.get("backup.format")
    })
    
    -- Ajoute l'entrée de menu pour les backups
    ui.add_menu_item({
        label = i18n.t("backup.menu.title"),
        description = i18n.t("backup.menu.description"),
        action = M.show_backup_menu
    })
end

-- Menu principal de gestion des backups
function M.show_backup_menu()
    local choices = {
        { text = i18n.t('backup.create'), value = 'create' },
        { text = i18n.t('backup.restore'), value = 'restore' },
        { text = i18n.t('backup.list'), value = 'list' },
        { text = i18n.t('backup.export'), value = 'export' },
        { text = i18n.t('backup.import'), value = 'import' },
        { text = i18n.t('backup.mirror'), value = 'mirror' },
        { text = i18n.t('backup.sync'), value = 'sync' },
        { text = i18n.t('backup.delete'), value = 'delete' },
        { text = i18n.t('version.restore'), value = 'version' },
        { text = i18n.t('schedule.configure'), value = 'schedule' },
    }

    ui.select(choices, {
        prompt = i18n.t('backup.title'),
        format_item = function(item)
            return item.text
        end
    }, function(choice)
        if choice then
            if choice.value == 'create' then
                M.create_backup()
            elseif choice.value == 'restore' then
                M.restore_backup()
            elseif choice.value == 'list' then
                M.list_backups()
            elseif choice.value == 'export' then
                M.export_patch()
            elseif choice.value == 'import' then
                M.import_patch()
            elseif choice.value == 'mirror' then
                M.configure_mirror()
            elseif choice.value == 'sync' then
                backup.sync_mirror()
            elseif choice.value == 'delete' then
                M.delete_backup()
            elseif choice.value == 'version' then
                M.show_version_menu()
            elseif choice.value == 'schedule' then
                M.show_schedule_menu()
            end
        end
    end)
end

-- Crée un backup de la branche courante
function M.create_backup()
    local success, current_branch = utils.execute_command("git branch --show-current")
    if not success then
        ui.show_error(i18n.t('error.no_git_repo'))
        return
    end

    ui.input({
        prompt = i18n.t('backup.info.enter_branch'),
        default = current_branch,
    }, function(branch_name)
        if branch_name then
            backup.backup_branch(branch_name)
        end
    end)
end

-- Restaure un backup existant
function M.restore_backup()
    local backups = backup.list_backups()
    if #backups == 0 then
        ui.show_info(i18n.t('backup.info.no_backups'))
        return
    end

    local choices = {}
    for _, b in ipairs(backups) do
        table.insert(choices, {
            text = string.format("%s (%s)", b.name, b.formatted_time),
            value = b
        })
    end

    ui.select(choices, {
        prompt = i18n.t('backup.info.select_backup'),
        format_item = function(item)
            return item.text
        end
    }, function(choice)
        if choice then
            ui.input({
                prompt = i18n.t('backup.info.enter_branch'),
                default = "restore_" .. os.date("%Y%m%d"),
            }, function(branch_name)
                if branch_name then
                    backup.restore_backup(choice.value.path, branch_name)
                end
            end)
        end
    end)
end

-- Liste tous les backups disponibles
function M.list_backups()
    local backups = backup.list_backups()
    if #backups == 0 then
        ui.show_info(i18n.t('backup.info.no_backups'))
        return
    end

    local lines = {}
    for _, b in ipairs(backups) do
        table.insert(lines, string.format(
            "%s (%s, %.2f MB)",
            b.name,
            b.formatted_time,
            b.size / 1024 / 1024
        ))
    end

    vim.api.nvim_echo({{table.concat(lines, '\n'), 'Normal'}}, true, {})
end

-- Exporte une branche en patch
function M.export_patch()
    local success, current_branch = utils.execute_command("git branch --show-current")
    if not success then
        ui.show_error(i18n.t('error.no_git_repo'))
        return
    end

    ui.input({
        prompt = i18n.t('backup.info.enter_branch'),
        default = current_branch,
    }, function(branch_name)
        if branch_name then
            ui.input({
                prompt = i18n.t('backup.info.enter_path'),
                default = vim.fn.getcwd() .. "/patches",
            }, function(path)
                if path then
                    backup.export_patch(branch_name, path)
                end
            end)
        end
    end)
end

-- Importe un patch
function M.import_patch()
    ui.input({
        prompt = i18n.t('backup.info.enter_path'),
        default = vim.fn.getcwd() .. "/patches",
    }, function(path)
        if path then
            backup.import_patch(path)
        end
    end)
end

-- Configure un mirror repository
function M.configure_mirror()
    ui.input({
        prompt = i18n.t('backup.info.enter_mirror'),
    }, function(url)
        if url then
            backup.setup_mirror(url)
        end
    end)
end

-- Supprime un backup
function M.delete_backup()
    local backups = backup.list_backups()
    if #backups == 0 then
        ui.show_info(i18n.t('backup.info.no_backups'))
        return
    end

    local choices = {}
    for _, b in ipairs(backups) do
        table.insert(choices, {
            text = string.format("%s (%s)", b.name, b.formatted_time),
            value = b
        })
    end

    ui.select(choices, {
        prompt = i18n.t('backup.info.select_backup'),
        format_item = function(item)
            return item.text
        end
    }, function(choice)
        if choice then
            local success = os.remove(choice.value.path)
            if success then
                ui.show_info(i18n.t('backup.success.deleted'))
            else
                ui.show_error(i18n.t('backup.error.delete_failed', {error = "File not found"}))
            end
        end
    end)
end

-- Affiche le menu de restauration de versions
function M.show_version_menu()
    local commits = backup.get_commit_history()
    if #commits == 0 then
        ui.show_error(i18n.t('version.error.no_commits'))
        return
    end

    local choices = {}
    for _, commit in ipairs(commits) do
        table.insert(choices, {
            text = string.format("[%s] %s (%s - %s)",
                commit.hash:sub(1, 7),
                commit.subject,
                commit.date,
                commit.author
            ),
            value = commit
        })
    end

    ui.select(choices, {
        prompt = i18n.t('version.select_commit'),
        format_item = function(item)
            return item.text
        end
    }, function(choice)
        if choice then
            -- Affiche les détails du commit
            local diff = backup.get_commit_diff(choice.value.hash)
            if diff then
                vim.api.nvim_echo({{diff, 'Normal'}}, true, {})
            end

            -- Demande confirmation et nom de la branche
            ui.confirm(i18n.t('version.confirm_restore'), function(confirmed)
                if confirmed then
                    ui.input({
                        prompt = i18n.t('version.enter_branch_name'),
                        default = "restore_" .. choice.value.hash:sub(1, 7),
                    }, function(branch_name)
                        if branch_name then
                            backup.restore_version(choice.value.hash, branch_name)
                        end
                    end)
                end
            end)
        end
    end)
end

-- Affiche le menu de planification des backups
function M.show_schedule_menu()
    local scheduler = require('gitpilot.features.backup_scheduler')
    local current_config = scheduler.get_config()

    local choices = {
        {
            text = i18n.t('schedule.toggle'),
            value = 'toggle'
        },
        {
            text = i18n.t('schedule.on_branch_switch') .. (current_config.on_branch_switch and ' ✓' or ' ✗'),
            value = 'on_branch_switch'
        },
        {
            text = i18n.t('schedule.on_commit') .. (current_config.on_commit and ' ✓' or ' ✗'),
            value = 'on_commit'
        },
        {
            text = i18n.t('schedule.on_push') .. (current_config.on_push and ' ✓' or ' ✗'),
            value = 'on_push'
        },
        {
            text = i18n.t('schedule.on_pull') .. (current_config.on_pull and ' ✓' or ' ✗'),
            value = 'on_pull'
        },
        {
            text = i18n.t('schedule.daily') .. (current_config.daily and ' ✓' or ' ✗'),
            value = 'daily'
        },
        {
            text = i18n.t('schedule.weekly') .. (current_config.weekly and ' ✓' or ' ✗'),
            value = 'weekly'
        },
        {
            text = i18n.t('schedule.configure_retention'),
            value = 'retention'
        }
    }

    ui.select(choices, {
        prompt = i18n.t('schedule.title'),
        format_item = function(item)
            return item.text
        end
    }, function(choice)
        if choice then
            if choice.value == 'toggle' then
                scheduler.toggle()
            elseif choice.value == 'retention' then
                M.configure_retention()
            else
                -- Inverse la valeur du paramètre sélectionné
                local new_config = {}
                new_config[choice.value] = not current_config[choice.value]
                scheduler.update_config(new_config)
                M.show_schedule_menu()  -- Rafraîchit le menu
            end
        end
    end)
end

-- Configure les paramètres de rétention
function M.configure_retention()
    local scheduler = require('gitpilot.features.backup_scheduler')
    local current_config = scheduler.get_config()

    ui.input({
        prompt = i18n.t('schedule.max_backups'),
        default = tostring(current_config.max_backups),
    }, function(max_backups)
        if max_backups then
            max_backups = tonumber(max_backups)
            if max_backups and max_backups > 0 then
                ui.input({
                    prompt = i18n.t('schedule.retain_days'),
                    default = tostring(current_config.retain_days),
                }, function(retain_days)
                    if retain_days then
                        retain_days = tonumber(retain_days)
                        if retain_days and retain_days > 0 then
                            scheduler.update_config({
                                max_backups = max_backups,
                                retain_days = retain_days
                            })
                            M.show_schedule_menu()
                        end
                    end
                end)
            end
        end
    end)
end

return M
