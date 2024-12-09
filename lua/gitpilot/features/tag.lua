-- lua/gitpilot/features/tag.lua

local M = {}
local ui = require('gitpilot.ui')
local utils = require('gitpilot.utils')
local i18n = require('gitpilot.i18n')

-- Configuration locale
local config = {
    max_tag_list = 100
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

-- Vérifie si un tag existe
local function tag_exists(tag_name)
    if not tag_name then return false end
    local success, _ = utils.execute_command("git rev-parse --verify --quiet refs/tags/" .. utils.escape_string(tag_name))
    return success
end

-- Liste les tags
function M.list(callback)
    if not is_git_repo() then
        ui.show_error(i18n.t('tag.error.not_git_repo'))
        return false
    end

    local success, tags = utils.execute_command(string.format(
        "git tag --sort=-creatordate -n%d",
        config.max_tag_list
    ))
    if not success then
        ui.show_error(i18n.t('tag.error.list_failed'))
        return false
    end

    local tag_list = {}
    for line in tags:gmatch("[^\r\n]+") do
        if line ~= "" then
            table.insert(tag_list, line)
        end
    end

    if #tag_list == 0 then
        ui.show_error(i18n.t('tag.error.no_tags'))
        return false
    end

    ui.select(tag_list, {
        prompt = i18n.t("tag.select_tag")
    }, function(choice)
        if choice and callback then
            callback(choice)
        end
    end)

    return true
end

-- Crée un nouveau tag
function M.create(tag_name, message)
    if not is_git_repo() then
        ui.show_error(i18n.t('tag.error.not_git_repo'))
        return false
    end

    if not tag_name or tag_name == "" then
        ui.show_error(i18n.t('tag.error.invalid_name'))
        return false
    end

    if tag_exists(tag_name) then
        ui.show_error(i18n.t('tag.error.already_exists', {name = tag_name}))
        return false
    end

    local cmd = "git tag"
    if message and message ~= "" then
        cmd = cmd .. " -a " .. utils.escape_string(tag_name) .. " -m " .. utils.escape_string(message)
    else
        cmd = cmd .. " " .. utils.escape_string(tag_name)
    end

    local success, _ = utils.execute_command(cmd)
    if not success then
        ui.show_error(i18n.t('tag.error.create_failed'))
        return false
    end

    ui.show_success(i18n.t('tag.success.created', {name = tag_name}))
    return true
end

-- Supprime un tag
function M.delete(tag_name)
    if not is_git_repo() then
        ui.show_error(i18n.t('tag.error.not_git_repo'))
        return false
    end

    if not tag_name or tag_name == "" then
        ui.show_error(i18n.t('tag.error.invalid_name'))
        return false
    end

    if not tag_exists(tag_name) then
        ui.show_error(i18n.t('tag.error.not_found', {name = tag_name}))
        return false
    end

    local success, _ = utils.execute_command("git tag -d " .. utils.escape_string(tag_name))
    if not success then
        ui.show_error(i18n.t('tag.error.delete_failed'))
        return false
    end

    ui.show_success(i18n.t('tag.success.deleted', {name = tag_name}))
    return true
end

-- Push un tag vers le remote
function M.push(tag_name)
    if not is_git_repo() then
        ui.show_error(i18n.t('tag.error.not_git_repo'))
        return false
    end

    if not tag_name or tag_name == "" then
        ui.show_error(i18n.t('tag.error.invalid_name'))
        return false
    end

    if not tag_exists(tag_name) then
        ui.show_error(i18n.t('tag.error.not_found', {name = tag_name}))
        return false
    end

    local success, _ = utils.execute_command("git push origin " .. utils.escape_string(tag_name))
    if not success then
        ui.show_error(i18n.t('tag.error.push_failed'))
        return false
    end

    ui.show_success(i18n.t('tag.success.pushed', {name = tag_name}))
    return true
end

-- Affiche les détails d'un tag
function M.show(tag_name)
    if not is_git_repo() then
        ui.show_error(i18n.t('tag.error.not_git_repo'))
        return false
    end

    if not tag_name or tag_name == "" then
        ui.show_error(i18n.t('tag.error.invalid_name'))
        return false
    end

    if not tag_exists(tag_name) then
        ui.show_error(i18n.t('tag.error.not_found', {name = tag_name}))
        return false
    end

    local success, details = utils.execute_command("git show " .. utils.escape_string(tag_name))
    if not success then
        ui.show_error(i18n.t('tag.error.show_failed'))
        return false
    end

    ui.show_preview({
        title = i18n.t('tag.preview.title', {name = tag_name}),
        content = details
    })

    return true
end

return M
