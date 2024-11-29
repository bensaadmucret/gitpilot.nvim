local i18n = require('gitpilot.i18n')
local ui = require('gitpilot.ui')
local utils = require('gitpilot.utils')
local M = {}

-- Configuration locale
local config = {}

-- Setup function
M.setup = function(opts)
    config = opts
end

-- Fonction utilitaire pour exécuter des commandes git
local function git_command(cmd, callback)
    local command = string.format("%s %s", config.git.cmd, cmd)
    local handle = io.popen(command)
    
    if handle then
        local result = handle:read("*a")
        handle:close()
        
        if callback then
            callback(result)
        else
            return result
        end
    else
        ui.notify(i18n.t("error") .. ": " .. command, "error")
        return nil
    end
end

-- Assistant de commit intelligent
M.smart_commit = function()
    -- Récupérer le status
    local status = utils.git_command('status --porcelain')
    if not status or status == "" then
        ui.notify(i18n.t("commit.files.none"), "warn")
        return
    end
    
    -- Préparer la liste des fichiers modifiés
    local files = {}
    for line in status:gmatch("[^\r\n]+") do
        local status_code = line:sub(1, 2)
        local file_path = line:sub(4)
        table.insert(files, {
            status = status_code,
            path = file_path
        })
    end
    
    -- Afficher la sélection des fichiers
    local file_list = {}
    for _, file in ipairs(files) do
        table.insert(file_list, string.format("%s %s", file.status, file.path))
    end
    
    local buf, win = ui.create_floating_window(
        i18n.t("commit.files.select"),
        file_list,
        {
            width = 60
        }
    )
    
    -- TODO: Implémenter la sélection multiple des fichiers
    -- TODO: Implémenter la sélection du type de commit
    -- TODO: Implémenter l'édition du message de commit
end

