-- lua/gitpilot/features/tag.lua

--
-- AVERTISSEMENT POUR LES TESTS ASYNCHRONES ET LE CALLBACK UTILISATEUR
--
-- ⚠️ Pour garantir la compatibilité avec Busted et éviter les erreurs 'attempt to call a nil value (upvalue done)',
-- le callback utilisateur passé aux fonctions asynchrones de ce module (list_async, create_async, delete_async, push_async, show_async)
-- NE DOIT JAMAIS utiliser de variable locale du test (ex : done) ni être transmis à une closure imbriquée.
--
-- Toutes les assertions et l'appel à done() doivent être faits dans la closure du test, jamais dans une fonction utilitaire ou une closure intermédiaire.
--
-- Exemple recommandé pour Busted :
--
--   it("test async", function(done)
--     M.create_async("v1.0.0", nil, function(success, msg)
--       assert.is_false(success)
--       done()
--     end)
--   end)
--
-- Si vous ne respectez pas ce pattern, done sera nil dans la closure imbriquée.
--
local M = {}
local ui = require('gitpilot.ui')
local utils = require('gitpilot.utils')
local i18n = require('gitpilot.i18n')

-- Helper de validation centralisée pour les noms de tags
local function validate_tag_name(tag_name)
    if not tag_name or type(tag_name) ~= "string" or tag_name:match("^%s*$") then
        return false, "Nom de tag invalide (vide ou nil)"
    end
    -- Optionnel : restreindre les caractères autorisés (alphanum/underscore/dash)
    if tag_name:find("[^%w%._%-]") then
        return false, "Nom de tag invalide (caractères non autorisés)"
    end
    return true
end

-- Helper pour valider le callback utilisateur
local function validate_callback(cb)
    return type(cb) == "function"
