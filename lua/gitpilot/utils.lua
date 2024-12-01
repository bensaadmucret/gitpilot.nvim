-- lua/gitpilot/utils.lua

local M = {}
local vim = vim

-- Configuration par défaut
local config = {
    git = {
        cmd = "git",
        timeout = 5000
    }
}

-- Fonction pour mettre à jour la configuration
function M.setup(opts)
    if opts and opts.git then
        config.git = vim.tbl_deep_extend("force", config.git, opts.git)
    end
end

-- Exécute une commande Git et retourne la sortie
-- @param command string: La commande à exécuter
-- @return string|nil: La sortie de la commande ou nil en cas d'erreur
function M.execute_command(command)
    if not command or command == "" then
        return nil
    end

    local stdout = vim.fn.system(command)
    local success = vim.v.shell_error == 0
    
    if not success then
        vim.api.nvim_err_writeln(string.format("GitPilot error executing: %s\nOutput: %s", command, stdout))
        return nil
    end
    
    return stdout
end

-- Vérifie si Git est disponible sur le système
-- @return boolean: true si Git est installé, false sinon
function M.check_git()
    local handle = io.popen("git --version")
    if not handle then
        return false
    end
    
    local result = handle:read("*a")
    handle:close()
    
    return result and result:match("git version") ~= nil
end

-- Vérifie si le chemin actuel est dans un dépôt Git
-- @return boolean: true si dans un dépôt Git, false sinon
function M.is_git_repo()
    local result = M.execute_command("git rev-parse --is-inside-work-tree 2>/dev/null")
    return result ~= nil
end

-- Obtient le répertoire racine du dépôt Git
-- @return string|nil: Chemin du répertoire racine ou nil si pas dans un dépôt Git
function M.get_git_root()
    if not M.is_git_repo() then
        return nil
    end
    
    local result = M.execute_command("git rev-parse --show-toplevel")
    return result and result:gsub("%s+$", "")
end

-- Échappe les caractères spéciaux dans une chaîne
-- @param str string: La chaîne à échapper
-- @return string: La chaîne échappée
function M.escape_string(str)
    return str:gsub("([^%w])", "\\%1")
end

-- Formate un message avec des paramètres
-- @param msg string: Le message avec placeholders %{key}
-- @param params table|nil: Table de paramètres de remplacement
-- @return string: Le message formaté
function M.format_message(msg, params)
    if not params then return msg end
    
    return msg:gsub("%%{(.-)}", function(key)
        return params[key] or ""
    end)
end

return M