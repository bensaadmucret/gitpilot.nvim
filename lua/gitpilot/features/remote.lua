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

-- Liste des remotes
M.list_remotes = function()
    local remotes = utils.git_command('remote -v')
    if not remotes then return {} end

    local remote_list = {}
    local seen = {}
    for line in remotes:gmatch("[^\r\n]+") do
        local name, url = line:match("([^%s]+)%s+([^%s]+)")
        if name and url and not seen[name] then
            table.insert(remote_list, {name = name, url = url})
            seen[name] = true
        end
    end
    return remote_list
end

-- Ajouter un remote
M.add_remote = function()
    vim.ui.input({prompt = i18n.t("remote.name.prompt")}, function(name)
        if not name or name == "" then return end
        
        vim.ui.input({prompt = i18n.t("remote.url.prompt")}, function(url)
            if not url or url == "" then return end
            
            local result = utils.git_command(string.format('remote add %s %s', name, url))
            if result then
                ui.notify(i18n.t("remote.added"), "info")
            end
        end)
    end)
end

-- Supprimer un remote
M.remove_remote = function()
    local remotes = M.list_remotes()
    if #remotes == 0 then
        ui.notify(i18n.t("remote.none"), "warn")
        return
    end

    local remote_names = {}
    for _, remote in ipairs(remotes) do
        table.insert(remote_names, string.format("%s (%s)", remote.name, remote.url))
    end

    local buf, win = ui.create_floating_window(
        i18n.t("remote.select_delete"),
        remote_names,
        {
            width = 60
        }
    )

    -- Navigation et sélection
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #remote_names then
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

    -- Sélection et suppression
    vim.keymap.set('n', '<CR>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local remote = remotes[cursor[1]]
        
        vim.api.nvim_win_close(win, true)
        
        ui.confirm(i18n.t("remote.confirm_delete") .. " " .. remote.name .. "?", function(confirmed)
            if confirmed then
                local result = utils.git_command('remote remove ' .. remote.name)
                if result then
                    ui.notify(i18n.t("remote.deleted") .. ": " .. remote.name, "info")
                end
            end
        end)
    end, opts)
end

-- Fetch depuis un remote spécifique
M.fetch_remote = function()
    local remotes = M.list_remotes()
    if #remotes == 0 then
        ui.notify(i18n.t("remote.none"), "warn")
        return
    end

    local remote_names = {}
    for _, remote in ipairs(remotes) do
        table.insert(remote_names, remote.name)
    end

    local buf, win = ui.create_floating_window(
        i18n.t("remote.select_fetch"),
        remote_names,
        {
            width = 40
        }
    )

    -- Navigation et sélection
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #remote_names then
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

    -- Sélection et fetch
    vim.keymap.set('n', '<CR>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local remote = remotes[cursor[1]]
        
        vim.api.nvim_win_close(win, true)
        
        local result = utils.git_command('fetch ' .. remote.name)
        if result then
            ui.notify(i18n.t("remote.fetched") .. ": " .. remote.name, "info")
        end
    end, opts)
end

-- Push avec options
M.push_remote = function()
    local remotes = M.list_remotes()
    if #remotes == 0 then
        ui.notify(i18n.t("remote.none"), "warn")
        return
    end

    -- Options de push
    local push_options = {
        {name = "normal", desc = i18n.t("remote.push.normal")},
        {name = "force", desc = i18n.t("remote.push.force")},
        {name = "force-with-lease", desc = i18n.t("remote.push.force_lease")}
    }

    local option_list = {}
    for _, opt in ipairs(push_options) do
        table.insert(option_list, opt.desc)
    end

    local buf, win = ui.create_floating_window(
        i18n.t("remote.push.select_option"),
        option_list,
        {
            width = 60
        }
    )

    -- Navigation et sélection
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #option_list then
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

    -- Sélection de l'option et push
    vim.keymap.set('n', '<CR>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local option = push_options[cursor[1]]
        
        vim.api.nvim_win_close(win, true)
        
        -- Sélection du remote
        local remote_names = {}
        for _, remote in ipairs(remotes) do
            table.insert(remote_names, remote.name)
        end

        local remote_buf, remote_win = ui.create_floating_window(
            i18n.t("remote.select_push"),
            remote_names,
            {
                width = 40
            }
        )

        local remote_opts = {buffer = remote_buf, noremap = true, silent = true}
        
        -- Navigation
        vim.keymap.set('n', 'j', function()
            local cursor = vim.api.nvim_win_get_cursor(remote_win)
            if cursor[1] < #remote_names then
                vim.api.nvim_win_set_cursor(remote_win, {cursor[1] + 1, cursor[2]})
            end
        end, remote_opts)
        
        vim.keymap.set('n', 'k', function()
            local cursor = vim.api.nvim_win_get_cursor(remote_win)
            if cursor[1] > 1 then
                vim.api.nvim_win_set_cursor(remote_win, {cursor[1] - 1, cursor[2]})
            end
        end, remote_opts)

        -- Fermeture
        vim.keymap.set('n', 'q', function()
            vim.api.nvim_win_close(remote_win, true)
        end, remote_opts)
        
        vim.keymap.set('n', '<Esc>', function()
            vim.api.nvim_win_close(remote_win, true)
        end, remote_opts)

        -- Push final
        vim.keymap.set('n', '<CR>', function()
            local remote_cursor = vim.api.nvim_win_get_cursor(remote_win)
            local remote = remotes[remote_cursor[1]]
            
            vim.api.nvim_win_close(remote_win, true)
            
            local push_cmd = 'push'
            if option.name == "force" then
                push_cmd = push_cmd .. ' --force'
            elseif option.name == "force-with-lease" then
                push_cmd = push_cmd .. ' --force-with-lease'
            end
            
            local result = utils.git_command(push_cmd .. ' ' .. remote.name)
            if result then
                ui.notify(i18n.t("remote.pushed") .. ": " .. remote.name, "info")
            end
        end, remote_opts)
    end, opts)
end

return M
