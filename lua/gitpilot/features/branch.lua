-- lua/gitpilot/features/branch.lua

local M = {}
local ui = require('gitpilot.ui')
local utils = require('gitpilot.utils')
local i18n = require('gitpilot.i18n')

-- Configuration locale
local config = {
    default_remote = "origin"
}

-- Initialisation du module
function M.setup(opts)
    if opts then
        config = vim.tbl_deep_extend("force", config, opts)
    end
end

-- Vérifie si le répertoire courant est un dépôt git
local function is_git_repo()
    local success, _ = utils.execute_command("git rev-parse --is-inside-work-tree")
    return success
end

-- Vérifie si une branche existe
local function branch_exists(branch_name)
    if not branch_name then return false end
    local success, _ = utils.execute_command("git rev-parse --verify --quiet " .. utils.escape_string(branch_name))
    return success
end

-- Récupère la liste des branches
local function get_branches()
    local success, output = utils.execute_command("git branch --no-color")
    if not success then
        return {}, nil
    end

    local branches = {}
    local current_branch = nil

    for line in output:gmatch("[^\r\n]+") do
        local is_current = line:match("^%s*%*")
        local branch = line:match("^%s*%*?%s*(.+)$")
        if branch then
            -- Supprime les espaces en début et fin
            branch = branch:gsub("^%s*(.-)%s*$", "%1")
            -- Détecte la branche courante
            if is_current then
                current_branch = branch
            end
            table.insert(branches, branch)
        end
    end

    return branches, current_branch
end

-- Liste toutes les branches et récupère la branche courante
function M.list_branches()
    if not is_git_repo() then
        ui.show_error(i18n.t('branch.error.not_git_repo'))
        return {}, nil
    end

    local branches, current_branch = get_branches()
    return branches, current_branch
end

-- Crée une nouvelle branche
function M.create_branch(branch_name, start_point)
    if not branch_name or branch_name == "" then
        ui.show_error(i18n.t('branch.error.invalid_name'))
        return false
    end

    if not is_git_repo() then
        ui.show_error(i18n.t('branch.error.not_git_repo'))
        return false
    end

    if branch_exists(branch_name) then
        ui.show_error(i18n.t('branch.error.already_exists', {name = branch_name}))
        return false
    end

    local cmd = "git branch " .. utils.escape_string(branch_name)
    if start_point then
        if not branch_exists(start_point) then
            ui.show_error(i18n.t('branch.error.invalid_start_point', {name = start_point}))
            return false
        end
        cmd = cmd .. " " .. utils.escape_string(start_point)
    end
    
    local success, _ = utils.execute_command(cmd)
    if not success then
        ui.show_error(i18n.t('branch.error.create_failed', {name = branch_name}))
        return false
    end

    ui.show_success(i18n.t('branch.success.created', {name = branch_name}))
    return true
end

-- Bascule vers une branche
function M.checkout_branch(branch_name)
    if not branch_name or branch_name == "" then
        ui.show_error(i18n.t('branch.error.invalid_name'))
        return false
    end

    if not is_git_repo() then
        ui.show_error(i18n.t('branch.error.not_git_repo'))
        return false
    end

    if not branch_exists(branch_name) then
        ui.show_error(i18n.t('branch.error.not_found', {name = branch_name}))
        return false
    end

    local success, _ = utils.execute_command("git checkout " .. utils.escape_string(branch_name))
    if not success then
        ui.show_error(i18n.t('branch.error.checkout_failed', {name = branch_name}))
        return false
    end

    ui.show_success(i18n.t('branch.success.checked_out', {name = branch_name}))
    return true
end

-- Fusionne une branche
function M.merge_branch(branch_name)
    if not branch_name or branch_name == "" then
        ui.show_error(i18n.t('branch.error.invalid_name'))
        return false
    end

    if not is_git_repo() then
        ui.show_error(i18n.t('branch.error.not_git_repo'))
        return false
    end

    if not branch_exists(branch_name) then
        ui.show_error(i18n.t('branch.error.not_found', {name = branch_name}))
        return false
    end

    -- Vérifie s'il y a des changements non commités
    local success, status = utils.execute_command("git status --porcelain")
    if success and status ~= "" then
        ui.show_warning(i18n.t('branch.warning.uncommitted_changes'))
        return false
    end

    local success, _ = utils.execute_command("git merge " .. utils.escape_string(branch_name))
    if not success then
        ui.show_error(i18n.t('branch.error.merge_failed', {name = branch_name}))
        return false
    end

    -- Vérifie s'il y a des conflits
    local _, status = utils.execute_command("git status")
    if status:match("Unmerged paths") then
        ui.show_warning(i18n.t('branch.warning.merge_conflicts', {name = branch_name}))
        return true
    end

    ui.show_success(i18n.t('branch.success.merged', {name = branch_name}))
    return true
end

-- Supprime une branche
function M.delete_branch(branch_name, force)
    if not branch_name or branch_name == "" then
        ui.show_error(i18n.t('branch.error.invalid_name'))
        return false
    end

    if not is_git_repo() then
        ui.show_error(i18n.t('branch.error.not_git_repo'))
        return false
    end

    if not branch_exists(branch_name) then
        ui.show_error(i18n.t('branch.error.not_found', {name = branch_name}))
        return false
    end

    -- Vérifie si c'est la branche courante
    local _, current_branch = M.list_branches()
    if current_branch == branch_name then
        ui.show_error(i18n.t('branch.error.delete_current'))
        return false
    end

    local flag = force and "-D" or "-d"
    local success, _ = utils.execute_command("git branch " .. flag .. " " .. utils.escape_string(branch_name))
    if not success then
        if not force then
            ui.show_error(i18n.t('branch.error.delete_unmerged', {name = branch_name}))
        else
            ui.show_error(i18n.t('branch.error.delete_failed', {name = branch_name}))
        end
        return false
    end

    ui.show_success(i18n.t('branch.success.deleted', {name = branch_name}))
    return true
end

return M