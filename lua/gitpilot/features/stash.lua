local M = {}
local utils = require('gitpilot.utils')

---Liste tous les stashs disponibles
---@return table Liste des stashs avec {ref, hash, message}
M.list_stash = function()
    local success, output = pcall(utils.git_command, 'stash list --format="%gd|%h|%s"')
    if not success then
        vim.notify("stash.error.list", vim.log.levels.ERROR)
        return {}
    end

    if not output or output == "" then
        return {}
    end

    local stash_list = {}
    for line in output:gmatch("[^\r\n]+") do
        local ref, hash, message = line:match("([^|]+)|([^|]+)|(.+)")
        if ref and hash then
            table.insert(stash_list, {
                ref = ref,
                hash = hash,
                message = message or ""
            })
        end
    end
    return stash_list
end

---Crée un nouveau stash avec les modifications actuelles
---@return boolean true si le stash est créé, false sinon
M.create_stash = function()
    local success, output = pcall(utils.git_command, 'status --porcelain')
    if not success then
        vim.notify("stash.error.create", vim.log.levels.ERROR)
        return false
    end

    if not output or output == "" then
        vim.notify("stash.no_changes", vim.log.levels.WARN)
        return false
    end

    success = pcall(utils.git_command, 'stash push')
    if not success then
        vim.notify("stash.error.create", vim.log.levels.ERROR)
        return false
    end

    vim.notify("stash.created", vim.log.levels.INFO)
    return true
end

---Applique le dernier stash
---@return boolean true si le stash est appliqué, false sinon
M.apply_stash = function()
    local success, output = pcall(utils.git_command, 'stash list')
    if not success then
        vim.notify("stash.error.apply", vim.log.levels.ERROR)
        return false
    end

    if not output or output == "" then
        vim.notify("stash.none", vim.log.levels.WARN)
        return false
    end

    success = pcall(utils.git_command, 'stash apply')
    if not success then
        vim.notify("stash.error.apply", vim.log.levels.ERROR)
        return false
    end

    vim.notify("stash.applied", vim.log.levels.INFO)
    return true
end

---Affiche le contenu d'un stash spécifique
---@param stash_ref string Référence du stash (ex: stash@{0})
---@return boolean true si le contenu est affiché, false sinon
M.show_stash_content = function(stash_ref)
    if not stash_ref or stash_ref == "" then
        vim.notify("stash.show.invalid", vim.log.levels.WARN)
        return false
    end

    local success, content = pcall(utils.git_command, 'stash show -p ' .. stash_ref)
    if not success then
        vim.notify("stash.error.show", vim.log.levels.ERROR)
        return false
    end

    -- TODO: Implémenter l'affichage du contenu dans une fenêtre flottante
    return true
end

---Supprime le dernier stash
---@return boolean true si le stash est supprimé, false sinon
M.delete_stash = function()
    local success, output = pcall(utils.git_command, 'stash list')
    if not success then
        vim.notify("stash.error.delete", vim.log.levels.ERROR)
        return false
    end

    if not output or output == "" then
        vim.notify("stash.none", vim.log.levels.WARN)
        return false
    end

    success = pcall(utils.git_command, 'stash drop')
    if not success then
        vim.notify("stash.error.delete", vim.log.levels.ERROR)
        return false
    end

    vim.notify("stash.deleted", vim.log.levels.INFO)
    return true
end

return M
