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

-- Liste des stash
M.list_stash = function()
    local stashes = utils.git_command('stash list --format="%gd|%h|%s"')
    if not stashes then return {} end

    local stash_list = {}
    for line in stashes:gmatch("[^\r\n]+") do
        local ref, hash, message = line:match("([^|]+)|([^|]+)|(.+)")
        if ref and hash then
            table.insert(stash_list, {
                ref = ref,
                hash = hash,
                message = message or ""
            })
        end
    end
    return stash_list
end

-- Créer un stash sélectif
M.create_stash = function()
    local status = utils.git_command('status --porcelain')
    if not status or status == "" then
        ui.notify(i18n.t("stash.no_changes"), "warn")
        return
    end

    local files = {}
    for line in status:gmatch("[^\r\n]+") do
        local status_code = line:sub(1, 2)
        local file_path = line:sub(4)
        table.insert(files, {
            status = status_code,
            path = file_path,
            selected = false
        })
    end

    local file_list = {}
    for _, file in ipairs(files) do
        local prefix = file.selected and "✓" or " "
        table.insert(file_list, string.format("%s [%s] %s", prefix, file.status, file.path))
    end

    local buf, win = ui.create_floating_window(
        i18n.t("stash.select_files"),
        file_list,
        {
            width = 60
        }
    )

    -- Navigation
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #file_list then
            vim.api.nvim_win_set_cursor(win, {cursor[1] + 1, cursor[2]})
        end
    end, opts)
    
    vim.keymap.set('n', 'k', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] > 1 then
            vim.api.nvim_win_set_cursor(win, {cursor[1] - 1, cursor[2]})
        end
    end, opts)

    -- Sélection/Désélection
    vim.keymap.set('n', '<Space>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local idx = cursor[1]
        files[idx].selected = not files[idx].selected
        
        local prefix = files[idx].selected and "✓" or " "
        file_list[idx] = string.format("%s [%s] %s", prefix, files[idx].status, files[idx].path)
        vim.api.nvim_buf_set_lines(buf, idx-1, idx, false, {file_list[idx]})
    end, opts)

    -- Tout sélectionner/désélectionner
    vim.keymap.set('n', 'a', function()
        local all_selected = true
        for _, file in ipairs(files) do
            if not file.selected then
                all_selected = false
                break
            end
        end
        
        for i, file in ipairs(files) do
            file.selected = not all_selected
            local prefix = file.selected and "✓" or " "
            file_list[i] = string.format("%s [%s] %s", prefix, file.status, file.path)
        end
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, file_list)
    end, opts)

    -- Fermeture
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
    end, opts)

    -- Confirmation et création du stash
    vim.keymap.set('n', '<CR>', function()
        local selected_files = {}
        for _, file in ipairs(files) do
            if file.selected then
                table.insert(selected_files, file.path)
            end
        end
        
        if #selected_files == 0 then
            ui.notify(i18n.t("stash.no_selection"), "warn")
            return
        end

        vim.api.nvim_win_close(win, true)
        
        vim.ui.input({prompt = i18n.t("stash.message.prompt")}, function(message)
            if not message then return end
            
            -- Ajouter les fichiers sélectionnés
            local add_result = utils.git_command('add ' .. table.concat(selected_files, ' '))
            if not add_result then return end
            
            -- Créer le stash
            local stash_cmd = 'stash push'
            if message and message ~= "" then
                stash_cmd = stash_cmd .. ' -m "' .. message .. '"'
            end
            
            local result = utils.git_command(stash_cmd)
            if result then
                ui.notify(i18n.t("stash.created"), "info")
            end
        end)
    end, opts)
end

-- Appliquer un stash
M.apply_stash = function()
    local stashes = M.list_stash()
    if #stashes == 0 then
        ui.notify(i18n.t("stash.none"), "warn")
        return
    end

    local stash_display = {}
    for _, stash in ipairs(stashes) do
        table.insert(stash_display, string.format("%s - %s", stash.ref, stash.message))
    end

    local buf, win = ui.create_floating_window(
        i18n.t("stash.select_apply"),
        stash_display,
        {
            width = 80
        }
    )

    -- Navigation et sélection
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #stash_display then
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

    -- Options d'application
    vim.keymap.set('n', '<CR>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local stash = stashes[cursor[1]]
        
        vim.api.nvim_win_close(win, true)
        
        local options = {
            {name = "apply", desc = i18n.t("stash.apply_keep")},
            {name = "pop", desc = i18n.t("stash.apply_drop")}
        }

        local option_list = {}
        for _, opt in ipairs(options) do
            table.insert(option_list, opt.desc)
        end

        local opt_buf, opt_win = ui.create_floating_window(
            i18n.t("stash.select_option"),
            option_list,
            {
                width = 60
            }
        )

        local opt_opts = {buffer = opt_buf, noremap = true, silent = true}
        
        -- Navigation
        vim.keymap.set('n', 'j', function()
            local cursor = vim.api.nvim_win_get_cursor(opt_win)
            if cursor[1] < #option_list then
                vim.api.nvim_win_set_cursor(opt_win, {cursor[1] + 1, cursor[2]})
            end
        end, opt_opts)
        
        vim.keymap.set('n', 'k', function()
            local cursor = vim.api.nvim_win_get_cursor(opt_win)
            if cursor[1] > 1 then
                vim.api.nvim_win_set_cursor(opt_win, {cursor[1] - 1, cursor[2]})
            end
        end, opt_opts)

        -- Fermeture
        vim.keymap.set('n', 'q', function()
            vim.api.nvim_win_close(opt_win, true)
        end, opt_opts)
        
        vim.keymap.set('n', '<Esc>', function()
            vim.api.nvim_win_close(opt_win, true)
        end, opt_opts)

        -- Application finale
        vim.keymap.set('n', '<CR>', function()
            local opt_cursor = vim.api.nvim_win_get_cursor(opt_win)
            local option = options[opt_cursor[1]]
            
            vim.api.nvim_win_close(opt_win, true)
            
            local result = utils.git_command('stash ' .. option.name .. ' ' .. stash.ref)
            if result then
                ui.notify(i18n.t("stash.applied"), "info")
            end
        end, opt_opts)
    end, opts)
end

-- Afficher le contenu d'un stash
M.show_stash_content = function(stash_ref)
    local content = utils.git_command('stash show -p ' .. stash_ref)
    if not content then return end

    local buf, win = ui.create_floating_window(
        i18n.t("stash.content_title") .. ": " .. stash_ref,
        vim.split(content, "\n"),
        {
            width = 80,
            height = 20
        }
    )

    -- Navigation
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
end

-- Supprimer un stash
M.delete_stash = function()
    local stashes = M.list_stash()
    if #stashes == 0 then
        ui.notify(i18n.t("stash.none"), "warn")
        return
    end

    local stash_display = {}
    for _, stash in ipairs(stashes) do
        table.insert(stash_display, string.format("%s - %s", stash.ref, stash.message))
    end

    local buf, win = ui.create_floating_window(
        i18n.t("stash.select_delete"),
        stash_display,
        {
            width = 80
        }
    )

    -- Navigation et sélection
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #stash_display then
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
        local stash = stashes[cursor[1]]
        
        vim.api.nvim_win_close(win, true)
        
        ui.confirm(i18n.t("stash.confirm_delete") .. " " .. stash.ref .. "?", function(confirmed)
            if confirmed then
                local result = utils.git_command('stash drop ' .. stash.ref)
                if result then
                    ui.notify(i18n.t("stash.deleted"), "info")
                end
            end
        end)
    end, opts)
end

return M
