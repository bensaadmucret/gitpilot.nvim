-- lua/gitpilot/config.lua

local M = {}

-- Configuration par défaut
M.defaults = {
    -- Configuration Git
    git = {
        timeout = 5000,
        command = "git"
    },
    
    -- Configuration des sauvegardes
    backup = {
        enabled = true,
        directory = vim.fn.stdpath('data') .. '/gitpilot/backups',
        max_backups = 10,
        auto_backup = true,
        backup_on_save = true
    },
    
    -- Configuration des patches
    patch = {
        directory = vim.fn.stdpath('data') .. '/gitpilot/patches',
        template_directory = vim.fn.stdpath('data') .. '/gitpilot/templates/patches'
    },
    
    -- Configuration des issues
    issues = {
        template_directory = vim.fn.stdpath('data') .. '/gitpilot/templates/issues',
        cache_directory = vim.fn.stdpath('data') .. '/gitpilot/cache/issues'
    },
    
    -- Configuration UI
    ui = {
        icons = {
            branch = "",
            commit = "",
            conflict = "󰞇",
            modified = "●",
            staged = "✓",
            untracked = "?",
            error = "",
            warning = "",
            info = "",
            success = "",
            loading = ""
        },
        border = "rounded",
        float = {
            width = 0.8,
            height = 0.8
        }
    },
    
    -- Configuration des hooks
    hooks = {
        pre_commit = nil,
        post_commit = nil,
        pre_push = nil,
        post_push = nil
    },
    
    -- Configuration du logging
    log = {
        enabled = true,
        level = "info",
        file = vim.fn.stdpath('data') .. '/gitpilot/gitpilot.log'
    }
}

-- Configuration actuelle
M.current = vim.deepcopy(M.defaults)

-- Met à jour la configuration
function M.setup(opts)
    M.current = vim.tbl_deep_extend("force", M.current, opts or {})
end

-- Récupère une valeur de configuration
function M.get(key)
    if key == nil then
        return M.current
    end
    
    local value = M.current
    for part in string.gmatch(key, "[^.]+") do
        if type(value) ~= "table" then
            return nil
        end
        value = value[part]
    end
    return value
end

-- Définit une valeur de configuration
function M.set(key, value)
    if key == nil then
        return
    end
    
    local current = M.current
    local parts = {}
    for part in string.gmatch(key, "[^.]+") do
        table.insert(parts, part)
    end
    
    for i = 1, #parts - 1 do
        local part = parts[i]
        if type(current[part]) ~= "table" then
            current[part] = {}
        end
        current = current[part]
    end
    
    current[parts[#parts]] = value
end

return M
