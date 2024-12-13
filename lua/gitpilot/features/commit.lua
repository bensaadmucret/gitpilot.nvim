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

-- Affiche le statut Git détaillé
local function show_git_status(callback)
    local success, status = utils.execute_command("git status -s")
    if not success then
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

    -- Construire le message de statut
    local status_msg = i18n.t('commit.status.title') .. "\n\n"

    if #files.modified > 0 then
        status_msg = status_msg .. i18n.t('commit.status.modified') .. ":\n - " .. table.concat(files.modified, "\n - ") .. "\n\n"
    end
    if #files.added > 0 then
        status_msg = status_msg .. i18n.t('commit.status.added') .. ":\n - " .. table.concat(files.added, "\n - ") .. "\n\n"
    end
    if #files.deleted > 0 then
        status_msg = status_msg .. i18n.t('commit.status.deleted') .. ":\n - " .. table.concat(files.deleted, "\n - ") .. "\n\n"
    end
    if #files.renamed > 0 then
        status_msg = status_msg .. i18n.t('commit.status.renamed') .. ":\n - " .. table.concat(files.renamed, "\n - ") .. "\n\n"
    end
    if #files.untracked > 0 then
        status_msg = status_msg .. i18n.t('commit.status.untracked') .. ":\n - " .. table.concat(files.untracked, "\n - ") .. "\n\n"
    end

    ui.float_window({ status_msg }, {
        title = i18n.t('commit.status.window_title'),
        callback = callback
    })

    return true
end

-- Crée un nouveau commit avec l'éditeur intégré
local function create_commit_builtin()
    ui.input({
        prompt = i18n.t("commit.enter_message"),
        multiline = true
    }, function(message)
        if message and message ~= "" then
            -- Échapper les caractères spéciaux et entourer le message de guillemets simples
            local escaped_message = "'" .. message:gsub("'", "'\\''") .. "'"
            local success, _ = utils.execute_command("git commit -m " .. escaped_message)
            if success then
                ui.show_success(i18n.t('commit.success.created'))
            else
                ui.show_error(i18n.t('commit.error.create_failed'))
            end
        end
    end)
end

-- Crée un nouveau commit
function M.create_commit()
    if not is_git_repo() then
        ui.show_error(i18n.t('commit.error.not_git_repo'))
        return false
    end

    -- Vérifie s'il y a des changements à commiter
    local success, status = utils.execute_command("git status --porcelain")
    if not success or status == "" then
        ui.show_error(i18n.t('commit.error.no_changes'))
        return false
    end

    if config.commit_editor == "builtin" then
        -- Affiche d'abord le statut Git, puis crée le commit
        show_git_status(create_commit_builtin)
    else
        -- Utilise l'éditeur externe
        local success, _ = utils.execute_command("git commit")
        if not success then
            ui.show_error(i18n.t('commit.error.create_failed'))
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

        -- Utilise l'éditeur intégré
        ui.input({
            prompt = i18n.t("commit.enter_amend_message"),
            multiline = true,
            default = last_message
        }, function(message)
            if message and message ~= "" then
                -- Échapper les caractères spéciaux et entourer le message de guillemets simples
                local escaped_message = "'" .. message:gsub("'", "'\\''") .. "'"
                local success, _ = utils.execute_command("git commit --amend -m " .. escaped_message)
                if success then
                    ui.show_success(i18n.t('commit.success.amended'))
                else
                    ui.show_error(i18n.t('commit.error.amend_failed'))
                end
            end
        end)
    else
        -- Utilise l'éditeur externe
        local success, _ = utils.execute_command("git commit --amend")
        if not success then
            ui.show_error(i18n.t('commit.error.amend_failed'))
            return false
        end
    end

    return true
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
    local success, status = utils.execute_command("git status --porcelain")
    if not success or status == "" then
        ui.show_error(i18n.t('commit.error.no_changes'))
        return false
    end

    local success, _ = utils.execute_command("git commit --fixup=" .. utils.escape_string(commit_hash))
    if not success then
        ui.show_error(i18n.t('commit.error.fixup_failed'))
        return false
    end

    ui.show_success(i18n.t('commit.success.fixup'))
    return true
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

    local success, _ = utils.execute_command("git revert --no-edit " .. utils.escape_string(commit_hash))
    if not success then
        ui.show_error(i18n.t('commit.error.revert_failed'))
        return false
    end

    ui.show_success(i18n.t('commit.success.reverted'))
    return true
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

    local success, _ = utils.execute_command("git cherry-pick " .. utils.escape_string(commit_hash))
    if not success then
        ui.show_error(i18n.t('commit.error.cherry_pick_failed'))
        return false
    end

    ui.show_success(i18n.t('commit.success.cherry_picked'))
    return true
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
    if not success then
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
