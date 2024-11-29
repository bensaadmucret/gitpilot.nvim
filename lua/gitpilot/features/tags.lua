local M = {}
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')
local utils = require('gitpilot.utils')

-- Configuration locale
local config = {}

-- Setup function
M.setup = function(opts)
    config = opts
end

-- Liste des tags
M.list_tags = function()
    local tags = utils.git_command('tag -l --format="%(refname:short)|%(objectname:short)|%(contents:subject)"')
    if not tags then return {} end

    local tag_list = {}
    for line in tags:gmatch("[^\r\n]+") do
        local name, hash, message = line:match("([^|]+)|([^|]+)|(.+)")
        if name and hash then
            table.insert(tag_list, {
                name = name,
                hash = hash,
                message = message or ""
            })
        end
    end
    return tag_list
end

-- Créer un tag
M.create_tag = function()
    -- Obtenir le hash du commit actuel
    local current_commit = utils.git_command('rev-parse HEAD')
    if not current_commit then return end

    vim.ui.input({prompt = i18n.t("tag.name.prompt")}, function(name)
        if not name or name == "" then return end
        
        -- Vérifier si le tag existe déjà
        local existing = utils.git_command('tag -l ' .. name)
        if existing and existing ~= "" then
            ui.notify(i18n.t("tag.exists"), "warn")
            return
        end

        vim.ui.input({prompt = i18n.t("tag.message.prompt")}, function(message)
            if not message or message == "" then
                -- Tag léger
                local result = utils.git_command(string.format('tag %s', name))
                if result then
                    ui.notify(i18n.t("tag.created_light"), "info")
                end
            else
                -- Tag annoté
                local result = utils.git_command(string.format('tag -a %s -m "%s"', name, message))
                if result then
                    ui.notify(i18n.t("tag.created_annotated"), "info")
                end
            end
        end)
    end)
end

-- Supprimer un tag
M.delete_tag = function()
    local tags = M.list_tags()
    if #tags == 0 then
        ui.notify(i18n.t("tag.none"), "warn")
        return
    end

    local tag_display = {}
    for _, tag in ipairs(tags) do
        table.insert(tag_display, string.format("%s (%s) - %s", tag.name, tag.hash, tag.message))
    end

    local buf, win = ui.create_floating_window(
        i18n.t("tag.select_delete"),
        tag_display,
        {
            width = 80
        }
    )

    -- Navigation et sélection
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #tag_display then
            vim.api.nvim_win_set_cursor(win, {cursor[1] + 1, cursor[2]})
        end
    end, opts)
    
    vim.keymap.set('n', 'k', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] > 1 then
            vim.api.nvim_win_set_cursor(win, {cursor[1] - 1, cursor[2]})
        end
    end, opts)

    -- Fermeture
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
    end, opts)

    -- Sélection et suppression
    vim.keymap.set('n', '<CR>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local tag = tags[cursor[1]]
        
        vim.api.nvim_win_close(win, true)
        
        ui.confirm(i18n.t("tag.confirm_delete") .. " " .. tag.name .. "?", function(confirmed)
            if confirmed then
                local result = utils.git_command('tag -d ' .. tag.name)
                if result then
                    ui.notify(i18n.t("tag.deleted") .. ": " .. tag.name, "info")
                end
            end
        end)
    end, opts)
end

-- Push des tags
M.push_tags = function()
    local tags = M.list_tags()
    if #tags == 0 then
        ui.notify(i18n.t("tag.none"), "warn")
        return
    end

    local tag_display = {}
    for _, tag in ipairs(tags) do
        table.insert(tag_display, string.format("%s (%s)", tag.name, tag.hash))
    end
    table.insert(tag_display, 1, i18n.t("tag.push_all"))

    local buf, win = ui.create_floating_window(
        i18n.t("tag.select_push"),
        tag_display,
        {
            width = 60
        }
    )

    -- Navigation et sélection
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #tag_display then
            vim.api.nvim_win_set_cursor(win, {cursor[1] + 1, cursor[2]})
        end
    end, opts)
    
    vim.keymap.set('n', 'k', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] > 1 then
            vim.api.nvim_win_set_cursor(win, {cursor[1] - 1, cursor[2]})
        end
    end, opts)

    -- Fermeture
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
    end, opts)

    -- Sélection et push
    vim.keymap.set('n', '<CR>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        vim.api.nvim_win_close(win, true)
        
        if cursor[1] == 1 then
            -- Push tous les tags
            local result = utils.git_command('push --tags')
            if result then
                ui.notify(i18n.t("tag.pushed_all"), "info")
            end
        else
            -- Push tag spécifique
            local tag = tags[cursor[1] - 1]
            local result = utils.git_command('push origin ' .. tag.name)
            if result then
                ui.notify(i18n.t("tag.pushed") .. ": " .. tag.name, "info")
            end
        end
    end, opts)
end

return M