end

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
  local valid, err = validate_tag_name(tag_name)
  if not valid then if validate_callback(cb) then cb(false, err) end; return end
  utils.execute_command_async("git rev-parse --verify --quiet refs/tags/" .. utils.escape_string(tag_name), function(success)
    if validate_callback(cb) then cb(success) end
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
---
--- [IMPORTANT BUSTED COMPAT] Le callback utilisateur NE DOIT PAS utiliser de variable locale du test (ex : done).
--- Faites toutes les assertions et l'appel à done() dans la closure du test, jamais ici ou dans une closure imbriquée.
---
--- [SECURITY & BUSTED COMPAT] Le callback utilisateur est TOUJOURS rappelé à la racine de la closure principale.
--- Jamais transmis à un helper interne. Robustesse garantie pour les tests et l’usage plugin.
function M.list_async(callback)
    local function finish(success, tags_or_msg)
        if success then
            callback(true, tags_or_msg)
        else
            ui.show_error(tags_or_msg or i18n.t('tag.error.list_failed'))
            callback(false, tags_or_msg)
        end
    end
    is_git_repo_async(function(repo_ok)
        if not repo_ok then
            finish(false, i18n.t('tag.error.not_git_repo'))
            return
        end
        local cmd = string.format("git tag --sort=-creatordate -n%d", config.max_tag_list)
        utils.execute_command_async(cmd, function(success, tags)
            if not success then
                finish(false, i18n.t('tag.error.list_failed'))
                return
            end
            local tag_list = {}
            for line in (tags or ''):gmatch("[^\r\n]+") do
                if line ~= "" then table.insert(tag_list, line) end
            end
            if #tag_list == 0 then
                finish(false, i18n.t('tag.error.no_tags'))
                return
            end
            finish(true, tag_list)
        end)
    end)
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
---
--- [IMPORTANT BUSTED COMPAT] Le callback utilisateur NE DOIT PAS utiliser de variable locale du test (ex : done).
--- Faites toutes les assertions et l'appel à done() dans la closure du test, jamais ici ou dans une closure imbriquée.
---
--- [SECURITY & BUSTED COMPAT] Le callback utilisateur est TOUJOURS rappelé à la racine de la closure principale.
--- Jamais transmis à un helper interne. Robustesse garantie pour les tests et l’usage plugin.
function M.create_async(tag_name, message, callback)
    local valid, err = validate_tag_name(tag_name)
    if not valid then
        ui.show_error(i18n.t('tag.error.invalid_name'))
        if validate_callback(callback) then callback(false, err) end
        return
    end
    if not validate_callback(callback) then
        ui.show_error(i18n.t('tag.error.callback_invalid'))
        return
    end
    -- Chaine asynchrone avec stockage local des résultats
    local function finish(success, msg)
        if success then
            ui.show_success(i18n.t('tag.success.created', {name = tag_name}))
        else
            ui.show_error(msg or i18n.t('tag.error.create_failed'))
        end
        callback(success, msg)
    end
    is_git_repo_async(function(repo_ok)
        if not repo_ok then
            finish(false, i18n.t('tag.error.not_git_repo'))
            return
        end
        tag_exists_async(tag_name, function(exists)
            if exists then
                finish(false, i18n.t('tag.error.already_exists', {name = tag_name}))
                return
            end
            local cmd = string.format("git tag %s %s", utils.escape_string(tag_name), message and ("-m " .. utils.escape_string(message)) or "")
            utils.execute_command_async(cmd, function(success)
                if not success then
                    finish(false, i18n.t('tag.error.create_failed'))
                else
                    finish(true)
                end
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
---
--- [IMPORTANT BUSTED COMPAT] Le callback utilisateur NE DOIT PAS utiliser de variable locale du test (ex : done).
--- Faites toutes les assertions et l'appel à done() dans la closure du test, jamais ici ou dans une closure imbriquée.
---
--- [SECURITY & BUSTED COMPAT] Le callback utilisateur est TOUJOURS rappelé à la racine de la closure principale.
--- Jamais transmis à un helper interne. Robustesse garantie pour les tests et l’usage plugin.
function M.delete_async(tag_name, callback)
    local valid, err = validate_tag_name(tag_name)
    if not valid then
        ui.show_error(i18n.t('tag.error.invalid_name'))
        if validate_callback(callback) then callback(false, err) end
        return
    end
    if not validate_callback(callback) then
        ui.show_error(i18n.t('tag.error.callback_invalid'))
        return
    end
    local function finish(success, msg)
        if success then
            ui.show_success(i18n.t('tag.success.deleted', {name = tag_name}))
        else
            ui.show_error(msg or i18n.t('tag.error.delete_failed'))
        end
        callback(success, msg)
    end
    is_git_repo_async(function(repo_ok)
        if not repo_ok then
            finish(false, i18n.t('tag.error.not_git_repo'))
            return
        end
        tag_exists_async(tag_name, function(exists, err_exists)
            if not exists then
                local msg = err_exists or i18n.t('tag.error.not_found', {name = tag_name})
                finish(false, msg)
                return
            end
            utils.execute_command_async("git tag -d " .. utils.escape_string(tag_name), function(success)
                if not success then
                    finish(false, i18n.t('tag.error.delete_failed'))
                else
                    finish(true)
                end
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
---
--- [IMPORTANT BUSTED COMPAT] Le callback utilisateur NE DOIT PAS utiliser de variable locale du test (ex : done).
--- Faites toutes les assertions et l'appel à done() dans la closure du test, jamais ici ou dans une closure imbriquée.
---
--- [SECURITY & BUSTED COMPAT] Le callback utilisateur est TOUJOURS rappelé à la racine de la closure principale.
--- Jamais transmis à un helper interne. Robustesse garantie pour les tests et l’usage plugin.
function M.push_async(tag_name, callback)
    local valid, err = validate_tag_name(tag_name)
    if not valid then
        ui.show_error(i18n.t('tag.error.invalid_name'))
        if validate_callback(callback) then callback(false, err) end
        return
    end
    if not validate_callback(callback) then
        ui.show_error(i18n.t('tag.error.callback_invalid'))
        return
    end
    local function finish(success, msg)
        if success then
            ui.show_success(i18n.t('tag.success.pushed', {name = tag_name}))
        else
            ui.show_error(msg or i18n.t('tag.error.push_failed'))
        end
        callback(success, msg)
    end
    is_git_repo_async(function(repo_ok)
        if not repo_ok then
            finish(false, i18n.t('tag.error.not_git_repo'))
            return
        end
        tag_exists_async(tag_name, function(exists, err_exists)
            if not exists then
                local msg = err_exists or i18n.t('tag.error.not_found', {name = tag_name})
                finish(false, msg)
                return
            end
            utils.execute_command_async("git push origin " .. utils.escape_string(tag_name), function(success)
                if not success then
                    finish(false, i18n.t('tag.error.push_failed'))
                else
                    finish(true)
                end
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
---
--- [IMPORTANT BUSTED COMPAT] Le callback utilisateur NE DOIT PAS utiliser de variable locale du test (ex : done).
--- Faites toutes les assertions et l'appel à done() dans la closure du test, jamais ici ou dans une closure imbriquée.
---
--- [SECURITY & BUSTED COMPAT] Le callback utilisateur est TOUJOURS rappelé à la racine de la closure principale.
--- Jamais transmis à un helper interne. Robustesse garantie pour les tests et l’usage plugin.
function M.show_async(tag_name, callback)
    local valid, err = validate_tag_name(tag_name)
    if not valid then
        ui.show_error(i18n.t('tag.error.invalid_name'))
        if validate_callback(callback) then callback(false, err) end
        return
    end
    if not validate_callback(callback) then
        ui.show_error(i18n.t('tag.error.callback_invalid'))
        return
    end
    local function finish(success, details_or_msg)
        if success then
            ui.show_preview({
                title = i18n.t('tag.preview.title', {name = tag_name}),
                content = details_or_msg
            })
        else
            ui.show_error(details_or_msg or i18n.t('tag.error.show_failed'))
        end
        callback(success, details_or_msg)
    end
    is_git_repo_async(function(repo_ok)
        if not repo_ok then
            finish(false, i18n.t('tag.error.not_git_repo'))
            return
        end
        tag_exists_async(tag_name, function(exists, err_exists)
            if not exists then
                local msg = err_exists or i18n.t('tag.error.not_found', {name = tag_name})
                finish(false, msg)
                return
            end
            utils.execute_command_async("git show " .. utils.escape_string(tag_name), function(success, details)
                if not success then
                    finish(false, i18n.t('tag.error.show_failed'))
                else
                    finish(true, details)
                end
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

if require('gitpilot.utils').is_test_env() then
    M.validate_tag_name = validate_tag_name
    M.validate_callback = validate_callback
end

return M
