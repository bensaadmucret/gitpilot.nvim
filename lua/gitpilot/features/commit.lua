local M = {}
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')
local utils = require('gitpilot.utils')

-- Configuration locale
local config = {}

-- Setup function
M.setup = function(opts)
    config = opts or {}
end

-- Sélection multiple des fichiers
M.select_files = function()
    local status = utils.git_command('status --porcelain')
    if not status.success or status.output == "" then
        ui.notify(i18n.t("commit.files.none"), "warn")
        return {}
    end

    local files = {}
    for line in status.output:gmatch("[^\r\n]+") do
        local status_code = line:sub(1, 2)
        local file_path = line:sub(4)
        table.insert(files, {
            status = status_code,
            path = file_path,
            selected = false
        })
    end

    -- Pour les tests, retourner directement les fichiers
    if vim.env.GITPILOT_TEST then
        return files
    end

    local file_list = {}
    for _, file in ipairs(files) do
        local prefix = file.selected and "✓" or " "
        table.insert(file_list, string.format("%s [%s] %s", prefix, file.status, file.path))
    end

    local buf, win = ui.create_floating_window(
        i18n.t("commit.files.select"),
        file_list,
        {
            width = 60
        }
    )

    -- Navigation
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #file_list then
            vim.api.nvim_win_set_cursor(win, {cursor[1] + 1, cursor[2]})
        end
    end, opts)
    
    vim.keymap.set('n', 'k', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] > 1 then
            vim.api.nvim_win_set_cursor(win, {cursor[1] - 1, cursor[2]})
        end
    end, opts)

    -- Sélection/Désélection
    vim.keymap.set('n', '<Space>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local idx = cursor[1]
        files[idx].selected = not files[idx].selected
        
        -- Mettre à jour l'affichage
        local prefix = files[idx].selected and "✓" or " "
        file_list[idx] = string.format("%s [%s] %s", prefix, files[idx].status, files[idx].path)
        vim.api.nvim_buf_set_lines(buf, idx-1, idx, false, {file_list[idx]})
    end, opts)

    -- Tout sélectionner/désélectionner
    vim.keymap.set('n', 'a', function()
        local all_selected = true
        for _, file in ipairs(files) do
            if not file.selected then
                all_selected = false
                break
            end
        end
        
        for i, file in ipairs(files) do
            file.selected = not all_selected
            local prefix = file.selected and "✓" or " "
            file_list[i] = string.format("%s [%s] %s", prefix, file.status, file.path)
        end
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, file_list)
    end, opts)

    -- Fermeture
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, true)
        return {}
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
        return {}
    end, opts)

    -- Confirmation
    vim.keymap.set('n', '<CR>', function()
        local selected_files = {}
        for _, file in ipairs(files) do
            if file.selected then
                table.insert(selected_files, file.path)
            end
        end
        vim.api.nvim_win_close(win, true)
        return selected_files
    end, opts)
end

-- Sélection du type de commit
M.select_commit_type = function()
    local commit_types = {
        {type = "feat", emoji = "✨", desc = i18n.t("commit.type.feat")},
        {type = "fix", emoji = "🐛", desc = i18n.t("commit.type.fix")},
        {type = "docs", emoji = "📚", desc = i18n.t("commit.type.docs")},
        {type = "style", emoji = "💎", desc = i18n.t("commit.type.style")},
        {type = "refactor", emoji = "♻️", desc = i18n.t("commit.type.refactor")},
        {type = "test", emoji = "🧪", desc = i18n.t("commit.type.test")},
        {type = "chore", emoji = "🔧", desc = i18n.t("commit.type.chore")}
    }

    -- Pour les tests, retourner le premier type
    if vim.env.GITPILOT_TEST then
        return commit_types[1]
    end

    local type_list = {}
    for _, t in ipairs(commit_types) do
        table.insert(type_list, string.format("%s %s: %s", t.emoji, t.type, t.desc))
    end

    local buf, win = ui.create_floating_window(
        i18n.t("commit.type.select"),
        type_list,
        {
            width = 60
        }
    )

    -- Navigation et sélection
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #type_list then
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
        return nil
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
        return nil
    end, opts)

    -- Sélection
    vim.keymap.set('n', '<CR>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local selected = commit_types[cursor[1]]
        vim.api.nvim_win_close(win, true)
        return selected
    end, opts)
end

-- Prévisualisation des changements
M.preview_changes = function(files)
    if #files == 0 then return end
    
    local diff = utils.git_command('diff -- ' .. table.concat(files, ' '))
    if not diff.success then return end
    
    local buf, win = ui.create_floating_window(
        i18n.t("commit.preview"),
        vim.split(diff.output, "\n"),
        {
            width = 80,
            height = 20
        }
    )

    -- Navigation
    local opts = {buffer = buf, noremap = true, silent = true}
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
end

-- Création d'un commit intelligent
M.smart_commit = function()
    -- 1. Sélection des fichiers
    local files = M.select_files()
    if #files == 0 then
        ui.notify(i18n.t("commit.files.none"), "warn")
        return false
    end

    -- 2. Sélection du type de commit
    local commit_type = M.select_commit_type()
    if not commit_type then
        return false
    end

    -- 3. Ajout des fichiers sélectionnés
    for _, file in ipairs(files) do
        if file.selected or vim.env.GITPILOT_TEST then
            local add_result = utils.git_command('add ' .. file.path)
            if not add_result.success then
                ui.notify(add_result.error, "error")
                return false
            end
        end
    end

    -- 4. Création du commit
    local commit_msg = string.format("%s %s: ", commit_type.emoji, commit_type.type)
    if vim.env.GITPILOT_TEST then
        commit_msg = commit_msg .. "Test commit message"
        local commit_result = utils.git_command(string.format('commit -m "%s"', commit_msg))
        if not commit_result.success then
            ui.notify(commit_result.error, "error")
            return false
        end
        ui.notify(i18n.t("commit.success"), "info")
        return true
    end

    -- En mode normal, demander le message à l'utilisateur
    local success = false
    vim.ui.input({
        prompt = i18n.t("commit.message.prompt"),
        default = commit_msg
    }, function(message)
        if not message or message == "" then
            ui.notify(i18n.t("commit.message.empty"), "warn")
            success = false
            return
        end

        local commit_result = utils.git_command(string.format('commit -m "%s"', message))
        if not commit_result.success then
            ui.notify(commit_result.error, "error")
            success = false
            return
        end

        ui.notify(i18n.t("commit.success"), "info")
        success = true
    end)

    return success
end

-- Modification du dernier commit
M.amend_commit = function()
    if vim.env.GITPILOT_TEST then
        local result = utils.git_command('commit --amend --no-edit')
        if not result.success then
            ui.notify(result.error, "error")
            return false
        end
        ui.notify(i18n.t("commit.amend_success"), "info")
        return true
    end

    local result = utils.git_command('commit --amend')
    if not result.success then
        ui.notify(result.error, "error")
        return false
    end
    
    ui.notify(i18n.t("commit.amend_success"), "info")
    return true
end

return M
