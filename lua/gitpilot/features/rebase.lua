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
M.start_interactive_rebase = function()
    -- Obtenir la liste des commits
    local commits = utils.git_command('log --oneline -n 10')
    if not commits or commits == "" then
        ui.notify(i18n.t("rebase.no_commits"), "warn")
        return
    end

    local commit_list = {}
    local commit_data = {}
    for line in commits:gmatch("[^\r\n]+") do
        local hash, message = line:match("(%w+)%s+(.+)")
        if hash then
            table.insert(commit_data, {
                hash = hash,
                message = message,
                action = "pick" -- Action par défaut
            })
            table.insert(commit_list, string.format("pick %s %s", hash, message))
        end
    end

    local buf, win = ui.create_floating_window(
        i18n.t("rebase.title"),
        commit_list,
        {
            width = 100
        }
    )

    -- Afficher les actions disponibles
    local help_text = {}
    for _, action in ipairs(REBASE_ACTIONS) do
        table.insert(help_text, string.format("%s: %s", action.key, action.desc))
    end
    table.insert(help_text, "")
    table.insert(help_text, i18n.t("rebase.help.move"))
    table.insert(help_text, i18n.t("rebase.help.start"))
    table.insert(help_text, i18n.t("rebase.help.cancel"))

    local help_buf, help_win = ui.create_floating_window(
        i18n.t("rebase.help.title"),
        help_text,
        {
            width = 60,
            relative = "editor",
            row = 3,
            col = 120
        }
    )

    -- Navigation
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #commit_list then
            vim.api.nvim_win_set_cursor(win, {cursor[1] + 1, cursor[2]})
        end
    end, opts)
    
    vim.keymap.set('n', 'k', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] > 1 then
            vim.api.nvim_win_set_cursor(win, {cursor[1] - 1, cursor[2]})
        end
    end, opts)

    -- Déplacer les commits
    vim.keymap.set('n', 'J', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #commit_list then
            -- Échanger les lignes
            local temp = commit_list[cursor[1]]
            commit_list[cursor[1]] = commit_list[cursor[1] + 1]
            commit_list[cursor[1] + 1] = temp
            
            -- Échanger les données
            local temp_data = commit_data[cursor[1]]
            commit_data[cursor[1]] = commit_data[cursor[1] + 1]
            commit_data[cursor[1] + 1] = temp_data
            
            -- Mettre à jour l'affichage
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, commit_list)
            vim.api.nvim_win_set_cursor(win, {cursor[1] + 1, cursor[2]})
        end
    end, opts)
    
    vim.keymap.set('n', 'K', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] > 1 then
            -- Échanger les lignes
            local temp = commit_list[cursor[1]]
            commit_list[cursor[1]] = commit_list[cursor[1] - 1]
            commit_list[cursor[1] - 1] = temp
            
            -- Échanger les données
            local temp_data = commit_data[cursor[1]]
            commit_data[cursor[1]] = commit_data[cursor[1] - 1]
            commit_data[cursor[1] - 1] = temp_data
            
            -- Mettre à jour l'affichage
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, commit_list)
            vim.api.nvim_win_set_cursor(win, {cursor[1] - 1, cursor[2]})
        end
    end, opts)

    -- Actions de rebase
    for _, action in ipairs(REBASE_ACTIONS) do
        vim.keymap.set('n', action.key, function()
            local cursor = vim.api.nvim_win_get_cursor(win)
            local commit = commit_data[cursor[1]]
            commit.action = action.action
            commit_list[cursor[1]] = string.format("%s %s %s", action.action, commit.hash, commit.message)
            vim.api.nvim_buf_set_lines(buf, cursor[1]-1, cursor[1], false, {commit_list[cursor[1]]})
        end, opts)
    end

    -- Prévisualisation des changements
    vim.keymap.set('n', 'P', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local commit = commit_data[cursor[1]]
        
        local diff = utils.git_command('show ' .. commit.hash)
        if diff then
            local diff_buf, diff_win = ui.create_floating_window(
                i18n.t("rebase.preview"),
                vim.split(diff, "\n"),
                {
                    width = 100,
                    height = 20
                }
            )

            -- Navigation dans la prévisualisation
            local diff_opts = {buffer = diff_buf, noremap = true, silent = true}
            vim.keymap.set('n', 'q', function()
                vim.api.nvim_win_close(diff_win, true)
            end, diff_opts)
            
            vim.keymap.set('n', '<Esc>', function()
                vim.api.nvim_win_close(diff_win, true)
            end, diff_opts)
        end
    end, opts)

    -- Fermeture et annulation
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_win_close(help_win, true)
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_win_close(help_win, true)
    end, opts)

    -- Démarrer le rebase
    vim.keymap.set('n', '<CR>', function()
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_win_close(help_win, true)
        
        -- Créer le fichier de rebase
        local rebase_content = {}
        for i = #commit_data, 1, -1 do
            local commit = commit_data[i]
            table.insert(rebase_content, string.format("%s %s %s", commit.action, commit.hash, commit.message))
        end
        
        -- Écrire dans un fichier temporaire
        local temp_file = os.tmpname()
        local file = io.open(temp_file, "w")
        if file then
            file:write(table.concat(rebase_content, "\n"))
            file:close()
            
            -- Lancer le rebase
            local oldest_commit = commit_data[#commit_data].hash
            local cmd = string.format('git rebase -i %s --git-editor="cat %s >"', oldest_commit .. "~1", temp_file)
            local result = utils.git_command(cmd)
            
            os.remove(temp_file)
            
            if result then
                ui.notify(i18n.t("rebase.started"), "info")
            end
        end
    end, opts)
end

-- Gérer les conflits de rebase
M.handle_conflicts = function()
    local status = utils.git_command('status')
    if not status or not status:match("rebase in progress") then
        ui.notify(i18n.t("rebase.no_conflicts"), "warn")
        return
    end

    local conflicts = utils.git_command('diff --name-only --diff-filter=U')
    if not conflicts or conflicts == "" then
        ui.notify(i18n.t("rebase.no_conflicts"), "warn")
        return
    end

    local conflict_list = vim.split(conflicts, "\n")
    local buf, win = ui.create_floating_window(
        i18n.t("rebase.conflicts.title"),
        conflict_list,
        {
            width = 80
        }
    )

    -- Navigation
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #conflict_list then
            vim.api.nvim_win_set_cursor(win, {cursor[1] + 1, cursor[2]})
        end
    end, opts)
    
    vim.keymap.set('n', 'k', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] > 1 then
            vim.api.nvim_win_set_cursor(win, {cursor[1] - 1, cursor[2]})
        end
    end, opts)

    -- Fermeture
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
    end, opts)

    -- Ouvrir le fichier en conflit
    vim.keymap.set('n', '<CR>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local file = conflict_list[cursor[1]]
        vim.api.nvim_win_close(win, true)
        vim.cmd('edit ' .. file)
    end, opts)

    -- Actions sur les conflits
    local actions = {
        {key = "o", cmd = "checkout --ours", desc = i18n.t("rebase.conflicts.ours")},
        {key = "t", cmd = "checkout --theirs", desc = i18n.t("rebase.conflicts.theirs")},
        {key = "a", cmd = "add", desc = i18n.t("rebase.conflicts.add")},
        {key = "c", cmd = "rebase --continue", desc = i18n.t("rebase.conflicts.continue")},
        {key = "s", cmd = "rebase --skip", desc = i18n.t("rebase.conflicts.skip")},
        {key = "x", cmd = "rebase --abort", desc = i18n.t("rebase.conflicts.abort")}
    }

    -- Afficher les actions disponibles
    local action_text = {}
    for _, action in ipairs(actions) do
        table.insert(action_text, string.format("%s: %s", action.key, action.desc))
    end

    local action_buf, action_win = ui.create_floating_window(
        i18n.t("rebase.conflicts.actions"),
        action_text,
        {
            width = 40,
            relative = "editor",
            row = 3,
            col = 120
        }
    )

    -- Configurer les actions
    for _, action in ipairs(actions) do
        vim.keymap.set('n', action.key, function()
            local cursor = vim.api.nvim_win_get_cursor(win)
            local file = conflict_list[cursor[1]]
            
            if action.cmd:match("checkout") or action.cmd:match("add") then
                local result = utils.git_command(action.cmd .. ' ' .. file)
                if result then
                    ui.notify(string.format(i18n.t("rebase.conflicts.resolved"), file), "info")
                end
            else
                local result = utils.git_command('rebase ' .. action.cmd:match("rebase%s+(.+)"))
                if result then
                    vim.api.nvim_win_close(win, true)
                    vim.api.nvim_win_close(action_win, true)
                    ui.notify(i18n.t("rebase.conflicts.done"), "info")
                end
            end
        end, opts)
    end
end

return M
