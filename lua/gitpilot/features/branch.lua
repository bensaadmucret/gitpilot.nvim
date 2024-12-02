-- lua/gitpilot/features/branch.lua

local M = {}
local config = {}
local vim = vim
local i18n = require('gitpilot.i18n')
local utils = require('gitpilot.utils')

-- Vérifie si on est dans un dépôt Git
local function is_git_repo()
    local handle = io.popen("git rev-parse --is-inside-work-tree")
    if not handle then
        vim.notify("git.not_repo", vim.log.levels.ERROR)
        return false
    end
    local result = handle:read("*a")
    local success = handle:close()
    return success
end

-- Liste toutes les branches
function M.list_branches()
    if not is_git_repo() then
        return {}, ""
    end

    local handle = io.popen("git branch --all")
    if not handle then
        vim.notify("branch.list_error", vim.log.levels.ERROR)
        return {}, ""
    end
    
    local output = handle:read("*a")
    handle:close()
    
    local branches = {}
    local current = ""
    
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
        vim.notify("branch.invalid_name", vim.log.levels.ERROR)
        return false
    end
    
    local cmd = "git branch " .. branch_name
    if start_point then
        cmd = cmd .. " " .. start_point
    end
    
    local handle = io.popen(cmd)
    if not handle then
        vim.notify("branch.create_error", vim.log.levels.ERROR)
        return false
    end
    
    local output = handle:read("*a")
    local success = handle:close()
    
    if not success or output:match("error:") then
        vim.notify("branch.create_error", vim.log.levels.ERROR)
        return false
    else
        vim.notify("branch.create_success", vim.log.levels.INFO)
        return true
    end
end

-- Change de branche
function M.checkout_branch(branch_name)
    if not branch_name or branch_name == "" then
        vim.notify("branch.invalid_name", vim.log.levels.ERROR)
        return false
    end
    
    local handle = io.popen("git checkout " .. branch_name)
    if not handle then
        vim.notify("branch.checkout_error", vim.log.levels.ERROR)
        return false
    end
    
    local output = handle:read("*a")
    local success = handle:close()
    
    if not success or output:match("error:") then
        vim.notify("branch.checkout_error", vim.log.levels.ERROR)
        return false
    else
        vim.notify("branch.checkout_success", vim.log.levels.INFO)
        return true
    end
end

-- Fusionne une branche
function M.merge_branch(branch_name)
    if not branch_name or branch_name == "" then
        vim.notify("branch.invalid_name", vim.log.levels.ERROR)
        return false
    end
    
    local handle = io.popen("git merge " .. branch_name)
    if not handle then
        vim.notify("branch.merge_error", vim.log.levels.ERROR)
        return false
    end
    
    local output = handle:read("*a")
    local success = handle:close()
    
    -- Check for merge conflicts
    if output:match("CONFLICT") then
        vim.notify("branch.merge_conflict", vim.log.levels.WARN)
        return false
    end
    
    -- Check for other errors
    if not success or output:match("error:") then
        vim.notify("branch.merge_error", vim.log.levels.ERROR)
        return false
    end
    
    -- Success case
    vim.notify("branch.merge_success", vim.log.levels.INFO)
    return true
end

-- Supprime une branche
function M.delete_branch(branch_name, force)
    if not branch_name or branch_name == "" then
        vim.notify("branch.invalid_name", vim.log.levels.ERROR)
        return false
    end
    
    local handle = io.popen("git branch " .. (force and "-D" or "-d") .. " " .. branch_name)
    if not handle then
        vim.notify("branch.delete_error", vim.log.levels.ERROR)
        return false
    end
    
    local output = handle:read("*a")
    local success = handle:close()
    
    if not success or output:match("error:") then
        vim.notify("branch.delete_error", vim.log.levels.ERROR)
        return false
    else
        vim.notify("branch.delete_success", vim.log.levels.INFO)
        return true
    end
end

-- Interface utilisateur pour la gestion des branches
function M.show()
    if not is_git_repo() then
        return
    end

    local branches, current = M.list_branches()
    if not branches then
        return
    end
    
    -- Créer le menu
    local menu_items = {
        { text = "branch.create_new", action = function()
            vim.ui.input({ prompt = "branch.enter_name" }, function(name)
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
                    { text = "branch.checkout", action = function()
                        M.checkout_branch(branch)
                    end },
                    { text = "branch.merge", action = function()
                        M.merge_branch(branch)
                    end },
                    { text = "branch.delete", action = function()
                        M.delete_branch(branch)
                    end },
                }
                -- Afficher le sous-menu
                vim.ui.select(branch_menu, {
                    prompt = "branch.select_action",
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
        prompt = "branch.select_branch",
        format_item = function(item) return item.text end
    }, function(choice)
        if choice and choice.action then
            choice.action()
        end
    end)
end

return M