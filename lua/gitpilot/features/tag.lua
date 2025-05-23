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

-- Helper asynchrone pour vérifier si le répertoire courant est un dépôt git
-- Helper asynchrone sécurisé : n'appelle cb qu'avec un booléen (pour compatibilité Busted)
local function is_git_repo_async(cb)
  utils.execute_command_async("git rev-parse --is-inside-work-tree", function(success)
    -- On ne transmet qu'un booléen, jamais plus d'arguments, pour éviter les soucis d'upvalue avec Busted
    if type(cb) == "function" then cb(success) end
  end)
end

-- Helper asynchrone sécurisé : n'appelle cb qu'avec un booléen (pour compatibilité Busted)
local function tag_exists_async(tag_name, cb)
  if not tag_name then if type(cb) == "function" then cb(false) end; return end
  utils.execute_command_async("git rev-parse --verify --quiet refs/tags/" .. utils.escape_string(tag_name), function(success)
    -- On ne transmet qu'un booléen
    if type(cb) == "function" then cb(success) end
  end)
end

-- Synchrone legacy
local function is_git_repo()
    local success, _ = utils.execute_command("git rev-parse --is-inside-work-tree")
    return success
end

local function tag_exists(tag_name)
    if not tag_name then return false end
    local success, _ = utils.execute_command("git rev-parse --verify --quiet refs/tags/" .. utils.escape_string(tag_name))
    return success
end

-- Liste les tags
-- Version asynchrone de la liste des tags
function M.list_async(callback)
    local function on_tags(success, tags)
        if not success then
            ui.show_error(i18n.t('tag.error.list_failed'))
            if type(callback) == "function" then callback(false) end
            return
        end
        local tag_list = {}
        for line in (tags or ''):gmatch("[^\r\n]+") do
            if line ~= "" then table.insert(tag_list, line) end
        end
        if #tag_list == 0 then
            ui.show_error(i18n.t('tag.error.no_tags'))
            if type(callback) == "function" then callback(false) end
            return
        end
        ui.select(tag_list, {
            prompt = i18n.t("tag.select_tag")
        }, function(choice)
            if type(callback) == "function" then
                if choice then callback(true, choice) else callback(false) end
            end
        end)
    end
    local function on_repo(repo_ok)
        if not repo_ok then
            ui.show_error(i18n.t('tag.error.not_git_repo'))
            if type(callback) == "function" then callback(false) end
            return
        end
        local cmd = string.format("git tag --sort=-creatordate -n%d", config.max_tag_list)
        utils.execute_command_async(cmd, on_tags)
    end
    is_git_repo_async(on_repo)
end

-- Version synchrone (dépréciée)
function M.list(callback)
    (vim and vim.schedule or function(f) f() end)(function()
        if vim and vim.notify then vim.notify('tag.list synchrone est déprécié. Utilisez list_async.', vim.log.levels.WARN) end
    end)
    if not is_git_repo() then
        ui.show_error(i18n.t('tag.error.not_git_repo'))
        return false
    end
    local success, tags = utils.execute_command(string.format("git tag --sort=-creatordate -n%d", config.max_tag_list))
    if not success then
        ui.show_error(i18n.t('tag.error.list_failed'))
        return false
    end
    local tag_list = {}
    for line in tags:gmatch("[^\r\n]+") do
        if line ~= "" then table.insert(tag_list, line) end
    end
    if #tag_list == 0 then
        ui.show_error(i18n.t('tag.error.no_tags'))
        return false
    end
    ui.select(tag_list, {
        prompt = i18n.t("tag.select_tag")
    }, function(choice)
        if choice and callback then callback(choice) end
    end)
    return true
end

-- Crée un nouveau tag
-- Version asynchrone de la création de tag
function M.create_async(tag_name, message, callback)
    -- Utiliser le callback tel quel, toujours vérifier son type (compatibilité Busted/upvalue)
    is_git_repo_async(function(repo_ok)
        if not repo_ok then
            ui.show_error(i18n.t('tag.error.not_git_repo'))
            if type(callback) == "function" then callback(false) end
            return
        end
        if not tag_name or tag_name == "" then
            ui.show_error(i18n.t('tag.error.invalid_name'))
            if type(callback) == "function" then callback(false) end
            return
        end
        tag_exists_async(tag_name, function(exists)
            if exists then
                ui.show_error(i18n.t('tag.error.already_exists', {name = tag_name}))
                if type(callback) == "function" then callback(false) end
                return
            end
            local cmd = string.format('git tag %s %s',
                message and ('-a ' .. utils.escape_string(tag_name) .. ' -m ' .. utils.escape_string(message))
                or utils.escape_string(tag_name),
                message and '' or '')
            utils.execute_command_async(cmd, function(success)
                if not success then
                    ui.show_error(i18n.t('tag.error.create_failed'))
                    if type(callback) == "function" then callback(false) end
                    return
                end
                ui.show_success(i18n.t('tag.success.created', {name = tag_name}))
                if type(callback) == "function" then callback(true) end
            end)
        end)
    end)
