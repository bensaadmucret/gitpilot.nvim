-- lua/gitpilot/features/branch.lua

local M = {}
local utils = require('gitpilot.utils')
local i18n = require('gitpilot.i18n')
local ui = require('gitpilot.ui')

-- Setup function
M.setup = function(opts)
    opts = opts or {}
end

-- Check if current directory is a git repository
local function is_git_repo()
    local result = utils.execute_command('git rev-parse --is-inside-work-tree')
    if not result.success then
        ui.show_error("error.not_git_repo")
        return false
    end
    return true
end

-- List branches
M.list_branches = function()
    if not is_git_repo() then
        return {}, nil
    end

    local result = utils.execute_command('git branch')
    if not result.success then
        return {}, nil
    end

    local branches = {}
    local current = nil
    for line in result.stdout:gmatch("[^\r\n]+") do
        local branch = line:match("^%s*(.+)$")
        if branch then
            if branch:sub(1, 1) == "*" then
                branch = branch:sub(3)
                current = branch
            else
                branch = branch:gsub("^%s+", "")
            end
            table.insert(branches, branch)
        end
    end

    return branches, current
end

-- Create branch
M.create_branch = function(name, start_point)
    if not name or name == "" then
        ui.show_error("branch.error.invalid_name")
        return false
    end

    if not is_git_repo() then
        return false
    end

    local cmd = 'git checkout -b ' .. utils.escape_string(name)
    if start_point then
        cmd = cmd .. ' ' .. utils.escape_string(start_point)
    end

    local result = utils.execute_command(cmd)
    if result.success then
        ui.show_info("branch.success.created", {name = name})
        return true
    else
        ui.show_error("branch.error.create_failed", {name = name})
        return false
    end
end

-- Switch branch
M.switch_branch = function(name)
    if not name or name == "" then
        ui.show_error("branch.error.invalid_name")
        return false
    end

    if not is_git_repo() then
        return false
    end

    local result = utils.execute_command('git checkout ' .. utils.escape_string(name))
    if result.success then
        ui.show_info("branch.success.checked_out", {name = name})
        return true
    else
        ui.show_error("branch.error.checkout_failed", {name = name})
        return false
    end
end

-- Merge branch
M.merge_branch = function(name)
    if not name or name == "" then
        ui.show_error("branch.error.invalid_name")
        return false
    end

    if not is_git_repo() then
        return false
    end

    local result = utils.execute_command('git merge ' .. utils.escape_string(name))
    if result.success then
        ui.show_info("branch.success.merged", {name = name})
        return true
    else
        ui.show_error("branch.error.merge_failed", {name = name})
        return false
    end
end

-- Delete branch
M.delete_branch = function(name, force)
    if not name or name == "" then
        ui.show_error("branch.error.invalid_name")
        return false
    end

    if not is_git_repo() then
        return false
    end

    local flag = force and '-D' or '-d'
    local result = utils.execute_command('git branch ' .. flag .. ' ' .. utils.escape_string(name))
    if result.success then
        ui.show_info("branch.success.deleted", {name = name})
        return true
    else
        ui.show_error("branch.error.delete_failed", {name = name})
        return false
    end
end

-- Show branch menu
M.show = function()
    if not is_git_repo() then
        return
    end

    local branches, current = M.list_branches()
    if not branches then
        ui.show_error("branch.error.list_failed")
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
                    if branch == current then
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