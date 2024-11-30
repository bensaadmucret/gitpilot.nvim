local M = {}
local config = {}
local utils = require('gitpilot.utils')
local i18n = require('gitpilot.i18n')
local ui = require('gitpilot.ui')

M.setup = function(opts)
    config = opts
end

-- Obtenir la liste des branches
local function get_branches()
    local output = utils.git_command('branch')
    local branches = {}
    for line in output:gmatch("[^\r\n]+") do
        local branch = line:gsub("^%s*%*?%s*", "")
        table.insert(branches, branch)
    end
    return branches
end

-- Obtenir la branche courante
local function get_current_branch()
    local output = utils.git_command('branch --show-current')
    return output:gsub("%s+", "")
end

-- Création d'une fenêtre flottante
local function create_floating_window()
    return ui.create_floating_window()
end

-- Afficher un menu de sélection
local function show_selection_menu(title, items, callback)
    local bufnr, win = create_floating_window()
    
    -- Préparer les lignes
    local lines = {title, string.rep("-", 40)}
    for i, item in ipairs(items) do
        table.insert(lines, string.format("%d. %s", i, item))
    end
    
    -- Configurer le buffer
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
    vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
    
    -- Options pour les mappings
    local opts = {
        buffer = bufnr,
        nowait = true,
        silent = true
    }
    
    -- Mappings pour fermer
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
    
    -- Navigation
    vim.keymap.set('n', 'j', 'j', opts)
    vim.keymap.set('n', 'k', 'k', opts)
    
    -- Sélection par numéro
    for i = 1, #items do
        vim.keymap.set('n', tostring(i), function()
            vim.api.nvim_win_close(win, true)
            callback(items[i])
        end, opts)
    end
    
    -- Sélection avec Enter
    vim.keymap.set('n', '<CR>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local selection = cursor[1] - 2
        
        if selection > 0 and selection <= #items then
            vim.api.nvim_win_close(win, true)
            callback(items[selection])
        end
    end, opts)
end

-- Demander une confirmation
local function confirm(message, callback)
    local bufnr, win = create_floating_window()
    
    -- Préparer les lignes
    local lines = {
        i18n.t("menu.confirmation"),
        string.rep("-", 40),
        message,
        "",
        i18n.t("menu.confirm_yes"),
        i18n.t("menu.confirm_no")
    }
    
    -- Configurer le buffer
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
    vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
    
    -- Options pour les mappings
    local opts = {
        buffer = bufnr,
        nowait = true,
        silent = true
    }
    
    -- Mappings
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

-- Demander un input
local function prompt_input(title, callback)
    local bufnr, win = create_floating_window()
    
    -- Préparer les lignes
    local lines = {
        title,
        string.rep("-", 40),
        ""
    }
    
    -- Configurer le buffer
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
    
    -- Placer le curseur sur la ligne d'input
    vim.api.nvim_win_set_cursor(win, {3, 0})
    vim.cmd('startinsert')
    
    -- Options pour les mappings
    local opts = {
        buffer = bufnr,
        nowait = true,
        silent = true
    }
    
    -- Mapping pour valider
    vim.keymap.set('i', '<CR>', function()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 2, 3, false)
        local input = lines[1]
        vim.api.nvim_win_close(win, true)
        callback(input)
    end, opts)
    
    -- Mapping pour annuler
    vim.keymap.set('i', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
        callback(nil)
    end, opts)
end

-- Créer une nouvelle branche
M.create_branch = function()
    prompt_input(i18n.t("branch.create_title"), function(branch_name)
        if branch_name and branch_name ~= "" then
            local success, err = utils.git_command_with_error('checkout -b ' .. branch_name)
            if success then
                vim.notify(i18n.t("branch.create_success", {name = branch_name}), vim.log.levels.INFO)
            else
                vim.notify(i18n.t("branch.create_error", {error = err}), vim.log.levels.ERROR)
            end
        end
    end)
end

-- Changer de branche
M.switch_branch = function()
    local branches = get_branches()
    show_selection_menu(i18n.t("branch.switch_title"), branches, function(branch)
        if branch then
            local success, err = utils.git_command_with_error('checkout ' .. branch)
            if success then
                vim.notify(i18n.t("branch.switch_success", {name = branch}), vim.log.levels.INFO)
            else
                vim.notify(i18n.t("branch.switch_error", {error = err}), vim.log.levels.ERROR)
            end
        end
    end)
end

-- Fusionner une branche
M.merge_branch = function()
    local branches = get_branches()
    local current = get_current_branch()
    
    -- Filtrer la branche courante
    local merge_branches = {}
    for _, branch in ipairs(branches) do
        if branch ~= current then
            table.insert(merge_branches, branch)
        end
    end
    
    show_selection_menu(i18n.t("branch.merge_title"), merge_branches, function(branch)
        if branch then
            confirm(i18n.t("branch.merge_confirm", {source = branch, target = current}), function(confirmed)
                if confirmed then
                    local success, err = utils.git_command_with_error('merge ' .. branch)
                    if success then
                        vim.notify(i18n.t("branch.merge_success", {name = branch}), vim.log.levels.INFO)
                    else
                        vim.notify(i18n.t("branch.merge_error", {error = err}), vim.log.levels.ERROR)
                    end
                end
            end)
        end
    end)
end

-- Supprimer une branche
M.delete_branch = function()
    local branches = get_branches()
    local current = get_current_branch()
    
    -- Filtrer la branche courante
    local delete_branches = {}
    for _, branch in ipairs(branches) do
        if branch ~= current then
            table.insert(delete_branches, branch)
        end
    end
    
    show_selection_menu(i18n.t("branch.delete_title"), delete_branches, function(branch)
        if branch then
            confirm(i18n.t("branch.delete_confirm", {name = branch}), function(confirmed)
                if confirmed then
                    local success, err = utils.git_command_with_error('branch -D ' .. branch)
                    if success then
                        vim.notify(i18n.t("branch.delete_success", {name = branch}), vim.log.levels.INFO)
                    else
                        vim.notify(i18n.t("branch.delete_error", {error = err}), vim.log.levels.ERROR)
                    end
                end
            end)
        end
    end)
end

return M
