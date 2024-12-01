-- lua/gitpilot/features/branch.lua

local M = {}
local config = {}
local vim = vim
local i18n = require('gitpilot.i18n')
local utils = require('gitpilot.utils')

-- Liste toutes les branches
function M.list_branches()
    local cmd = "git branch --all"
    local output = utils.execute_command(cmd)
    if not output then
        return {}, nil
    end
    
    local branches = {}
    local current = nil
    
    for line in output:gmatch("[^\r\n]+") do
        local branch = line:match("^%s*%*?%s*(.+)$")
        if branch then
            if line:match("^%s*%*") then
                current = branch
            end
            table.insert(branches, branch)
        end
    end
    
    return branches, current
end

-- Crée une nouvelle branche
function M.create_branch(branch_name, start_point)
    if not branch_name or branch_name == "" then
        return false, i18n.t("branch.error.invalid_name")
    end
    
    local cmd = string.format("git checkout -b %s", branch_name)
    if start_point then
        cmd = cmd .. " " .. start_point
    end
    
    local success = utils.execute_command(cmd)
    if success then
        vim.notify(i18n.t("branch.success.created", {name = branch_name}), vim.log.levels.INFO)
        return true
    else
        vim.notify(i18n.t("branch.error.create_failed", {name = branch_name}), vim.log.levels.ERROR)
        return false
    end
end

-- Change de branche
function M.switch_branch(branch_name)
    if not branch_name or branch_name == "" then
        return false, i18n.t("branch.error.invalid_name")
    end
    
    local cmd = string.format("git checkout %s", branch_name)
    local success = utils.execute_command(cmd)
    
    if success then
        vim.notify(i18n.t("branch.success.switched", {name = branch_name}), vim.log.levels.INFO)
        return true
    else
        vim.notify(i18n.t("branch.error.switch_failed", {name = branch_name}), vim.log.levels.ERROR)
        return false
    end
end

-- Fusionne une branche
function M.merge_branch(branch_name)
    if not branch_name or branch_name == "" then
        return false, i18n.t("branch.error.invalid_name")
    end
    
    local cmd = string.format("git merge %s", branch_name)
    local success = utils.execute_command(cmd)
    
    if success then
        vim.notify(i18n.t("branch.success.merged", {name = branch_name}), vim.log.levels.INFO)
        return true
    else
        vim.notify(i18n.t("branch.error.merge_failed", {name = branch_name}), vim.log.levels.ERROR)
        return false
    end
end

-- Supprime une branche
function M.delete_branch(branch_name, force)
    if not branch_name or branch_name == "" then
        return false, i18n.t("branch.error.invalid_name")
    end
    
    local flag = force and "-D" or "-d"
    local cmd = string.format("git branch %s %s", flag, branch_name)
    local success = utils.execute_command(cmd)
    
    if success then
        vim.notify(i18n.t("branch.success.deleted", {name = branch_name}), vim.log.levels.INFO)
        return true
    else
        vim.notify(i18n.t("branch.error.delete_failed", {name = branch_name}), vim.log.levels.ERROR)
        return false
    end
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
                        M.switch_branch(branch)
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
end

return M