-- lua/gitpilot/features/branch.lua

local M = {}
<<<<<<< HEAD
local config = {}
local i18n = require("gitpilot.i18n")

-- Fonction utilitaire pour exécuter des commandes git
local function git_command(cmd, callback)
    local handle = io.popen(cmd)
    if handle then
        local result = handle:read("*a")
        handle:close()
        if callback then
            callback(result)
        end
        return result
=======
local vim = vim
local i18n = require('gitpilot.i18n')
local utils = require('gitpilot.utils')

-- Liste toutes les branches
M.list_branches = function()
    local cmd = "git branch --all"
    local output = utils.execute_command(cmd)
    if not output then
        return {}
>>>>>>> 979b8f4 (feat: Ajout du module de gestion des branches et configuration des tests)
    end
    return nil
end

-- Obtenir la liste des branches
function M.list_branches()
    local branches = {}
<<<<<<< HEAD
    local current = ""
    
    git_command("git branch --all", function(output)
        for line in output:gmatch("[^\r\n]+") do
            local branch = line:match("^%s*%*?%s*(.+)$")
            if branch then
                if line:match("^%s*%*") then
                    current = branch
                end
                table.insert(branches, branch)
            end
        end
    end)
    
    return branches, current
end

-- Créer une nouvelle branche
function M.create_branch(name, start_point)
    local cmd = string.format("git branch %s", name)
    if start_point then
        cmd = cmd .. " " .. start_point
    end
    
    git_command(cmd, function(output)
        if output and output:match("error") then
            vim.notify(i18n.t("branch.create_error", {name = name}), vim.log.levels.ERROR)
        else
            vim.notify(i18n.t("branch.create_success", {name = name}), vim.log.levels.INFO)
        end
    end)
end

-- Changer de branche
function M.checkout_branch(name)
    git_command(string.format("git checkout %s", name), function(output)
        if output and output:match("error") then
            vim.notify(i18n.t("branch.checkout_error", {name = name}), vim.log.levels.ERROR)
        else
            vim.notify(i18n.t("branch.checkout_success", {name = name}), vim.log.levels.INFO)
        end
    end)
end

-- Fusionner une branche
function M.merge_branch(name)
    git_command(string.format("git merge %s", name), function(output)
        if output and output:match("CONFLICT") then
            vim.notify(i18n.t("branch.merge_conflict", {name = name}), vim.log.levels.WARN)
        elseif output and output:match("error") then
            vim.notify(i18n.t("branch.merge_error", {name = name}), vim.log.levels.ERROR)
        else
            vim.notify(i18n.t("branch.merge_success", {name = name}), vim.log.levels.INFO)
        end
    end)
end

-- Supprimer une branche
function M.delete_branch(name, force)
    local flag = force and "-D" or "-d"
    git_command(string.format("git branch %s %s", flag, name), function(output)
        if output and output:match("error") then
            vim.notify(i18n.t("branch.delete_error", {name = name}), vim.log.levels.ERROR)
        else
            vim.notify(i18n.t("branch.delete_success", {name = name}), vim.log.levels.INFO)
        end
    end)
end

-- Interface utilisateur pour la gestion des branches
function M.show()
    local branches, current = M.list_branches()
    
    -- Créer le menu
    local menu_items = {
        { text = i18n.t("branch.create_new"), action = function()
            vim.ui.input({ prompt = i18n.t("branch.enter_name") }, function(name)
                if name then
                    M.create_branch(name)
                end
            end)
        end },
        { text = "─────────────────────" },
    }
    
    -- Ajouter les branches au menu
    for _, branch in ipairs(branches) do
        local is_current = branch == current
        table.insert(menu_items, {
            text = (is_current and "* " or "  ") .. branch,
            action = function()
                -- Sous-menu pour chaque branche
                local branch_menu = {
                    { text = i18n.t("branch.checkout"), action = function()
                        M.checkout_branch(branch)
                    end },
                    { text = i18n.t("branch.merge"), action = function()
                        M.merge_branch(branch)
                    end },
                    { text = i18n.t("branch.delete"), action = function()
                        M.delete_branch(branch)
                    end },
                }
                -- Afficher le sous-menu
                vim.ui.select(branch_menu, {
                    prompt = i18n.t("branch.select_action"),
                    format_item = function(item) return item.text end
                }, function(choice)
                    if choice then
                        choice.action()
                    end
                end)
            end
        })
    end
    
    -- Afficher le menu principal
    vim.ui.select(menu_items, {
        prompt = i18n.t("branch.select_branch"),
        format_item = function(item) return item.text end
    }, function(choice)
        if choice and choice.action then
            choice.action()
        end
    end)
end

-- Configuration du module
function M.setup(opts)
    config = opts or {}
=======
    for line in output:gmatch("[^\r\n]+") do
        local branch = line:match("^%s*%*?%s*(.+)$")
        if branch then
            table.insert(branches, branch)
        end
    end
    return branches
end

-- Crée une nouvelle branche
M.create_branch = function(branch_name)
    if not branch_name or branch_name == "" then
        return false, i18n.t("branch.error.invalid_name")
    end
    
    local cmd = string.format("git checkout -b %s", branch_name)
    local success = utils.execute_command(cmd)
    
    if success then
        return true, i18n.t("branch.success.created", {name = branch_name})
    else
        return false, i18n.t("branch.error.create_failed", {name = branch_name})
    end
end

-- Change de branche
M.switch_branch = function(branch_name)
    if not branch_name or branch_name == "" then
        return false, i18n.t("branch.error.invalid_name")
    end
    
    local cmd = string.format("git checkout %s", branch_name)
    local success = utils.execute_command(cmd)
    
    if success then
        return true, i18n.t("branch.success.switched", {name = branch_name})
    else
        return false, i18n.t("branch.error.switch_failed", {name = branch_name})
    end
end

-- Fusionne une branche
M.merge_branch = function(branch_name)
    if not branch_name or branch_name == "" then
        return false, i18n.t("branch.error.invalid_name")
    end
    
    local cmd = string.format("git merge %s", branch_name)
    local success = utils.execute_command(cmd)
    
    if success then
        return true, i18n.t("branch.success.merged", {name = branch_name})
    else
        return false, i18n.t("branch.error.merge_failed", {name = branch_name})
    end
>>>>>>> 979b8f4 (feat: Ajout du module de gestion des branches et configuration des tests)
end

-- Supprime une branche
M.delete_branch = function(branch_name, force)
    if not branch_name or branch_name == "" then
        return false, i18n.t("branch.error.invalid_name")
    end
    
    local flag = force and "-D" or "-d"
    local cmd = string.format("git branch %s %s", flag, branch_name)
    local success = utils.execute_command(cmd)
    
    if success then
        return true, i18n.t("branch.success.deleted", {name = branch_name})
    else
        return false, i18n.t("branch.error.delete_failed", {name = branch_name})
    end
end

-- Obtient le nom de la branche courante
M.get_current_branch = function()
    local cmd = "git rev-parse --abbrev-ref HEAD"
    local output = utils.execute_command(cmd)
    return output and output:match("^(.-)%s*$")
end

return M