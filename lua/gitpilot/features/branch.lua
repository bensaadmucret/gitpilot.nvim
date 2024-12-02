-- lua/gitpilot/features/branch.lua

local M = {}
local ui = require('gitpilot.ui')
local utils = require('gitpilot.utils')
local i18n = require('gitpilot.i18n')

-- Check if current directory is a git repository
local function is_git_repo()
    local result = utils.execute_command("git rev-parse --is-inside-work-tree")
    return result ~= nil
end

-- List all branches and get current branch
function M.list_branches()
    if not is_git_repo() then
        ui.show_error('error.not_git_repo', {}, ui.levels.ERROR)
        return nil, nil
    end

    local result = utils.execute_command("git branch --no-color")
    if not result then
        ui.show_error('error.branch_list_failed', {}, ui.levels.ERROR)
        return nil, nil
    end

    local branches = {}
    local current_branch = nil
    
    for line in result:gmatch("[^\r\n]+") do
        local branch = line:match("^%s*%*?%s*(.+)$")
        if branch then
            if line:match("^%s*%*") then
                current_branch = branch
            end
            table.insert(branches, branch)
        end
    end

    return branches, current_branch
end

-- Create a new branch
function M.create_branch(branch_name, start_point)
    if not branch_name or branch_name == "" then
        ui.show_error('error.invalid_branch_name', {}, ui.levels.ERROR)
        return false
    end

    if not is_git_repo() then
        ui.show_error('error.not_git_repo', {}, ui.levels.ERROR)
        return false
    end

    local cmd = "git checkout -b " .. utils.escape_string(branch_name)
    if start_point then
        cmd = cmd .. " " .. utils.escape_string(start_point)
    end
    
    local result = utils.execute_command(cmd)
    if not result then
        ui.show_error('error.branch_creation_failed', {branch = branch_name}, ui.levels.ERROR)
        return false
    end

    ui.show_info('info.branch_created', {branch = branch_name})
    return true
end

-- Switch to a branch
function M.switch_branch(branch_name)
    if not branch_name or branch_name == "" then
        ui.show_error('error.invalid_branch_name', {}, ui.levels.ERROR)
        return false
    end

    if not is_git_repo() then
        ui.show_error('error.not_git_repo', {}, ui.levels.ERROR)
        return false
    end

    local cmd = "git checkout " .. utils.escape_string(branch_name)
    local result = utils.execute_command(cmd)
    if not result then
        ui.show_error('error.branch_switch_failed', {branch = branch_name}, ui.levels.ERROR)
        return false
    end

    ui.show_info('info.branch_switched', {branch = branch_name})
    return true
end

-- Merge a branch
function M.merge_branch(branch_name)
    if not branch_name or branch_name == "" then
        ui.show_error('error.invalid_branch_name', {}, ui.levels.ERROR)
        return false
    end

    if not is_git_repo() then
        ui.show_error('error.not_git_repo', {}, ui.levels.ERROR)
        return false
    end

    local cmd = "git merge " .. utils.escape_string(branch_name)
    local result = utils.execute_command(cmd)
    if not result then
        ui.show_error('error.branch_merge_failed', {branch = branch_name}, ui.levels.ERROR)
        return false
    end

    ui.show_info('info.branch_merged', {branch = branch_name})
    return true
end

-- Delete a branch
function M.delete_branch(branch_name, force)
    if not branch_name or branch_name == "" then
        ui.show_error('error.invalid_branch_name', {}, ui.levels.ERROR)
        return false
    end

    if not is_git_repo() then
        ui.show_error('error.not_git_repo', {}, ui.levels.ERROR)
        return false
    end

    local flag = force and "-D" or "-d"
    local cmd = "git branch " .. flag .. " " .. utils.escape_string(branch_name)
    local result = utils.execute_command(cmd)
    if not result then
        ui.show_error('error.branch_deletion_failed', {branch = branch_name}, ui.levels.ERROR)
        return false
    end

    ui.show_info('info.branch_deleted', {branch = branch_name})
    return true
end

-- Show branch menu
function M.show()
    if not is_git_repo() then
        return
    end

    local branches, current_branch = M.list_branches()
    if not branches then
        ui.show_error("error.branch_list_failed", {}, ui.levels.ERROR)
        return
    end

    local actions = {
        i18n.t("branch.create_new"),
        i18n.t("branch.checkout"),
        i18n.t("branch.merge"),
        i18n.t("branch.delete"),
        i18n.t("branch.refresh")
    }

    ui.select(actions, {
        prompt = i18n.t("branch.title")
    }, function(choice)
        if not choice then return end

        if choice == actions[1] then  -- Create new
            vim.ui.input({
                prompt = i18n.t("branch.enter_name")
            }, function(name)
                if name then
                    M.create_branch(name)
                end
            end)
        elseif choice == actions[2] then  -- Checkout
            ui.select(branches, {
                prompt = i18n.t("branch.checkout")
            }, function(branch)
                if branch then
                    M.switch_branch(branch)
                end
            end)
        elseif choice == actions[3] then  -- Merge
            ui.select(branches, {
                prompt = i18n.t("branch.merge")
            }, function(branch)
                if branch then
                    M.merge_branch(branch)
                end
            end)
        elseif choice == actions[4] then  -- Delete
            ui.select(branches, {
                prompt = i18n.t("branch.delete")
            }, function(branch)
                if branch then
                    if branch == current_branch then
                        ui.show_error("branch.error.delete_current")
                        return
                    end
                    M.delete_branch(branch)
                end
            end)
        elseif choice == actions[5] then  -- Refresh
            M.show()
        end
    end)
end

return M