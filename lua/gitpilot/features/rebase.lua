local M = {}
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')
local utils = require('gitpilot.utils')

-- Configuration locale
local config = {}

-- Setup function
M.setup = function(opts)
    config = opts
end

-- Actions de rebase disponibles
local REBASE_ACTIONS = {
    {key = "p", action = "pick", desc = i18n.t("rebase.action.pick")},
    {key = "r", action = "reword", desc = i18n.t("rebase.action.reword")},
    {key = "e", action = "edit", desc = i18n.t("rebase.action.edit")},
    {key = "s", action = "squash", desc = i18n.t("rebase.action.squash")},
    {key = "f", action = "fixup", desc = i18n.t("rebase.action.fixup")},
    {key = "d", action = "drop", desc = i18n.t("rebase.action.drop")}
}

-- Démarrer un rebase interactif
M.start_rebase = function(base_commit)
    if not base_commit then
        ui.notify(i18n.t("rebase.error.no_base"), "error")
        return
    end

    -- Vérifier s'il y a des commits à réorganiser
    local commits = utils.git_command(string.format('log --oneline %s..HEAD', base_commit))
    if not commits or commits == "" then
        ui.notify(i18n.t("rebase.no_commits"), "warn")
        return
    end

    -- Créer une sauvegarde avant le rebase
    local backup_branch = "backup_" .. os.time()
    local backup = utils.git_command('branch ' .. backup_branch)
    if not backup then
        ui.notify(i18n.t("rebase.error.backup_failed"), "error")
        return
    end

    -- Démarrer le rebase
    local success, err = utils.git_command_with_error(string.format('rebase -i %s', base_commit))
    if success then
        ui.notify(i18n.t("rebase.started"), "info")
    else
        ui.notify(i18n.t("rebase.error.start_failed", {error = err}), "error")
        -- Restaurer la sauvegarde en cas d'erreur
        utils.git_command('reset --hard ' .. backup_branch)
        utils.git_command('branch -D ' .. backup_branch)
    end
end

-- Gérer les conflits de rebase
M.handle_conflicts = function()
    local conflicts = utils.git_command('diff --name-only --diff-filter=U')
    if not conflicts or conflicts == "" then
        ui.notify(i18n.t("rebase.conflicts.no_conflicts"), "info")
        return
    end

    local conflict_files = vim.split(conflicts, "\n")
    local buf, win = ui.create_floating_window(
        i18n.t("rebase.conflicts.title"),
        conflict_files,
        {
            width = 80,
            height = 20
        }
    )

    -- Navigation
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('n', 'o', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local file = conflict_files[cursor[1]]
        if file then
            vim.cmd('edit ' .. file)
        end
    end, opts)

    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, true)
    end, opts)

    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
end

-- Continuer le rebase après résolution des conflits
M.continue_rebase = function()
    local success, err = utils.git_command_with_error('rebase --continue')
    if success then
        ui.notify(i18n.t("rebase.conflicts.done"), "info")
    else
        ui.notify(i18n.t("rebase.error.continue_failed", {error = err}), "error")
    end
end

-- Abandonner le rebase
M.abort_rebase = function()
    local success, err = utils.git_command_with_error('rebase --abort')
    if success then
        ui.notify(i18n.t("rebase.aborted"), "info")
    else
        ui.notify(i18n.t("rebase.error.abort_failed", {error = err}), "error")
    end
end

return M
