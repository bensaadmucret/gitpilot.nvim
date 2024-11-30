local M = {}
local utils = require('gitpilot.utils')
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')

---Liste tous les tags disponibles
---@return table Liste des tags avec {name, hash, message}
M.list_tags = function()
    local success, output = pcall(utils.git_command, 'tag --format="%(refname:short)|%(objectname:short)|%(subject)"')
    if not success then
        vim.notify("tags.error.list", vim.log.levels.ERROR)
        return {}
    end

    if not output or output == "" then
        return {}
    end

    local tags = {}
    for line in output:gmatch("[^\r\n]+") do
        local name, hash, message = line:match("([^|]+)|([^|]+)|(.+)")
        if name and hash then
            table.insert(tags, {
                name = name,
                hash = hash,
                message = message or ""
            })
        end
    end
    return tags
end

---Crée un nouveau tag
---@param name string Nom du tag
---@param message string Message associé au tag
---@return boolean true si le tag est créé, false sinon
M.create_tag = function(name, message)
    if not name or name == "" then
        vim.notify("tags.create.invalid_name", vim.log.levels.WARN)
        return false
    end

    local cmd = message and message ~= ""
        and string.format('tag -a %s -m "%s"', name, message)
        or string.format('tag %s', name)

    local success = pcall(utils.git_command, cmd)
    if not success then
        vim.notify("tags.error.create", vim.log.levels.ERROR)
        return false
    end

    vim.notify("tags.created", vim.log.levels.INFO)
    return true
end

---Pousse un tag vers le remote
---@param tag_name string Nom du tag à pousser
---@return boolean true si le tag est poussé, false sinon
M.push_tag = function(tag_name)
    if not tag_name or tag_name == "" then
        vim.notify("tags.push.invalid_name", vim.log.levels.WARN)
        return false
    end

    local success = pcall(utils.git_command, 'push origin ' .. tag_name)
    if not success then
        vim.notify("tags.error.push", vim.log.levels.ERROR)
        return false
    end

    vim.notify("tags.pushed", vim.log.levels.INFO)
    return true
end

---Supprime un tag local
---@param tag_name string Nom du tag à supprimer
---@return boolean true si le tag est supprimé, false sinon
M.delete_tag = function(tag_name)
    if not tag_name or tag_name == "" then
        vim.notify("tags.delete.invalid_name", vim.log.levels.WARN)
        return false
    end

    local success = pcall(utils.git_command, 'tag -d ' .. tag_name)
    if not success then
        vim.notify("tags.error.delete", vim.log.levels.ERROR)
        return false
    end

    vim.notify("tags.deleted", vim.log.levels.INFO)
    return true
end

---Supprime un tag distant
---@param tag_name string Nom du tag à supprimer du remote
---@return boolean true si le tag distant est supprimé, false sinon
M.delete_remote_tag = function(tag_name)
    if not tag_name or tag_name == "" then
        vim.notify("tags.delete_remote.invalid_name", vim.log.levels.WARN)
        return false
    end

    local success = pcall(utils.git_command, 'push origin :refs/tags/' .. tag_name)
    if not success then
        vim.notify("tags.error.delete_remote", vim.log.levels.ERROR)
        return false
    end

    vim.notify("tags.deleted_remote", vim.log.levels.INFO)
    return true
end

---Afficher les détails d'un tag
---@param tag_name string Nom du tag
M.show_tag_details = function(tag_name)
    -- Récupérer les détails du tag
    local details = {}
    
    -- Message et auteur du tag
    local tag_info = utils.git_command('tag -n99 ' .. tag_name)
    if tag_info then
        table.insert(details, i18n.t("tag.message") .. ":")
        table.insert(details, tag_info)
        table.insert(details, "")
    end
    
    -- Commit associé
    local commit_info = utils.git_command('show ' .. tag_name)
    if commit_info then
        table.insert(details, i18n.t("tag.commit_info") .. ":")
        for line in commit_info:gmatch("[^\r\n]+") do
            table.insert(details, "  " .. line)
        end
    end

    local buf, win = ui.create_floating_window(
        i18n.t("tag.details_title") .. ": " .. tag_name,
        details,
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

return M
