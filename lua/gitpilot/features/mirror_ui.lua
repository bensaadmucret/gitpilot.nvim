-- lua/gitpilot/features/mirror_ui.lua

local M = {}
local mirror = require('gitpilot.features.mirror')
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')
local config = require('gitpilot.config')

-- Configuration par défaut
local default_config = {
    window = {
        width = 0.8,
        height = 0.6,
        border = "rounded"
    },
    list = {
        show_status = true,
        show_last_sync = true,
        show_auto_sync = true
    },
    confirm_actions = true,
    help = {
        show_intro = true,
        show_tips = true
    }
}

-- Configuration actuelle
local current_config = vim.deepcopy(default_config)

-- Configure le module
function M.setup(opts)
    current_config = vim.tbl_deep_extend("force", current_config, opts or {})
    
    -- Configure le module mirror
    mirror.setup({
        auto_sync = config.get("mirror.auto_sync"),
        sync_interval = config.get("mirror.sync_interval"),
        sync_on_push = config.get("mirror.sync_on_push"),
        max_retries = config.get("mirror.max_retries"),
        retry_delay = config.get("mirror.retry_delay"),
        timeout = config.get("mirror.timeout")
    })
    
    -- Ajoute l'entrée de menu pour les mirrors
    ui.add_menu_item({
        label = i18n.t("mirror.menu.title"),
        description = i18n.t("mirror.menu.description"),
        action = M.show_mirror_menu
    })
end

-- Affiche le menu principal des mirrors
function M.show_mirror_menu()
    -- Affiche d'abord une introduction aux mirrors
    vim.api.nvim_echo({
        {i18n.t('mirror.help.what_is') .. "\n\n", "Title"},
        {i18n.t('mirror.help.why_use') .. "\n\n", "Normal"},
        {i18n.t('mirror.help.how_to') .. "\n", "Normal"}
    }, true, {})

    local choices = {
        { text = i18n.t('mirror.add'), value = 'add', help = i18n.t('mirror.help.what_is') },
        { text = i18n.t('mirror.list'), value = 'list' },
        { text = i18n.t('mirror.sync_all'), value = 'sync_all' },
        { text = i18n.t('mirror.configure'), value = 'configure', help = i18n.t('mirror.help.auto_sync') },
    }

    ui.select(choices, {
        prompt = i18n.t('mirror.title'),
        format_item = function(item)
            return item.text .. (item.help and "\n   " .. item.help or "")
        end
    }, function(choice)
        if choice then
            if choice.value == 'add' then
                M.add_mirror()
            elseif choice.value == 'list' then
                M.list_mirrors()
            elseif choice.value == 'sync_all' then
                mirror.sync_all_mirrors()
            elseif choice.value == 'configure' then
                M.show_config_menu()
            end
        end
    end)
end

-- Ajoute un nouveau mirror
function M.add_mirror()
    ui.input({
        prompt = i18n.t('mirror.enter_name'),
    }, function(name)
        if name then
            ui.input({
                prompt = i18n.t('mirror.enter_url'),
            }, function(url)
                if url then
                    mirror.add_mirror(name, url)
                end
            end)
        end
    end)
end

-- Liste et gère les mirrors existants
function M.list_mirrors()
    local mirrors = mirror.list_mirrors()
    if #mirrors == 0 then
        ui.show_info(i18n.t('mirror.no_mirrors'))
        return
    end

    local choices = {}
    for _, m in ipairs(mirrors) do
        local last_sync = m.last_sync and os.date("%Y-%m-%d %H:%M:%S", m.last_sync) or i18n.t('mirror.never_synced')
        table.insert(choices, {
            text = string.format("%s (%s) [%s] - %s",
                m.name,
                m.url,
                m.enabled and "✓" or "✗",
                last_sync
            ),
            value = m
        })
    end

    ui.select(choices, {
        prompt = i18n.t('mirror.select_mirror'),
        format_item = function(item)
            return item.text
        end
    }, function(choice)
        if choice then
            M.show_mirror_actions(choice.value)
        end
    end)
end

-- Affiche les actions disponibles pour un mirror
function M.show_mirror_actions(mirror_info)
    local choices = {
        { text = i18n.t('mirror.sync'), value = 'sync' },
        { text = mirror_info.enabled and i18n.t('mirror.disable') or i18n.t('mirror.enable'), value = 'toggle' },
        { text = i18n.t('mirror.remove'), value = 'remove' },
    }

    ui.select(choices, {
        prompt = string.format(i18n.t('mirror.actions_for'), mirror_info.name),
        format_item = function(item)
            return item.text
        end
    }, function(choice)
        if choice then
            if choice.value == 'sync' then
                mirror.sync_mirror(mirror_info.name)
            elseif choice.value == 'toggle' then
                mirror.toggle_mirror(mirror_info.name)
            elseif choice.value == 'remove' then
                ui.confirm(i18n.t('mirror.confirm_remove', {name = mirror_info.name}), function(confirmed)
                    if confirmed then
                        mirror.remove_mirror(mirror_info.name)
                    end
                end)
            end
        end
    end)
end

-- Affiche le menu de configuration
function M.show_config_menu()
    -- Affiche d'abord des informations sur la configuration
    vim.api.nvim_echo({
        {i18n.t('mirror.help.auto_sync') .. "\n\n", "Title"},
        {i18n.t('mirror.help.sync_interval') .. "\n", "Normal"}
    }, true, {})

    local choices = {
        { 
            text = i18n.t('mirror.config.auto_sync'),
            value = 'auto_sync',
            help = i18n.t('mirror.help.auto_sync')
        },
        { 
            text = i18n.t('mirror.config.sync_interval'),
            value = 'sync_interval',
            help = i18n.t('mirror.help.sync_interval')
        },
        { 
            text = i18n.t('mirror.config.sync_on_push'),
            value = 'sync_on_push'
        },
    }

    ui.select(choices, {
        prompt = i18n.t('mirror.config.title'),
        format_item = function(item)
            return item.text .. (item.help and "\n   " .. item.help or "")
        end
    }, function(choice)
        if choice then
            if choice.value == 'auto_sync' then
                ui.confirm(i18n.t('mirror.config.enable_auto_sync'), function(confirmed)
                    mirror.configure_auto_sync(confirmed)
                    if confirmed then
                        -- Si activé, propose de configurer l'intervalle
                        M.configure_sync_interval()
                    end
                end)
            elseif choice.value == 'sync_interval' then
                M.configure_sync_interval()
            elseif choice.value == 'sync_on_push' then
                ui.confirm(i18n.t('mirror.config.enable_sync_on_push'), function(confirmed)
                    mirror.configure_sync_on_push(confirmed)
                end)
            end
        end
    end)
end

-- Configure l'intervalle de synchronisation
function M.configure_sync_interval()
    -- Affiche d'abord des informations sur les intervalles
    vim.api.nvim_echo({
        {i18n.t('mirror.help.sync_interval') .. "\n", "Normal"}
    }, true, {})

    ui.input({
        prompt = i18n.t('mirror.config.enter_interval'),
        default = "3600",
    }, function(interval)
        if interval then
            interval = tonumber(interval)
            if interval and interval > 0 then
                mirror.configure_auto_sync(true, interval)
            else
                ui.show_error(i18n.t('mirror.error.invalid_interval'))
            end
        end
    end)
end

return M