-- Gestionnaire de branches sécurisé
M.safe_branch_manager = function()
    -- Récupérer la liste des branches
    local branches = utils.git_command('branch')
    if not branches then return end
    
    local branch_list = {}
    local current_branch = ""
    
    for line in branches:gmatch("[^\r\n]+") do
        if line:sub(1, 1) == "*" then
            current_branch = line:sub(3)
            table.insert(branch_list, "* " .. current_branch)
        else
            table.insert(branch_list, "  " .. line:sub(3))
        end
    end
    
    -- Afficher le menu des branches
    local menu_items = {
        i18n.t("branch.create"),
        i18n.t("branch.switch"),
        i18n.t("branch.merge"),
        i18n.t("branch.delete")
    }
    
    local buf, win = ui.create_floating_window(
        i18n.t("branch.current") .. " " .. current_branch,
        menu_items,
        {
            width = 40,
            height = #menu_items + 2
        }
    )
    
    -- Ajouter les mappings pour la navigation et la sélection
    local opts = {buffer = buf, noremap = true, silent = true}
    
    -- Navigation
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #menu_items then
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
    
    -- Sélection
    vim.keymap.set('n', '<CR>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local selection = cursor[1]
        
        -- Fermer la fenêtre du menu
        vim.api.nvim_win_close(win, true)
        
        -- Gérer les différentes actions
        if selection == 1 then
            -- Créer une nouvelle branche
            vim.ui.input({prompt = "Nom de la nouvelle branche: "}, function(branch_name)
                if branch_name and branch_name ~= "" then
                    local result = utils.git_command('checkout -b ' .. branch_name)
                    if result then
                        ui.notify(i18n.t("branch.created") .. ": " .. branch_name, "info")
                    end
                end
            end)
            
        elseif selection == 2 then
            -- Changer de branche
            local switch_buf, switch_win = ui.create_floating_window(
                i18n.t("branch.select"),
                branch_list,
                {
                    width = 40,
                    height = #branch_list + 2
                }
            )
            
            local switch_opts = {buffer = switch_buf, noremap = true, silent = true}
            
            -- Navigation dans la liste des branches
            vim.keymap.set('n', 'j', function()
                local cursor = vim.api.nvim_win_get_cursor(switch_win)
                if cursor[1] < #branch_list then
                    vim.api.nvim_win_set_cursor(switch_win, {cursor[1] + 1, cursor[2]})
                end
            end, switch_opts)
            
            vim.keymap.set('n', 'k', function()
                local cursor = vim.api.nvim_win_get_cursor(switch_win)
                if cursor[1] > 1 then
                    vim.api.nvim_win_set_cursor(switch_win, {cursor[1] - 1, cursor[2]})
                end
            end, switch_opts)
            
            -- Fermeture
            vim.keymap.set('n', 'q', function()
                vim.api.nvim_win_close(switch_win, true)
            end, switch_opts)
            
            vim.keymap.set('n', '<Esc>', function()
                vim.api.nvim_win_close(switch_win, true)
            end, switch_opts)
            
            -- Sélection de la branche
            vim.keymap.set('n', '<CR>', function()
                local cursor = vim.api.nvim_win_get_cursor(switch_win)
                local branch = branch_list[cursor[1]]:gsub("^%s*%*?%s*", "")
                
                vim.api.nvim_win_close(switch_win, true)
                
                if branch ~= current_branch then
                    local result = utils.git_command('checkout ' .. branch)
                    if result then
                        ui.notify(i18n.t("branch.switched") .. ": " .. branch, "info")
                    end
                else
                    ui.notify(i18n.t("branch.already_on"), "warn")
                end
            end, switch_opts)
            
        elseif selection == 3 then
            -- Fusionner une branche
            local merge_buf, merge_win = ui.create_floating_window(
                i18n.t("branch.select_merge"),
                branch_list,
                {
                    width = 40,
                    height = #branch_list + 2
                }
            )
            
            local merge_opts = {buffer = merge_buf, noremap = true, silent = true}
            
            -- Navigation
            vim.keymap.set('n', 'j', function()
                local cursor = vim.api.nvim_win_get_cursor(merge_win)
                if cursor[1] < #branch_list then
                    vim.api.nvim_win_set_cursor(merge_win, {cursor[1] + 1, cursor[2]})
                end
            end, merge_opts)
            
            vim.keymap.set('n', 'k', function()
                local cursor = vim.api.nvim_win_get_cursor(merge_win)
                if cursor[1] > 1 then
                    vim.api.nvim_win_set_cursor(merge_win, {cursor[1] - 1, cursor[2]})
                end
            end, merge_opts)
            
            -- Fermeture
            vim.keymap.set('n', 'q', function()
                vim.api.nvim_win_close(merge_win, true)
            end, merge_opts)
            
            vim.keymap.set('n', '<Esc>', function()
                vim.api.nvim_win_close(merge_win, true)
            end, merge_opts)
            
            -- Sélection et fusion
            vim.keymap.set('n', '<CR>', function()
                local cursor = vim.api.nvim_win_get_cursor(merge_win)
                local branch = branch_list[cursor[1]]:gsub("^%s*%*?%s*", "")
                
                vim.api.nvim_win_close(merge_win, true)
                
                if branch == current_branch then
                    ui.notify(i18n.t("branch.cannot_merge_self"), "warn")
                    return
                end
                
                ui.confirm(i18n.t("branch.confirm_merge") .. " " .. branch .. "?", function(confirmed)
                    if confirmed then
                        local result = utils.git_command('merge ' .. branch)
                        if result then
                            ui.notify(i18n.t("branch.merged") .. ": " .. branch, "info")
                        end
                    end
                end)
            end, merge_opts)
            
        elseif selection == 4 then
            -- Supprimer une branche
            local delete_buf, delete_win = ui.create_floating_window(
                i18n.t("branch.select_delete"),
                branch_list,
                {
                    width = 40,
                    height = #branch_list + 2
                }
            )
            
            local delete_opts = {buffer = delete_buf, noremap = true, silent = true}
            
            -- Navigation
            vim.keymap.set('n', 'j', function()
                local cursor = vim.api.nvim_win_get_cursor(delete_win)
                if cursor[1] < #branch_list then
                    vim.api.nvim_win_set_cursor(delete_win, {cursor[1] + 1, cursor[2]})
                end
            end, delete_opts)
            
            vim.keymap.set('n', 'k', function()
                local cursor = vim.api.nvim_win_get_cursor(delete_win)
                if cursor[1] > 1 then
                    vim.api.nvim_win_set_cursor(delete_win, {cursor[1] - 1, cursor[2]})
                end
            end, delete_opts)
            
            -- Fermeture
            vim.keymap.set('n', 'q', function()
                vim.api.nvim_win_close(delete_win, true)
            end, delete_opts)
            
            vim.keymap.set('n', '<Esc>', function()
                vim.api.nvim_win_close(delete_win, true)
            end, delete_opts)
            
            -- Sélection et suppression
            vim.keymap.set('n', '<CR>', function()
                local cursor = vim.api.nvim_win_get_cursor(delete_win)
                local branch = branch_list[cursor[1]]:gsub("^%s*%*?%s*", "")
                
                vim.api.nvim_win_close(delete_win, true)
                
                if branch == current_branch then
                    ui.notify(i18n.t("branch.cannot_delete_current"), "warn")
                    return
                end
                
                ui.confirm(i18n.t("branch.warning.delete") .. "\n" .. i18n.t("branch.confirm_delete") .. " " .. branch .. "?", function(confirmed)
                    if confirmed then
                        local result = utils.git_command('branch -D ' .. branch)
                        if result then
                            ui.notify(i18n.t("branch.deleted") .. ": " .. branch, "info")
                        end
                    end
                end)
            end, delete_opts)
        end
    end, opts)