end

-- Version synchrone (dépréciée)
function M.create(tag_name, message)
    (vim and vim.schedule or function(f) f() end)(function()
        if vim and vim.notify then vim.notify('tag.create synchrone est déprécié. Utilisez create_async.', vim.log.levels.WARN) end
    end)
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
-- Version asynchrone de la suppression de tag
function M.delete_async(tag_name, callback)
    -- Utiliser le callback tel quel, toujours vérifier son type (compatibilité Busted/upvalue)
    is_git_repo_async(function(repo_ok)
    if not repo_ok then
        ui.show_error(i18n.t('tag.error.not_git_repo'))
        if type(callback) == "function" then callback(false) end
        return
    end
    if not tag_name or tag_name == "" then
        ui.show_error(i18n.t('tag.error.invalid_name'))
        if type(callback) == "function" then callback(false) end
        return
    end
    -- Toujours envelopper le callback utilisateur pour préserver l'upvalue (compatibilité Busted)
tag_exists_async(tag_name, function(exists)
    if not exists then
        ui.show_error(i18n.t('tag.error.not_found', {name = tag_name}))
        if type(callback) == "function" then callback(false) end
        return
    end
    utils.execute_command_async("git tag -d " .. utils.escape_string(tag_name), function(success)
        if not success then
            ui.show_error(i18n.t('tag.error.delete_failed'))
            if type(callback) == "function" then callback(false) end
            return
        end
        ui.show_success(i18n.t('tag.success.deleted', {name = tag_name}))
        if type(callback) == "function" then callback(true) end
    end)
end)
end)
end

-- Version synchrone (dépréciée)
function M.delete(tag_name)
    (vim and vim.schedule or function(f) f() end)(function()
        if vim and vim.notify then vim.notify('tag.delete synchrone est déprécié. Utilisez delete_async.', vim.log.levels.WARN) end
    end)
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
-- Version asynchrone du push de tag
function M.push_async(tag_name, callback)
    -- Utiliser le callback tel quel, toujours vérifier son type (compatibilité Busted/upvalue)
    is_git_repo_async(function(repo_ok)
    if not repo_ok then
        ui.show_error(i18n.t('tag.error.not_git_repo'))
        if type(callback) == "function" then callback(false) end
        return
    end
    if not tag_name or tag_name == "" then
        ui.show_error(i18n.t('tag.error.invalid_name'))
        if type(callback) == "function" then callback(false) end
        return
    end
    -- Toujours envelopper le callback utilisateur pour préserver l'upvalue (compatibilité Busted)
tag_exists_async(tag_name, function(exists)
    if not exists then
        ui.show_error(i18n.t('tag.error.not_found', {name = tag_name}))
        if type(callback) == "function" then callback(false) end
        return
    end
    utils.execute_command_async("git push origin " .. utils.escape_string(tag_name), function(success)
        if not success then
            ui.show_error(i18n.t('tag.error.push_failed'))
            if type(callback) == "function" then callback(false) end
            return
        end
        ui.show_success(i18n.t('tag.success.pushed', {name = tag_name}))
        if type(callback) == "function" then callback(true) end
    end)
end)
end)
end

-- Version synchrone (dépréciée)
function M.push(tag_name)
    (vim and vim.schedule or function(f) f() end)(function()
        if vim and vim.notify then vim.notify('tag.push synchrone est déprécié. Utilisez push_async.', vim.log.levels.WARN) end
    end)
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
-- Version asynchrone de l'affichage des détails d'un tag
function M.show_async(tag_name, callback)
    -- Utiliser le callback tel quel, toujours vérifier son type (compatibilité Busted/upvalue)
    is_git_repo_async(function(repo_ok)
    if not repo_ok then
        ui.show_error(i18n.t('tag.error.not_git_repo'))
        if type(callback) == "function" then callback(false) end
        return
    end
    if not tag_name or tag_name == "" then
        ui.show_error(i18n.t('tag.error.invalid_name'))
        if type(callback) == "function" then callback(false) end
        return
    end
    -- Toujours envelopper le callback utilisateur pour préserver l'upvalue (compatibilité Busted)
tag_exists_async(tag_name, function(exists)
    if not exists then
        ui.show_error(i18n.t('tag.error.not_found', {name = tag_name}))
        if type(callback) == "function" then callback(false) end
        return
    end
    utils.execute_command_async("git show " .. utils.escape_string(tag_name), function(success, details)
        if not success then
            ui.show_error(i18n.t('tag.error.show_failed'))
            if type(callback) == "function" then callback(false) end
            return
        end
        ui.show_preview({
            title = i18n.t('tag.preview.title', {name = tag_name}),
            content = details
        })
        if type(callback) == "function" then callback(true, details) end
    end)
end)
end)
end

-- Version synchrone (dépréciée)
function M.show(tag_name)
    (vim and vim.schedule or function(f) f() end)(function()
        if vim and vim.notify then vim.notify('tag.show synchrone est déprécié. Utilisez show_async.', vim.log.levels.WARN) end
    end)
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
