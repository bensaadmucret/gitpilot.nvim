-- lua/gitpilot/features/remote.lua

local M = {}
local ui = require('gitpilot.ui')
local utils = require('gitpilot.utils')
local i18n = require('gitpilot.i18n')

-- Configuration locale
local config = {}

-- Initialisation du module
function M.setup(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})
end

-- Vérifie si le répertoire courant est un dépôt git
local function is_git_repo()
    local success, _ = utils.execute_command("git rev-parse --is-inside-work-tree")
    return success
end

-- Vérifie si un remote existe
local function remote_exists(remote_name)
    if not remote_name then return false end
    local success, _ = utils.execute_command("git remote get-url " .. utils.escape_string(remote_name))
    return success
end

-- Liste les remotes
function M.list(callback)
    if not is_git_repo() then
        ui.show_error(i18n.t('remote.error.not_git_repo'))
        return false
    end

    local success, remotes = utils.execute_command("git remote")
    if not success then
        ui.show_error(i18n.t('remote.error.list_failed'))
        return false
    end

    local remote_list = {}
    for line in remotes:gmatch("[^\r\n]+") do
        if line ~= "" then
            table.insert(remote_list, line)
        end
    end

    if #remote_list == 0 then
        ui.show_error(i18n.t('remote.error.no_remotes'))
        return false
    end

    ui.select(remote_list, {
        prompt = i18n.t("remote.select_remote")
    }, function(choice)
        if choice and callback then
            callback(choice)
        end
    end)

    return true
end

-- Ajoute un nouveau remote
function M.add(remote_name, url)
    if not is_git_repo() then
        ui.show_error(i18n.t('remote.error.not_git_repo'))
        return false
    end

    if not remote_name or remote_name == "" then
        ui.show_error(i18n.t('remote.error.invalid_name'))
        return false
    end

    if not url or url == "" then
        ui.show_error(i18n.t('remote.error.invalid_url'))
        return false
    end

    if remote_exists(remote_name) then
        ui.show_error(i18n.t('remote.error.already_exists', {name = remote_name}))
        return false
    end

    local success, _ = utils.execute_command("git remote add " .. utils.escape_string(remote_name) .. " " .. utils.escape_string(url))
    if not success then
        ui.show_error(i18n.t('remote.error.add_failed'))
        return false
    end

    ui.show_success(i18n.t('remote.success.added', {name = remote_name}))
    return true
end

-- Supprime un remote
function M.remove(remote_name)
    if not is_git_repo() then
        ui.show_error(i18n.t('remote.error.not_git_repo'))
        return false
    end

    if not remote_name or remote_name == "" then
        ui.show_error(i18n.t('remote.error.invalid_name'))
        return false
    end

    if not remote_exists(remote_name) then
        ui.show_error(i18n.t('remote.error.not_found', {name = remote_name}))
        return false
    end

    local success, _ = utils.execute_command("git remote remove " .. utils.escape_string(remote_name))
    if not success then
        ui.show_error(i18n.t('remote.error.remove_failed'))
        return false
    end

    ui.show_success(i18n.t('remote.success.removed', {name = remote_name}))
    return true
end

-- Fetch depuis un remote
function M.fetch(remote_name)
    if not is_git_repo() then
        ui.show_error(i18n.t('remote.error.not_git_repo'))
        return false
    end

    if not remote_name or remote_name == "" then
        ui.show_error(i18n.t('remote.error.invalid_name'))
        return false
    end

    if not remote_exists(remote_name) then
        ui.show_error(i18n.t('remote.error.not_found', {name = remote_name}))
        return false
    end

    local success, _ = utils.execute_command("git fetch " .. utils.escape_string(remote_name))
    if not success then
        ui.show_error(i18n.t('remote.error.fetch_failed'))
        return false
    end

    ui.show_success(i18n.t('remote.success.fetched', {name = remote_name}))
    return true
end

-- Pull depuis un remote
function M.pull(remote_name)
    if not is_git_repo() then
        ui.show_error(i18n.t('remote.error.not_git_repo'))
        return false
    end

    if not remote_name or remote_name == "" then
        ui.show_error(i18n.t('remote.error.invalid_name'))
        return false
    end

    if not remote_exists(remote_name) then
        ui.show_error(i18n.t('remote.error.not_found', {name = remote_name}))
        return false
    end

    -- Vérifie s'il y a des changements non commités
    local success, status = utils.execute_command("git status --porcelain")
    if success and status ~= "" then
        ui.show_warning(i18n.t('remote.warning.uncommitted_changes'))
        return false
    end

    local success, _ = utils.execute_command("git pull " .. utils.escape_string(remote_name))
    if not success then
        ui.show_error(i18n.t('remote.error.pull_failed'))
        return false
    end

    ui.show_success(i18n.t('remote.success.pulled', {name = remote_name}))
    return true
end

-- Push vers un remote
function M.push(remote_name)
    if not is_git_repo() then
        ui.show_error(i18n.t('remote.error.not_git_repo'))
        return false
    end

    if not remote_name or remote_name == "" then
        ui.show_error(i18n.t('remote.error.invalid_name'))
        return false
    end

    if not remote_exists(remote_name) then
        ui.show_error(i18n.t('remote.error.not_found', {name = remote_name}))
        return false
    end

    local success, _ = utils.execute_command("git push " .. utils.escape_string(remote_name))
    if not success then
        ui.show_error(i18n.t('remote.error.push_failed'))
        return false
    end

    ui.show_success(i18n.t('remote.success.pushed', {name = remote_name}))
    return true
end

-- Nettoie les branches supprimées d'un remote
function M.prune(remote_name)
    if not is_git_repo() then
        ui.show_error(i18n.t('remote.error.not_git_repo'))
        return false
    end

    if not remote_name or remote_name == "" then
        ui.show_error(i18n.t('remote.error.invalid_name'))
        return false
    end

    if not remote_exists(remote_name) then
        ui.show_error(i18n.t('remote.error.not_found', {name = remote_name}))
        return false
    end

    local success, _ = utils.execute_command("git remote prune " .. utils.escape_string(remote_name))
    if not success then
        ui.show_error(i18n.t('remote.error.prune_failed'))
        return false
    end

    ui.show_success(i18n.t('remote.success.pruned', {name = remote_name}))
    return true
end

return M
