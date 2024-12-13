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
    return success
end

-- Vérifie s'il y a des changements à commiter
local function has_changes()
    local success, status = utils.execute_command("git status --porcelain")
    return success and status and status ~= ""
end

-- Affiche le statut Git détaillé
local function show_git_status(callback)
    local success, status = utils.execute_command("git status -s")
    if not success then
        ui.show_error(i18n.t('commit.error.status_failed'))
        return false
    end

    if not status or status == "" then
        ui.show_error(i18n.t('commit.error.no_changes'))
        return false
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
        
        if status_code:match("^M") or status_code:match("^.M") then
            table.insert(files.modified, file_path)
        elseif status_code:match("^A") then
            table.insert(files.added, file_path)
        elseif status_code:match("^D") or status_code:match("^.D") then
            table.insert(files.deleted, file_path)
        elseif status_code:match("^R") then
            table.insert(files.renamed, file_path)
        elseif status_code:match("^%?%?") then
            table.insert(files.untracked, file_path)
        end
    end

    -- Construire le message de statut ligne par ligne
    local lines = {i18n.t('commit.status.title'), ""}

    local function add_category(category, title)
        if #files[category] > 0 then
            table.insert(lines, title .. ":")
            for _, file in ipairs(files[category]) do
                table.insert(lines, " - " .. file)
            end
            table.insert(lines, "")
        end
    end

    add_category("modified", i18n.t('commit.status.modified'))
    add_category("added", i18n.t('commit.status.added'))
    add_category("deleted", i18n.t('commit.status.deleted'))
    add_category("renamed", i18n.t('commit.status.renamed'))
    add_category("untracked", i18n.t('commit.status.untracked'))

    ui.float_window(lines, {
        title = i18n.t('commit.status.window_title'),
        callback = callback
    })

    return true
end

-- Échapper un message de commit pour git
local function escape_commit_message(message, quote_type)
    if quote_type == "single" then
        return "'" .. message:gsub("'", "'\\''") .. "'"
    else
        return '"' .. message:gsub('"', '\\"'):gsub('`', '\\`') .. '"'
    end
end

-- Pousse les modifications vers le dépôt distant
local function push_changes()
    local success, output = utils.execute_command("git push")
    if success then
        ui.show_success(i18n.t('commit.success.pushed'))
    else
        ui.show_error(i18n.t('commit.error.push_failed') .. (output and ("\n" .. output) or ""))
    end
    return success
end

function M.push_changes()
    local success, output = utils.execute_command("git push")
    if success then
        ui.show_success(i18n.t('commit.success.pushed'))
    else
        ui.show_error(i18n.t('commit.error.push_failed') .. (output and ("\n" .. output) or ""))
    end
    return success
end

-- Crée un nouveau commit avec l'éditeur intégré
local function create_commit_builtin()
    local commit_success = false
    ui.input({
        prompt = i18n.t("commit.enter_message"),
        multiline = true
    }, function(message)
        if message and message ~= "" then
            -- Échapper les caractères spéciaux pour git commit
            local escaped_message = escape_commit_message(message)
            local success, output = utils.execute_command('git commit -m ' .. escaped_message)
            if success then
                ui.show_success(i18n.t('commit.success.created'))
                commit_success = true
                -- Demande à l'utilisateur s'il veut pousser les modifications
                ui.confirm({
                    prompt = i18n.t("commit.push_prompt"),
                    callback = function(confirmed)
                        if confirmed then
                            push_changes()
                        end
                    end
                })
            else
                ui.show_error(i18n.t('commit.error.create_failed') .. (output and ("\n" .. output) or ""))
            end
        else
            ui.show_error(i18n.t('commit.error.empty_message'))
        end
    end)
    return commit_success
end

-- Crée un nouveau commit
function M.create_commit()
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        return false
    end

    -- Vérifie s'il y a des changements à commiter
    if not has_changes() then
        ui.show_error(i18n.t('commit.error.no_changes'))
        return false
    end

    if config.commit_editor == "builtin" then
        -- Affiche d'abord le statut Git, puis crée le commit
        if not show_git_status(function()
            return create_commit_builtin()
        end) then
            ui.show_error(i18n.t('commit.error.status_failed'))
            return false
        end
    else
        -- Utilise l'éditeur externe
        local success, output = utils.execute_command("git commit")
        if not success then
            ui.show_error(i18n.t('commit.error.create_failed') .. (output and ("\n" .. output) or ""))
            return false
        else
            ui.show_success(i18n.t('commit.success.created'))
        end
    end

    return true
end

