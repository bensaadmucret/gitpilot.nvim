-- lua/gitpilot/features/stash.lua

local M = {}
local ui = require('gitpilot.ui')
local utils = require('gitpilot.utils')
local i18n = require('gitpilot.i18n')

-- Configuration locale
local config = {
    max_stash_list = 50
}

-- Initialisation du module
function M.setup(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})
end

-- Vérifie si le répertoire courant est un dépôt git
local function is_git_repo()
    local success, _ = utils.execute_command("git rev-parse --is-inside-work-tree")
    return success
end

-- Vérifie si un stash existe
local function stash_exists(stash_id)
    if not stash_id then return false end
    local success, _ = utils.execute_command("git rev-parse --verify --quiet " .. utils.escape_string(stash_id))
    return success
end

-- Liste les stashs
function M.list(callback)
    if not is_git_repo() then
        ui.show_error(i18n.t('stash.error.not_git_repo'))
        return false
    end

    local success, stashes = utils.execute_command(string.format(
        "git stash list -n %d --pretty=format:'%%gd - %%s'",
        config.max_stash_list
    ))
    if not success then
        ui.show_error(i18n.t('stash.error.list_failed'))
        return false
    end

    local stash_list = {}
    local stash_ids = {}
    for line in stashes:gmatch("[^\r\n]+") do
        local id = line:match("^(stash@{%d+})")
        if id then
            table.insert(stash_list, line)
            table.insert(stash_ids, id)
        end
    end

    if #stash_list == 0 then
        ui.show_error(i18n.t('stash.error.no_stashes'))
        return false
    end

    ui.select(stash_list, {
        prompt = i18n.t("stash.select_stash")
    }, function(choice)
        if choice then
            local index = vim.tbl_contains(stash_list, choice)
            if index and callback then
                callback(stash_ids[index])
            end
        end
    end)

    return true
end

-- Crée un nouveau stash
function M.save(message)
    if not is_git_repo() then
        ui.show_error(i18n.t('stash.error.not_git_repo'))
        return false
    end

    -- Vérifie s'il y a des changements à stasher
    local success, status = utils.execute_command("git status --porcelain")
    if not success or status == "" then
        ui.show_error(i18n.t('stash.error.no_changes'))
        return false
    end

    local cmd = "git stash push"
    if message and message ~= "" then
        cmd = cmd .. " -m " .. utils.escape_string(message)
    end

    local success, _ = utils.execute_command(cmd)
    if not success then
        ui.show_error(i18n.t('stash.error.save_failed'))
        return false
    end

    ui.show_success(i18n.t('stash.success.saved'))
    return true
end

-- Applique et supprime un stash
function M.pop(stash_id)
    if not is_git_repo() then
        ui.show_error(i18n.t('stash.error.not_git_repo'))
        return false
    end

    if not stash_exists(stash_id) then
        ui.show_error(i18n.t('stash.error.invalid_stash'))
        return false
    end

    local success, _ = utils.execute_command("git stash pop " .. utils.escape_string(stash_id))
    if not success then
        ui.show_error(i18n.t('stash.error.pop_failed'))
        return false
    end

    ui.show_success(i18n.t('stash.success.popped'))
    return true
end

-- Applique un stash sans le supprimer
function M.apply(stash_id)
    if not is_git_repo() then
        ui.show_error(i18n.t('stash.error.not_git_repo'))
        return false
    end

    if not stash_exists(stash_id) then
        ui.show_error(i18n.t('stash.error.invalid_stash'))
        return false
    end

    local success, _ = utils.execute_command("git stash apply " .. utils.escape_string(stash_id))
    if not success then
        ui.show_error(i18n.t('stash.error.apply_failed'))
        return false
    end

    ui.show_success(i18n.t('stash.success.applied'))
    return true
end

-- Supprime un stash
function M.drop(stash_id)
    if not is_git_repo() then
        ui.show_error(i18n.t('stash.error.not_git_repo'))
        return false
    end

    if not stash_exists(stash_id) then
        ui.show_error(i18n.t('stash.error.invalid_stash'))
        return false
    end

    local success, _ = utils.execute_command("git stash drop " .. utils.escape_string(stash_id))
    if not success then
        ui.show_error(i18n.t('stash.error.drop_failed'))
        return false
    end

    ui.show_success(i18n.t('stash.success.dropped'))
    return true
end

-- Affiche le contenu d'un stash
function M.show(stash_id)
    if not is_git_repo() then
        ui.show_error(i18n.t('stash.error.not_git_repo'))
        return false
    end

    if not stash_exists(stash_id) then
        ui.show_error(i18n.t('stash.error.invalid_stash'))
        return false
    end

    local success, details = utils.execute_command("git stash show -p " .. utils.escape_string(stash_id))
    if not success then
        ui.show_error(i18n.t('stash.error.show_failed'))
        return false
    end

    ui.show_preview({
        title = i18n.t('stash.preview.title', {id = stash_id}),
        content = details
    })

    return true
end

-- Supprime tous les stashs
function M.clear()
    if not is_git_repo() then
        ui.show_error(i18n.t('stash.error.not_git_repo'))
        return false
    end

    local success, _ = utils.execute_command("git stash clear")
    if not success then
        ui.show_error(i18n.t('stash.error.clear_failed'))
        return false
    end

    ui.show_success(i18n.t('stash.success.cleared'))
    return true
end

return M
