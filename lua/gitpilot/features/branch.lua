local M = {}
local utils = require('gitpilot.utils')
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')

-- Liste toutes les branches
M.list_branches = function()
    local success, output = pcall(utils.git_command, 'branch')
    if not success then
        vim.notify("branch.error.list", vim.log.levels.ERROR)
        return {}
    end
    
    local branches = {}
    for line in output:gmatch("[^\r\n]+") do
        local branch = line:gsub("^%s*%*?%s*", "")
        table.insert(branches, branch)
    end
    return branches
end

-- Obtient la branche courante
M.get_current_branch = function()
    local success, output = pcall(utils.git_command, 'branch --show-current')
    if not success then
        vim.notify("branch.error.current", vim.log.levels.ERROR)
        return nil
    end
    return output:gsub("%s+", "")
end

-- Fonction pour créer une nouvelle branche
M.create_branch = function(branch_name)
    if not branch_name or branch_name == "" then
        vim.notify("branch.create.invalid", vim.log.levels.WARN)
        return false
    end

    local success = pcall(utils.git_command, 'branch ' .. branch_name)
    if not success then
        vim.notify("branch.create.error", vim.log.levels.ERROR)
        return false
    end
    
    vim.notify("branch.create.success", vim.log.levels.INFO)
    return true
end

-- Fonction pour supprimer une branche
M.delete_branch = function(branch_name)
    if not branch_name or branch_name == "" then
        vim.notify("branch.delete.invalid", vim.log.levels.ERROR)
        return false
    end

    local success = pcall(utils.git_command, 'branch -d ' .. branch_name)
    if not success then
        vim.notify("branch.delete.error", vim.log.levels.ERROR)
        return false
    end
    
    vim.notify("branch.delete.success", vim.log.levels.INFO)
    return true
end

-- Fonction pour changer de branche
M.switch_branch = function(branch_name)
    if not branch_name or branch_name == "" then
        vim.notify("branch.switch.invalid", vim.log.levels.ERROR)
        return false
    end

    local success = pcall(utils.git_command, 'checkout ' .. branch_name)
    if not success then
        vim.notify("branch.switch.error", vim.log.levels.ERROR)
        return false
    end
    
    vim.notify("branch.switch.success", vim.log.levels.INFO)
    return true
end

-- Fonction pour fusionner une branche
M.merge_branch = function(branch_name)
    if not branch_name or branch_name == "" then
        vim.notify("branch.merge.invalid", vim.log.levels.ERROR)
        return false
    end

    local success = pcall(utils.git_command, 'merge ' .. branch_name)
    if not success then
        vim.notify("branch.merge.error", vim.log.levels.ERROR)
        return false
    end
    
    vim.notify("branch.merge.success", vim.log.levels.INFO)
    return true
end

return M
