-- lua/gitpilot/features/branch.lua

local M = {}
local config = {}
local vim = vim
local i18n = require('gitpilot.i18n')
local utils = require('gitpilot.utils')
local ui = require('gitpilot.ui')

-- Check if we're in a Git repository
local function is_git_repo()
    local result = utils.execute_command("git rev-parse --is-inside-work-tree")
    if not result then
        ui.show_error("git.not_repo")
        return false
    end
    return true
end

-- Setup function to initialize the module
function M.setup(opts)
    config = vim.tbl_deep_extend('force', {
        notifications = true
    }, opts or {})
end

-- List all branches
function M.list_branches()
    if not is_git_repo() then
        return {}, ""
    end

    local output = utils.execute_command("git branch --all")
    if not output then
        ui.show_error("branch.list_error")
        return {}, ""
    end

    local branches = {}
    local current = ""

    for line in output:gmatch("[^\r\n]+") do
        local branch = line:gsub("^%s*", ""):gsub("%s*$", "")
        if branch:sub(1, 1) == "*" then
            branch = branch:sub(2):gsub("^%s*", "")
            current = branch
        end
        if branch ~= "" then
            table.insert(branches, branch)
        end
    end

    return branches, current
end

-- Create a new branch
function M.create_branch(name)
    if not is_git_repo() then return end
    
    if not name or name == "" then
        ui.show_error("branch.error.invalid_name")
        return
    end

    local result = utils.execute_command(string.format("git branch %s", name))
    if result then
        ui.show_info("branch.create_success", { name = name })
    else
        ui.show_error("branch.create_error", { name = name })
    end
end

-- Checkout (switch to) a branch
function M.checkout_branch(name)
    if not is_git_repo() then return end

    if not name or name == "" then
        ui.show_error("branch.error.invalid_name")
        return
    end

    local result = utils.execute_command(string.format("git checkout %s", name))
    if result then
        ui.show_info("branch.checkout_success", { name = name })
    else
        ui.show_error("branch.checkout_error", { name = name })
    end
end

-- Switch to a branch
function M.switch_branch(name)
    if not is_git_repo() then return end

    if not name or name == "" then
        ui.show_error("branch.error.invalid_name")
        return
    end

    local result = utils.execute_command(string.format("git checkout %s", name))
    if result then
        ui.show_info("branch.switch_success", { name = name })
    else
        ui.show_error("branch.switch_error", { name = name })
    end
end

-- Merge a branch into the current branch
function M.merge_branch(name)
    if not is_git_repo() then return end

    if not name or name == "" then
        ui.show_error("branch.error.invalid_name")
        return
    end

    local result = utils.execute_command(string.format("git merge %s", name))
    if not result then
        ui.show_error("branch.merge_error", { name = name })
        return
    end

    -- Check for merge conflicts
    local status = utils.execute_command("git status")
    if status and status:match("Unmerged paths") then
        ui.show_warning("branch.merge_conflict", { name = name })
    else
        ui.show_info("branch.merge_success", { name = name })
    end
end

-- Delete a branch
function M.delete_branch(name, force)
    if not is_git_repo() then return end

    if not name or name == "" then
        ui.show_error("branch.error.invalid_name")
        return
    end

    local flag = force and "-D" or "-d"
    local result = utils.execute_command(string.format("git branch %s %s", flag, name))
    if result then
        ui.show_info("branch.delete_success", { name = name })
    else
        ui.show_error("branch.delete_error", { name = name })
    end
end

-- Show branch menu
function M.show()
    if not is_git_repo() then
        return
    end

    local branches, current = M.list_branches()  -- Utilise list_branches() qui utilise déjà git branch --all
    if #branches == 0 then
        ui.show_info("branch.no_branches")
        return
    end

    local actions = {
        { label = i18n.t("branch.create"), action = "create" },
        { label = i18n.t("branch.switch"), action = "switch" },
        { label = i18n.t("branch.merge"), action = "merge" },
        { label = i18n.t("branch.delete"), action = "delete" }
    }

    ui.select(actions, {
        prompt = i18n.t("branch.select_action"),
        format_item = function(item) return item.label end
    }, function(choice)
        if not choice then return end
        
        if choice.action == "create" then
            vim.ui.input({
                prompt = i18n.t("branch.enter_name")
            }, function(name)
                if name then M.create_branch(name) end
            end)
        elseif choice.action == "switch" then
            ui.select(branches, {
                prompt = i18n.t("branch.select_switch")
            }, function(branch)
                if branch then M.switch_branch(branch) end
            end)
        elseif choice.action == "merge" then
            ui.select(branches, {
                prompt = i18n.t("branch.select_merge")
            }, function(branch)
                if branch then M.merge_branch(branch) end
            end)
        elseif choice.action == "delete" then
            ui.select(branches, {
                prompt = i18n.t("branch.select_delete")
            }, function(branch)
                if branch then M.delete_branch(branch) end
            end)
        end
    end)
end

return M