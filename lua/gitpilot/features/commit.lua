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

-- Sélection multiple des fichiers
M.select_files = function()
    local status = utils.git_command('status --porcelain')
    if not status or status == "" then
        ui.notify(i18n.t("commit.files.none"), "warn")
        return {}
    end

    local files = {}
    for line in status:gmatch("[^\r\n]+") do
        local status_code = line:sub(1, 2)
        local file_path = line:sub(4)
        table.insert(files, {
            status = status_code,
            path = file_path,
            selected = false
        })
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

-- Prévisualisation des changements
M.preview_changes = function(files)
    if #files == 0 then return end
    
    local diff = utils.git_command('diff -- ' .. table.concat(files, ' '))
    if not diff then return end
    
    local buf, win = ui.create_floating_window(
        i18n.t("commit.preview"),
        vim.split(diff, "\n"),
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

-- Type de commit avec emojis
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

-- Assistant de commit complet
M.smart_commit = function()
    -- 1. Sélection des fichiers
    local files = M.select_files()
    if #files == 0 then
        ui.notify(i18n.t("commit.files.none"), "warn")
        return
    end

    -- 2. Prévisualisation des changements
    M.preview_changes(files)

    -- 3. Sélection du type de commit
    local commit_type = M.select_commit_type()
    if not commit_type then return end

    -- 4. Saisie du message
    vim.ui.input({
        prompt = i18n.t("commit.message.prompt"),
        default = commit_type.emoji .. " " .. commit_type.type .. ": "
    }, function(message)
        if not message or message == "" then
            ui.notify(i18n.t("commit.message.empty"), "warn")
            return
        end

        -- 5. Création du commit
        local add_command = 'add ' .. table.concat(files, ' ')
        local add_result = utils.git_command(add_command)
        if not add_result then return end

        local commit_command = string.format('commit -m "%s"', message)
        local commit_result = utils.git_command(commit_command)
        
        if commit_result then
            ui.notify(i18n.t("commit.success"), "info")
        end
    end)
end

return M