-- Modifie le dernier commit
function M.amend_commit()
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        return false
    end

    -- Vérifie si un commit existe
    local success, _ = utils.execute_command("git rev-parse HEAD")
    if not success then
        ui.show_error(i18n.t('commit.error.no_commits'))
        return false
    end

    if config.commit_editor == "builtin" then
        -- Récupère le message du dernier commit
        local success, last_message = utils.execute_command("git log -1 --pretty=%B")
        if not success then
            ui.show_error(i18n.t('commit.error.amend_failed'))
            return false
        end

        local amend_success = false
        -- Utilise l'éditeur intégré
        ui.input({
            prompt = i18n.t("commit.enter_amend_message"),
            multiline = true,
            default = last_message
        }, function(message)
            if message and message ~= "" then
                -- Échapper les caractères spéciaux pour git commit
                local escaped_message = escape_commit_message(message, "single")
                local success, output = utils.execute_command("git commit --amend -m " .. escaped_message)
                if success then
                    ui.show_success(i18n.t('commit.success.amended'))
                    amend_success = true
                    -- Demande à l'utilisateur s'il veut pousser les modifications
                    ui.confirm({
                        prompt = i18n.t("commit.push_prompt"),
                        callback = function(confirmed)
                            if confirmed then
                                push_changes()
                            end
                        end
                    })
                else
                    ui.show_error(i18n.t('commit.error.amend_failed') .. (output and ("\n" .. output) or ""))
                end
            else
                ui.show_error(i18n.t('commit.error.empty_message'))
            end
        end)
        return amend_success
    else
        -- Utilise l'éditeur externe
        local success, output = utils.execute_command("git commit --amend")
        if not success then
            ui.show_error(i18n.t('commit.error.amend_failed') .. (output and ("\n" .. output) or ""))
            return false
        end
        ui.show_success(i18n.t('commit.success.amended'))
        -- Demande à l'utilisateur s'il veut pousser les modifications
        ui.confirm({
            prompt = i18n.t("commit.push_prompt"),
            callback = function(confirmed)
                if confirmed then
                    push_changes()
                end
            end
        })
        return true
    end
end

-- Fixup un commit
function M.fixup_commit(commit_hash)
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        return false
    end

    if not commit_exists(commit_hash) then
        ui.show_error(i18n.t('commit.error.invalid_commit'))
        return false
    end

    -- Vérifie s'il y a des changements à commiter
    if not has_changes() then
        ui.show_error(i18n.t('commit.error.no_changes'))
        return false
    end

    local success, output = utils.execute_command("git commit --fixup=" .. utils.escape_string(commit_hash))
    if success then
        ui.show_success(i18n.t('commit.success.fixup'))
    else
        ui.show_error(i18n.t('commit.error.fixup_failed') .. (output and ("\n" .. output) or ""))
    end

    return success
end

-- Revert un commit
function M.revert_commit(commit_hash)
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        return false
    end

    if not commit_exists(commit_hash) then
        ui.show_error(i18n.t('commit.error.invalid_commit'))
        return false
    end

    local success, output = utils.execute_command("git revert --no-edit " .. utils.escape_string(commit_hash))
    if success then
        ui.show_success(i18n.t('commit.success.reverted'))
    else
        ui.show_error(i18n.t('commit.error.revert_failed') .. (output and ("\n" .. output) or ""))
    end

    return success
end

-- Cherry-pick un commit
function M.cherry_pick_commit(commit_hash)
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        return false
    end

    if not commit_exists(commit_hash) then
        ui.show_error(i18n.t('commit.error.invalid_commit'))
        return false
    end

    local success, output = utils.execute_command("git cherry-pick " .. utils.escape_string(commit_hash))
    if success then
        ui.show_success(i18n.t('commit.success.cherry_picked'))
    else
        ui.show_error(i18n.t('commit.error.cherry_pick_failed') .. (output and ("\n" .. output) or ""))
    end

    return success
end

-- Affiche les détails d'un commit
function M.show_commit(commit_hash)
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        return false
    end

    if not commit_exists(commit_hash) then
        ui.show_error(i18n.t('commit.error.invalid_commit'))
        return false
    end

    local success, details = utils.execute_command("git show " .. utils.escape_string(commit_hash))
    if not success then
        ui.show_error(i18n.t('commit.error.show_failed'))
        return false
    end

    ui.show_preview({
        title = i18n.t('commit.preview.title', {hash = commit_hash:sub(1,7)}),
        content = details
    })

    return true
end

-- Affiche l'historique des commits
function M.show_commit_log(callback)
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        return false
    end

    local success, log = utils.execute_command(string.format(
        "git log -n %d --pretty=format:'%%h - %%s (%%cr) <%%an>'",
        config.max_commit_log
    ))
    if not success or not log or log == "" then
        ui.show_error(i18n.t('commit.error.log_failed'))
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

    return true
end

return M