end

-- Assistant de rebase interactif
M.interactive_rebase = function()
    -- Vérifier s'il y a des commits à rebase
    local commits = utils.git_command('log --oneline -n 5')
    if not commits then return end
    
    local commit_list = {}
    for line in commits:gmatch("[^\r\n]+") do
        table.insert(commit_list, line)
    end
    
    -- Afficher l'avertissement
    ui.confirm(i18n.t("rebase.warning") .. "\n" .. i18n.t("rebase.backup"), function(confirmed)
        if confirmed then
            -- TODO: Implémenter l'interface de rebase interactif
        end
    end)
end

-- Résolution de conflits
M.conflict_resolver = function()
    -- Vérifier les conflits
    local conflicts = utils.git_command('diff --name-only --diff-filter=U')
    if not conflicts or conflicts == "" then
        ui.notify(i18n.t("conflict.none"), "info")
        return
    end
    
    local conflict_files = {}
    for line in conflicts:gmatch("[^\r\n]+") do
        table.insert(conflict_files, line)
    end
    
    -- Afficher les fichiers en conflit
    local buf, win = ui.create_floating_window(
        i18n.t("conflict.found"),
        conflict_files,
        {
            width = 60
        }
    )
    
    -- TODO: Implémenter l'interface de résolution de conflits
end

-- Gestionnaire de stash avancé
M.advanced_stash = function()
    -- Récupérer la liste des stash
    local stashes = utils.git_command('stash list')
    local stash_list = {}
    
    if stashes and stashes ~= "" then
        for line in stashes:gmatch("[^\r\n]+") do
            table.insert(stash_list, line)
        end
    else
        stash_list = {i18n.t("stash.empty")}
    end
    
    -- Afficher le menu stash
    local menu_items = {
        i18n.t("stash.create"),
        i18n.t("stash.apply"),
        i18n.t("stash.pop"),
        i18n.t("stash.drop")
    }
    
    local buf, win = ui.create_floating_window(
        i18n.t("stash.list"),
        menu_items,
        {
            width = 40
        }
    )
    
    -- TODO: Implémenter les actions sur les stash
end

-- Visualisation de l'historique
M.visual_history = function()
    -- Récupérer l'historique
    local history = utils.git_command('log --graph --oneline --decorate --all -n 20')
    if not history then return end
    
    local history_lines = vim.split(history, "\n")
    
    -- Afficher l'historique
    local buf, win = ui.create_floating_window(
        "Git History",
        history_lines,
        {
            width = 100
        }
    )
    
    -- Ajouter les mappings pour fermer la fenêtre
    local opts = {buffer = buf, noremap = true, silent = true}
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
end

return M
