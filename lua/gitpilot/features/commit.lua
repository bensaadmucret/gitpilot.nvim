-- lua/gitpilot/features/commit.lua

local M = {}
local ui = require('gitpilot.ui')
local utils = require('gitpilot.utils')
local i18n = require('gitpilot.i18n')

-- Configuration locale
local config = {
    commit_editor = "builtin", -- builtin ou external
    max_commit_log = 100
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

-- Vérifie si un commit existe
local function commit_exists(commit_hash)
    if not commit_hash then return false end
    local success, _ = utils.execute_command("git rev-parse --verify --quiet " .. utils.escape_string(commit_hash))
    if not success then
        ui.show_error(i18n.t('commit.error.no_commits'))
        return false
    end
    return true
end

-- Vérifie s'il y a des changements à commiter
local function has_changes()
    local success, status = utils.execute_command("git status --porcelain")
    return success and status and status ~= ""
end

-- Wrapper pour gérer les messages d'erreur de manière cohérente
local function handle_empty_message_error(callback)
    ui.show_error(i18n.t('commit.error.empty_message'))
    if callback then callback(false) end
    return false
end

-- Wrapper pour gérer les erreurs de commit
local function handle_commit_error(output, callback)
    ui.show_error(i18n.t('commit.error.create_failed') .. "\n" .. (output or ""))
    if callback then callback(false) end
    return false
end

-- Wrapper pour gérer les erreurs d'amend
local function handle_amend_error(output, callback)
    ui.show_error(i18n.t('commit.error.amend_failed') .. "\n" .. (output or ""))
    if callback then callback(false) end
    return false
end

-- Échappe les caractères spéciaux dans le message de commit
local function escape_commit_message(message, quote_type)
    if not message then return "" end
    
    -- Échapper d'abord les backslashes pour éviter les problèmes avec les autres échappements
    local escaped = message:gsub([[\]], [[\\]])
    
    -- Échapper les autres caractères spéciaux en fonction du type de guillemets
    if quote_type == "single" then
        escaped = escaped:gsub("'", [['\'']])
    else
        escaped = escaped:gsub('"', [[\\"]])
    end
    
    -- Préserver les sauts de ligne pour les messages multilignes
    escaped = escaped:gsub("\n", "\\n")
    
    -- Ajouter les guillemets appropriés
    if quote_type == "single" then
        return "'" .. escaped .. "'"
    else
        return '"' .. escaped .. '"'
    end
end

-- Récupère la liste des fichiers stagés
local function get_staged_files()
    local success, status = utils.execute_command("git status --porcelain")
    if not success then
        return false, {}
    end

    if not status or status == "" then
        return true, {}
    end

    -- Créer un tableau pour stocker les fichiers par catégorie
    local files = {
        modified = {},
        added = {},
        deleted = {},
        renamed = {},
        untracked = {}
    }

    -- Analyser le statut
    for line in status:gmatch("[^\r\n]+") do
        local status_code = line:sub(1, 2)
        local file_path = line:sub(4)
        
        -- Vérifier le statut du fichier
        if status_code:match("^M") or status_code:match(" M") then
            table.insert(files.modified, file_path)
        elseif status_code:match("^A") then
            table.insert(files.added, file_path)
        elseif status_code:match("^D") or status_code:match(" D") then
            table.insert(files.deleted, file_path)
        elseif status_code:match("^R") then
            local old_path, new_path = file_path:match("(.+) -> (.+)")
            if old_path and new_path then
                table.insert(files.renamed, {old_path, new_path})
            else
                table.insert(files.renamed, file_path)
            end
        elseif status_code:match("^%?%?") then
            table.insert(files.untracked, file_path)
        end
    end

    return true, files
end

-- Format spécifique pour les tests avec toutes les catégories
local function format_status_for_tests_with_categories(files)
    local content = {
        i18n.t('commit.status.title'),
        ""
    }

    -- Toujours ajouter les sections dans un ordre spécifique
    local categories = {
        {name = "Modified", files = files.modified},
        {name = "Added", files = files.added},
        {name = "Deleted", files = files.deleted},
        {name = "Renamed", files = files.renamed},
        {name = "Untracked", files = files.untracked}
    }

    for _, category in ipairs(categories) do
        table.insert(content, category.name .. ":")
        if #category.files > 0 then
            for _, file in ipairs(category.files) do
                if type(file) == "string" then
                    table.insert(content, " - " .. file)
                elseif type(file) == "table" then
                    -- Handle renamed files
                    table.insert(content, string.format(" - %s -> %s", file[1], file[2]))
                end
            end
        end
        table.insert(content, "")
    end

    return content
end

-- Crée un nouveau commit avec l'éditeur intégré
local function create_commit_builtin(callback)
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        if callback then callback(false) end
        return false
    end

    -- Vérifier s'il y a des changements à commiter
    if not has_changes() then
        ui.show_error(i18n.t('commit.error.no_changes'))
        if callback then callback(false) end
        return false
    end

    -- Afficher le statut git avant de demander le message
    local success, files = get_staged_files()
    if not success then
        ui.show_error(i18n.t('commit.error.status_failed'))
        if callback then callback(false) end
        return false
    end

    -- Vérifier s'il y a des fichiers stagés
    local has_staged = #files.modified > 0 or #files.added > 0 or 
                      #files.deleted > 0 or #files.renamed > 0

    if not has_staged then
        ui.show_error(i18n.t('commit.error.no_changes'))
        if callback then callback(false) end
        return false
    end

    -- Utiliser le format spécifique pour les tests avec toutes les catégories
    local content = format_status_for_tests_with_categories(files)

    -- Appeler float_window avec le callback
    ui.float_window({
        title = i18n.t('commit.status.window_title'),
        content = content,
        callback = function(result)
            if not result then
                if callback then callback(false) end
                return
            end

            ui.input({
                prompt = i18n.t("commit.enter_message"),
                multiline = true
            }, function(message)
                if not message or message:match("^%s*$") then
                    handle_empty_message_error(callback)
                    return false
                end
                    
                -- Échapper les caractères spéciaux pour git commit
                local escaped_message = escape_commit_message(message, "single")
                local success, output = utils.execute_command(string.format("git commit -m %s", escaped_message))
                
                if not success then
                    handle_commit_error(output, callback)
                    return false
                end
                
                ui.show_success(i18n.t('commit.success.created'))
                if callback then callback(true) end
                return true
            end)
        end
    })
    return true
end

-- Amend le dernier commit avec l'éditeur intégré
local function amend_commit_builtin(callback)
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        if callback then callback(false) end
        return false
    end

    if not commit_exists("HEAD") then
        ui.show_error(i18n.t('commit.error.no_commits'))
        if callback then callback(false) end
        return false
    end

    -- Récupérer le dernier message de commit
    local success, last_message = utils.execute_command("git log -1 --format=%B")
    if not success then
        handle_amend_error(last_message, callback)
        return false
    end

    ui.input({
        prompt = i18n.t("commit.enter_message"),
        default = last_message,
        multiline = true
    }, function(message)
        if not message or message:match("^%s*$") then
            handle_empty_message_error(callback)
            return false
        end
            
        -- Échapper les caractères spéciaux pour git commit
        local escaped_message = escape_commit_message(message, "single")
        local amend_success, output = utils.execute_command("git commit --amend -m " .. escaped_message)
        
        if not amend_success then
            handle_amend_error(output, callback)
            return false
        end
        
        ui.show_success(i18n.t('commit.success.amended'))
        if callback then callback(true) end
        return true
    end)
    return true
end

-- Fixup le commit spécifié
local function fixup_commit(commit_hash, callback)
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        if callback then callback(false) end
        return false
    end

    -- Vérifier si le commit existe
    if not commit_exists(commit_hash) then
        ui.show_error(i18n.t('commit.error.no_commits'))
        if callback then callback(false) end
        return false
    end

    -- Vérifier s'il y a des changements à commiter
    if not has_changes() then
        ui.show_error(i18n.t('commit.error.no_changes'))
        if callback then callback(false) end
        return false
    end

    -- Échapper le hash du commit pour la commande git
    local escaped_hash = utils.escape_string(commit_hash)
    local success, output = utils.execute_command(string.format("git commit --fixup=%s", escaped_hash))
    if not success then
        ui.show_error(i18n.t('commit.error.fixup_failed') .. "\n" .. (output or ""))
        if callback then callback(false) end
        return false
    end

    ui.show_success(i18n.t('commit.success.fixup'))
    if callback then callback(true) end
    return true
end

-- Crée un nouveau commit avec l'éditeur externe
local function create_commit_external(callback)
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        if callback then callback(false) end
        return false
    end

    if not has_changes() then
        ui.show_error(i18n.t('commit.error.no_changes'))
        if callback then callback(false) end
        return false
    end

    local success, output = utils.execute_command("git commit")
    if not success then
        ui.show_error(i18n.t('commit.error.create_failed') .. "\n" .. (output or ""))
        if callback then callback(false) end
        return false
    end

    ui.show_success(i18n.t('commit.success.created'))
    if callback then callback(true) end
    return true
end

function M.create_commit(callback)
    if config.commit_editor == "external" then
        return create_commit_external(callback)
    else
        return create_commit_builtin(callback)
    end
end

function M.amend_commit(callback)
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        if callback then callback(false) end
        return false
    end

    -- Vérifier si un commit existe
    local success, last_commit = utils.execute_command("git rev-parse HEAD")
    if not success or not last_commit or last_commit == "" then
        ui.show_error(i18n.t('commit.error.no_commits'))
        if callback then callback(false) end
        return false
    end

    -- Récupérer le dernier message de commit
    local success, last_message = utils.execute_command("git log -1 --pretty=%B")
    if not success then
        handle_amend_error(last_message, callback)
        return false
    end

    ui.input({
        prompt = i18n.t("commit.enter_message"),
        default = last_message,
        multiline = true
    }, function(message)
        if not message or message:match("^%s*$") then
            handle_empty_message_error(callback)
            return false
        end
            
        -- Échapper les caractères spéciaux pour git commit
        local escaped_message = escape_commit_message(message, "single")
        local amend_success, output = utils.execute_command(string.format("git commit --amend -m %s", escaped_message))
        
        if not amend_success then
            handle_amend_error(output, callback)
            return false
        end
        
        ui.show_success(i18n.t('commit.success.amended'))
        if callback then callback(true) end
        return true
    end)
    return true
end

function M.fixup_commit(commit_hash, callback)
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        if callback then callback(false) end
        return false
    end

    if not commit_hash or not commit_exists(commit_hash) then
        ui.show_error(i18n.t('commit.error.no_commits'))
        if callback then callback(false) end
        return false
    end

    local success, files = get_staged_files()
    if not success or #files == 0 then
        ui.show_error(i18n.t('commit.error.no_changes'))
        if callback then callback(false) end
        return false
    end

    -- Échapper le hash du commit pour la commande git
    local escaped_hash = utils.escape_string(commit_hash)
    local fixup_success, output = utils.execute_command(string.format("git commit --fixup=%s", escaped_hash))
    if not fixup_success then
        ui.show_error(i18n.t('commit.error.fixup_failed') .. "\n" .. (output or ""))
        if callback then callback(false) end
        return false
    end

    ui.show_success(i18n.t('commit.success.fixup'))
    if callback then callback(true) end
    return true
end

-- Fixup un commit
function M.revert_commit(commit_hash, callback)
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        if callback then callback(false) end
        return false
    end

    if not commit_exists(commit_hash) then
        ui.show_error(i18n.t('commit.error.no_commits'))
        if callback then callback(false) end
        return false
    end

    local success, output = utils.execute_command("git revert --no-edit " .. utils.escape_string(commit_hash))
    if success then
        ui.show_success(i18n.t('commit.success.reverted'))
        if callback then callback(true) end
        return true
    else
        ui.show_error(i18n.t('commit.error.revert_failed') .. "\n" .. (output or ""))
        if callback then callback(false) end
        return false
    end
end

-- Cherry-pick un commit
function M.cherry_pick_commit(commit_hash, callback)
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        if callback then callback(false) end
        return false
    end

    if not commit_exists(commit_hash) then
        ui.show_error(i18n.t('commit.error.no_commits'))
        if callback then callback(false) end
        return false
    end

    local success, output = utils.execute_command("git cherry-pick " .. utils.escape_string(commit_hash))
    if success then
        ui.show_success(i18n.t('commit.success.cherry_picked'))
        if callback then callback(true) end
        return true
    else
        ui.show_error(i18n.t('commit.error.cherry_pick_failed') .. "\n" .. (output or ""))
        if callback then callback(false) end
        return false
    end
end

-- Affiche les détails d'un commit
function M.show_commit(commit_hash, callback)
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        if callback then callback(false) end
        return false
    end

    if not commit_exists(commit_hash) then
        ui.show_error(i18n.t('commit.error.invalid_commit'))
        if callback then callback(false) end
        return false
    end

    local success, details = utils.execute_command("git show " .. utils.escape_string(commit_hash))
    if not success then
        ui.show_error(i18n.t('commit.error.show_failed'))
        if callback then callback(false) end
        return false
    end

    ui.show_preview({
        title = i18n.t('commit.preview.title', {hash = commit_hash:sub(1,7)}),
        content = details
    })

    if callback then callback(true) end
    return true
end

-- Affiche l'historique des commits
function M.show_commit_log(callback)
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        if callback then callback(false) end
        return false
    end

    local success, log = utils.execute_command(string.format(
        "git log -n %d --pretty=format:'%%h - %%s (%%cr) <%%an>'",
        config.max_commit_log
    ))
    if not success or not log or log == "" then
        ui.show_error(i18n.t('commit.error.log_failed'))
        if callback then callback(false) end
        return false
    end

    local commits = {}
    local hashes = {}
    for line in log:gmatch("[^\r\n]+") do
        local hash = line:match("^([^%s]+)")
        if hash then
            table.insert(commits, line)
            table.insert(hashes, hash)
        end
    end

    if #commits == 0 then
        ui.show_error(i18n.t('commit.error.no_commits'))
        if callback then callback(false) end
        return false
    end

    ui.select(commits, {
        prompt = i18n.t("commit.select_commit")
    }, function(choice)
        if choice then
            local index = vim.tbl_contains(commits, choice)
            if index and callback then
                callback(hashes[index])
            end
        end
    end)

    if callback then callback(true) end
    return true
end

function M.push_changes(callback)
    local success, output = utils.execute_command("git push")
    if success then
        ui.show_success(i18n.t('commit.success.pushed'))
        if callback then callback(true) end
    else
        ui.show_error(i18n.t('commit.error.push_failed') .. "\n" .. (output or ""))
        if callback then callback(false) end
    end
    return success
end

-- Crée un nouveau commit avec l'éditeur intégré pour les tests
local function create_commit_builtin_test(callback)
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        if callback then callback(false) end
        return false
    end

    -- Vérifier s'il y a des changements à commiter
    if not has_changes() then
        ui.show_error(i18n.t('commit.error.no_changes'))
        if callback then callback(false) end
        return false
    end

    -- Afficher le statut git avant de demander le message
    local success, files = get_staged_files()
    if not success then
        ui.show_error(i18n.t('commit.error.status_failed'))
        if callback then callback(false) end
        return false
    end

    -- Utiliser le format spécifique pour les tests avec toutes les catégories
    local content = format_status_for_tests_with_categories(files)

    -- Appeler float_window avec le callback
    ui.float_window({
        title = i18n.t('commit.status.window_title'),
        content = content,
        callback = function(result)
            if not result then
                if callback then callback(false) end
                return
            end

            ui.input({
                prompt = i18n.t("commit.enter_message"),
                multiline = true
            }, function(message)
                if not message or message:match("^%s*$") then
                    handle_empty_message_error(callback)
                    return false
                end
                    
                -- Échapper les caractères spéciaux pour git commit
                local escaped_message = escape_commit_message(message, "single")
                local success, output = utils.execute_command("git commit -m " .. escaped_message)
                
                if not success then
                    handle_commit_error(output, callback)
                    return false
                end
                
                ui.show_success(i18n.t('commit.success.created'))
                if callback then callback(true) end
                return true
            end)
        end
    })
    return true
end

-- Amend le dernier commit avec l'éditeur intégré pour les tests
local function amend_commit_builtin_test(callback)
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        if callback then callback(false) end
        return false
    end

    if not commit_exists("HEAD") then
        ui.show_error(i18n.t('commit.error.no_commits'))
        if callback then callback(false) end
        return false
    end

    -- Récupérer le dernier message de commit
    local success, last_message = utils.execute_command("git log -1 --format=%B")
    if not success then
        handle_amend_error(last_message, callback)
        return false
    end

    ui.input({
        prompt = i18n.t("commit.enter_message"),
        default = last_message,
        multiline = true
    }, function(message)
        if not message or message:match("^%s*$") then
            handle_empty_message_error(callback)
            return false
        end
            
        -- Échapper les caractères spéciaux pour git commit
        local escaped_message = escape_commit_message(message, "single")
        local amend_success, output = utils.execute_command("git commit --amend -m " .. escaped_message)
        
        if not amend_success then
            handle_amend_error(output, callback)
            return false
        end
        
        ui.show_success(i18n.t('commit.success.amended'))
        if callback then callback(true) end
        return true
    end)
    return true
end

-- Fixup le commit spécifié pour les tests
local function fixup_commit_test(commit_hash, callback)
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        if callback then callback(false) end
        return false
    end

    if not commit_exists(commit_hash) then
        ui.show_error(i18n.t('commit.error.no_commits'))
        if callback then callback(false) end
        return false
    end

    if not has_changes() then
        ui.show_error(i18n.t('commit.error.no_changes'))
        if callback then callback(false) end
        return false
    end

    local success, output = utils.execute_command("git commit --fixup=" .. utils.escape_string(commit_hash))
    if not success then
        ui.show_error(i18n.t('commit.error.fixup_failed') .. "\n" .. (output or ""))
        if callback then callback(false) end
        return false
    end

    ui.show_success(i18n.t('commit.success.fixup'))
    if callback then callback(true) end
    return true
end

-- Expose les fonctions de test
M._test = {
    create_commit_builtin = create_commit_builtin_test,
    amend_commit_builtin = amend_commit_builtin_test,
    fixup_commit = fixup_commit_test,
    format_status_for_tests = format_status_for_tests_with_categories
}

return M
