local M = {}
local config = {}
local i18n = require('gitpilot.i18n')
local utils = require('gitpilot.utils')

M.setup = function(opts)
    config = opts
end

-- Fonction utilitaire pour obtenir la liste des branches
local function get_branches()
    local output = utils.git_command('branch')
    local branches = {}
    for line in output:gmatch("[^\r\n]+") do
        -- Enlever les espaces et le marqueur de branche courante (*)
        local branch = line:gsub("^%s*%*?%s*", "")
        table.insert(branches, branch)
    end
    return branches
end

-- Fonction utilitaire pour obtenir la branche courante
local function get_current_branch()
    local output = utils.git_command('branch --show-current')
    return output:gsub("%s+", "")
end

-- Fonction pour créer une nouvelle fenêtre flottante
local function create_float_window(title, content)
    local width = 60
    local height = #content + 4
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        row = row,
        col = col,
        width = width,
        height = height,
        style = 'minimal',
        border = 'rounded'
    })
    
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {title, string.rep('-', width - 2)})
    vim.api.nvim_buf_set_lines(buf, 2, -1, false, content)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    
    return buf, win
end

-- Fonction pour demander une confirmation
local function confirm(message, callback)
    local content = {
        message,
        "",
        "Appuyez sur 'y' pour confirmer ou 'n' pour annuler"
    }
    
    local buf, win = create_float_window("Confirmation", content)
    
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('n', 'y', function()
        vim.api.nvim_win_close(win, true)
        callback(true)
    end, opts)
    
    vim.keymap.set('n', 'n', function()
        vim.api.nvim_win_close(win, true)
        callback(false)
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
        callback(false)
    end, opts)
end

-- Fonction pour demander un input
local function prompt_input(title, callback)
    local content = {
        "Entrez votre texte ci-dessous :",
        ""
    }
    
    local buf, win = create_float_window(title, content)
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    
    -- Activer le mode insertion
    vim.cmd('startinsert')
    
    -- Gérer la validation
    vim.keymap.set('i', '<CR>', function()
        local lines = vim.api.nvim_buf_get_lines(buf, 2, 3, false)
        local input = lines[1]
        vim.api.nvim_win_close(win, true)
        callback(input)
    end, {buffer = buf, noremap = true})
    
    -- Gérer l'annulation
    vim.keymap.set('i', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
        callback(nil)
    end, {buffer = buf, noremap = true})
end

-- Fonction pour afficher une liste sélectionnable
local function show_selectable_list(title, items, callback)
    local content = {}
    for i, item in ipairs(items) do
        table.insert(content, string.format("%d. %s", i, item))
    end
    
    local buf, win = create_float_window(title, content)
    
    local opts = {buffer = buf, noremap = true, silent = true}
    
    -- Navigation
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #items then
            vim.api.nvim_win_set_cursor(win, {cursor[1] + 1, cursor[2]})
        end
    end, opts)
    
    vim.keymap.set('n', 'k', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] > 1 then
            vim.api.nvim_win_set_cursor(win, {cursor[1] - 1, cursor[2]})
        end
    end, opts)
    
    -- Sélection
    vim.keymap.set('n', '<CR>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local selection = items[cursor[1]]
        vim.api.nvim_win_close(win, true)
        callback(selection)
    end, opts)
    
    -- Annulation
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
        callback(nil)
    end, opts)
    
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, true)
        callback(nil)
    end, opts)
end

-- Créer une nouvelle branche
M.create_branch = function()
    prompt_input("Nouvelle Branche", function(branch_name)
        if branch_name then
            local success, err = utils.git_command_with_error('checkout -b ' .. branch_name)
            if success then
                vim.notify("Branche '" .. branch_name .. "' créée avec succès", vim.log.levels.INFO)
            else
                vim.notify("Erreur lors de la création de la branche: " .. err, vim.log.levels.ERROR)
            end
        end
    end)
end

-- Changer de branche
M.switch_branch = function()
    local branches = get_branches()
    show_selectable_list("Changer de Branche", branches, function(branch)
        if branch then
            local success, err = utils.git_command_with_error('checkout ' .. branch)
            if success then
                vim.notify("Changement vers la branche '" .. branch .. "'", vim.log.levels.INFO)
            else
                vim.notify("Erreur lors du changement de branche: " .. err, vim.log.levels.ERROR)
            end
        end
    end)
end

-- Fusionner une branche
M.merge_branch = function()
    local current = get_current_branch()
    local branches = get_branches()
    
    -- Filtrer la branche courante
    local merge_branches = {}
    for _, branch in ipairs(branches) do
        if branch ~= current then
            table.insert(merge_branches, branch)
        end
    end
    
    show_selectable_list("Fusionner une Branche", merge_branches, function(branch)
        if branch then
            confirm("Voulez-vous fusionner la branche '" .. branch .. "' dans '" .. current .. "' ?", function(confirmed)
                if confirmed then
                    local success, err = utils.git_command_with_error('merge ' .. branch)
                    if success then
                        vim.notify("Fusion de la branche '" .. branch .. "' réussie", vim.log.levels.INFO)
                    else
                        vim.notify("Erreur lors de la fusion: " .. err, vim.log.levels.ERROR)
                    end
                end
            end)
        end
    end)
end

-- Supprimer une branche
M.delete_branch = function()
    local current = get_current_branch()
    local branches = get_branches()
    
    -- Filtrer la branche courante
    local delete_branches = {}
    for _, branch in ipairs(branches) do
        if branch ~= current then
            table.insert(delete_branches, branch)
        end
    end
    
    show_selectable_list("Supprimer une Branche", delete_branches, function(branch)
        if branch then
            confirm("Êtes-vous sûr de vouloir supprimer la branche '" .. branch .. "' ?", function(confirmed)
                if confirmed then
                    local success, err = utils.git_command_with_error('branch -d ' .. branch)
                    if success then
                        vim.notify("Branche '" .. branch .. "' supprimée", vim.log.levels.INFO)
                    else
                        vim.notify("Erreur lors de la suppression: " .. err, vim.log.levels.ERROR)
                    end
                end
            end)
        end
    end)
end

return M
