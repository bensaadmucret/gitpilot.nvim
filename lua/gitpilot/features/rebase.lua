-- lua/gitpilot/features/rebase.lua

local M = {}
local ui = require('gitpilot.ui')
local utils = require('gitpilot.utils')
local i18n = require('gitpilot.i18n')

-- Configuration locale
local config = {
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

-- Vérifie si un rebase est en cours
local function is_rebasing()
    local success, _ = utils.execute_command("git rev-parse --git-dir")
    if not success then return false end

    local success, _ = utils.execute_command("test -d .git/rebase-merge -o -d .git/rebase-apply")
    return success
end

-- Démarre un rebase
function M.start()
    if not is_git_repo() then
        ui.show_error(i18n.t('rebase.error.not_git_repo'))
        return false
    end

    if is_rebasing() then
        ui.show_error(i18n.t('rebase.error.already_rebasing'))
        return false
    end

    -- Vérifie s'il y a des changements non commités
    local success, status = utils.execute_command("git status --porcelain")
    if success and status ~= "" then
        ui.show_warning(i18n.t('rebase.warning.uncommitted_changes'))
        return false
    end

    -- Récupère la liste des commits pour le rebase
    local success, log = utils.execute_command(string.format(
        "git log -n %d --pretty=format:'%%h - %%s (%%cr) <%%an>'",
        config.max_commit_log
    ))
    if not success then
        ui.show_error(i18n.t('rebase.error.log_failed'))
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
        ui.show_error(i18n.t('rebase.error.no_commits'))
        return false
    end

    ui.select(commits, {
        prompt = i18n.t("rebase.select_commit")
    }, function(choice)
        if choice then
            local index = vim.tbl_contains(commits, choice)
            if index then
                local hash = hashes[index]
                local success, _ = utils.execute_command("git rebase -i " .. utils.escape_string(hash) .. "~1")
                if not success then
                    ui.show_error(i18n.t('rebase.error.start_failed'))
                else
                    ui.show_success(i18n.t('rebase.success.started'))
                end
            end
        end
    end)

    return true
end

-- Continue un rebase
function M.continue()
    if not is_git_repo() then
        ui.show_error(i18n.t('rebase.error.not_git_repo'))
        return false
    end

    if not is_rebasing() then
        ui.show_error(i18n.t('rebase.error.not_rebasing'))
        return false
    end

    local success, _ = utils.execute_command("git rebase --continue")
    if not success then
        ui.show_error(i18n.t('rebase.error.continue_failed'))
        return false
    end

    ui.show_success(i18n.t('rebase.success.continued'))
    return true
end

-- Skip un commit pendant un rebase
function M.skip()
    if not is_git_repo() then
        ui.show_error(i18n.t('rebase.error.not_git_repo'))
        return false
    end

    if not is_rebasing() then
        ui.show_error(i18n.t('rebase.error.not_rebasing'))
        return false
    end

    local success, _ = utils.execute_command("git rebase --skip")
    if not success then
        ui.show_error(i18n.t('rebase.error.skip_failed'))
        return false
    end

    ui.show_success(i18n.t('rebase.success.skipped'))
    return true
end

-- Annule un rebase
function M.abort()
    if not is_git_repo() then
        ui.show_error(i18n.t('rebase.error.not_git_repo'))
        return false
    end

    if not is_rebasing() then
        ui.show_error(i18n.t('rebase.error.not_rebasing'))
        return false
    end

    local success, _ = utils.execute_command("git rebase --abort")
    if not success then
        ui.show_error(i18n.t('rebase.error.abort_failed'))
        return false
    end

    ui.show_success(i18n.t('rebase.success.aborted'))
    return true
end

-- Démarre un rebase interactif
function M.interactive()
    if not is_git_repo() then
        ui.show_error(i18n.t('rebase.error.not_git_repo'))
        return false
    end

    if is_rebasing() then
        ui.show_error(i18n.t('rebase.error.already_rebasing'))
        return false
    end

    -- Vérifie s'il y a des changements non commités
    local success, status = utils.execute_command("git status --porcelain")
    if success and status ~= "" then
        ui.show_warning(i18n.t('rebase.warning.uncommitted_changes'))
        return false
    end

    -- Récupère la liste des commits pour le rebase
    local success, log = utils.execute_command(string.format(
        "git log -n %d --pretty=format:'%%h - %%s (%%cr) <%%an>'",
        config.max_commit_log
    ))
    if not success then
        ui.show_error(i18n.t('rebase.error.log_failed'))
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
        ui.show_error(i18n.t('rebase.error.no_commits'))
        return false
    end

    ui.select(commits, {
        prompt = i18n.t("rebase.select_commit")
    }, function(choice)
        if choice then
            local index = vim.tbl_contains(commits, choice)
            if index then
                local hash = hashes[index]
                local success, _ = utils.execute_command("git rebase -i " .. utils.escape_string(hash) .. "~1")
                if not success then
                    ui.show_error(i18n.t('rebase.error.interactive_failed'))
                else
                    ui.show_success(i18n.t('rebase.success.interactive_started'))
                end
            end
        end
    end)

    return true
end

return M
