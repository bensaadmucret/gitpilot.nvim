local M = {}
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')
local utils = require('gitpilot.utils')

-- Configuration par défaut
local config = {
    git_cmd = 'git',
    timeout = 5000,
    test_mode = false
}

-- Setup function
M.setup = function(opts)
    config = vim.tbl_deep_extend('force', config, opts or {})
    -- Si nous sommes en mode test, on initialise l'environnement de test
    if config.test_mode then
        utils.setup(config)
    end
end

-- Liste des remotes
M.list_remotes = function()
    local success, output = utils.git_command('remote -v')
    if not success or output == "" then
        return {}
    end

    local remote_list = {}
    local seen = {}
    for line in output:gmatch("[^\r\n]+") do
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
        if not name or name == "" then 
            vim.notify("Remote name cannot be empty", "error")
            return 
        end
        
        vim.ui.input({prompt = i18n.t("remote.url.prompt")}, function(url)
            if not url or url == "" then 
                vim.notify("Remote URL cannot be empty", "error")
                return
            end

            local success, output = utils.git_command(string.format('remote add %s %s', name, url))
            if success then
                vim.notify("Remote " .. name .. " added successfully", "info")
            else
                vim.notify("Failed to add remote: " .. output, "error")
            end
        end)
    end)
end

-- Supprimer un remote
M.remove_remote = function()
    local remotes = M.list_remotes()
    if #remotes == 0 then
        vim.notify(i18n.t("remote.none"), "warn")
        return
    end

    local remote_names = {}
    for _, remote in ipairs(remotes) do
        table.insert(remote_names, remote.name)
    end

    vim.ui.select(remote_names, {
        prompt = i18n.t("remote.select.remove"),
    }, function(name)
        if not name then return end

        local success, output = utils.git_command(string.format('remote remove %s', name))
        if success then
            vim.notify("Remote " .. name .. " removed successfully", "info")
        else
            vim.notify("Failed to remove remote: " .. output, "error")
        end
    end)
end

-- Push vers un remote
M.push_remote = function()
    local remotes = M.list_remotes()
    if #remotes == 0 then
        vim.notify("No remotes found", "warn")
        return
    end

    local remote_names = {}
    for _, remote in ipairs(remotes) do
        table.insert(remote_names, remote.name)
    end

    vim.ui.select(remote_names, {
        prompt = i18n.t("remote.select.push"),
    }, function(name)
        if not name then return end

        local success, output = utils.git_command(string.format('push %s', name))
        if success then
            vim.notify("Successfully pushed to remote " .. name, "info")
        else
            vim.notify("Failed to push to remote: " .. output, "error")
        end
    end)
end

-- Pull depuis un remote
M.pull_remote = function()
    local remotes = M.list_remotes()
    if #remotes == 0 then
        vim.notify("No remotes found", "warn")
        return
    end

    local remote_names = {}
    for _, remote in ipairs(remotes) do
        table.insert(remote_names, remote.name)
    end

    vim.ui.select(remote_names, {
        prompt = i18n.t("remote.select.pull"),
    }, function(name)
        if not name then return end

        local success, output = utils.git_command(string.format('pull %s', name))
        if success then
            vim.notify("Successfully pulled from remote " .. name, "info")
        else
            vim.notify("Failed to pull from remote: " .. output, "error")
        end
    end)
end

return M
