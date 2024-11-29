local M = {}
local fn = vim.fn
local uv = vim.loop

-- Configuration locale
local config = {}

-- Setup function
M.setup = function(opts)
    config = opts
end

-- Exécute une commande git et retourne le résultat
M.git_command = function(command)
    local git_cmd = config.git and config.git.cmd or "git"
    local timeout = config.git and config.git.timeout or 5000
    
    local cmd = git_cmd .. " " .. command
    local output = ""
    local error_output = ""
    local handle
    local stdout = uv.new_pipe(false)
    local stderr = uv.new_pipe(false)
    local timer = uv.new_timer()

    handle = uv.spawn(git_cmd, {
        args = vim.split(command, " "),
        stdio = {nil, stdout, stderr},
        cwd = fn.getcwd(),
    }, function(code)
        if code ~= 0 then
            vim.schedule(function()
                vim.notify("Git error: " .. error_output, vim.log.levels.ERROR)
            end)
            return nil
        end
        stdout:close()
        stderr:close()
        handle:close()
        timer:close()
    end)

    if not handle then
        vim.notify("Failed to spawn git process", vim.log.levels.ERROR)
        return nil
    end

    -- Timeout
    timer:start(timeout, 0, function()
        vim.schedule(function()
            vim.notify("Git command timed out", vim.log.levels.ERROR)
        end)
        handle:kill(9)
        stdout:close()
        stderr:close()
        timer:close()
    end)

    -- Lecture de la sortie standard
    stdout:read_start(function(err, data)
        if err then
            vim.schedule(function()
                vim.notify("Error reading git output: " .. err, vim.log.levels.ERROR)
            end)
            return
        end
        if data then
            output = output .. data
        end
    end)

    -- Lecture des erreurs
    stderr:read_start(function(err, data)
        if err then
            vim.schedule(function()
                vim.notify("Error reading git error output: " .. err, vim.log.levels.ERROR)
            end)
            return
        end
        if data then
            error_output = error_output .. data
        end
    end)

    -- Attendre la fin de l'exécution
    vim.wait(timeout, function()
        return not handle:is_active()
    end)

    return output
end

-- Exécute une commande git et retourne le succès/erreur
M.git_command_with_error = function(args)
    local cmd = string.format("%s %s 2>&1", config.git and config.git.cmd or "git", args)
    local handle = io.popen(cmd)
    if not handle then return false, "Failed to execute command" end
    
    local result = handle:read("*a")
    local success = handle:close()
    
    if success then
        return true, result
    else
        return false, result
    end
end

-- Vérifie si un fichier existe
M.file_exists = function(path)
    local stat = uv.fs_stat(path)
    return stat and stat.type == "file"
end

-- Vérifie si un répertoire existe
M.dir_exists = function(path)
    local stat = uv.fs_stat(path)
    return stat and stat.type == "directory"
end

-- Crée un répertoire récursivement
M.mkdir_p = function(path)
    local current = ""
    for dir in path:gmatch("[^/]+") do
        current = current .. "/" .. dir
        if not M.dir_exists(current) then
            uv.fs_mkdir(current, 493) -- 0755 en octal
        end
    end
end

-- Obtient le répertoire git racine
M.get_git_root = function()
    local root = M.git_command("rev-parse --show-toplevel")
    if root then
        return root:gsub("\n", "")
    end
    return nil
end

-- Vérifie si le répertoire courant est un dépôt git
M.is_git_repo = function()
    local result = M.git_command("rev-parse --is-inside-work-tree")
    return result and result:match("true") ~= nil
end

-- Obtient la branche courante
M.get_current_branch = function()
    local branch = M.git_command("symbolic-ref --short HEAD")
    if branch then
        return branch:gsub("\n", "")
    end
    return nil
end

-- Vérifie si un fichier est suivi par git
M.is_tracked = function(file)
    local result = M.git_command("ls-files --error-unmatch " .. file)
    return result ~= nil
end

-- Vérifie si un fichier a des modifications
M.is_modified = function(file)
    local result = M.git_command("diff --name-only " .. file)
    return result and result ~= ""
end

-- Obtient le statut d'un fichier
M.get_file_status = function(file)
    local result = M.git_command("status --porcelain " .. file)
    if result and result ~= "" then
        return result:sub(1, 2)
    end
    return nil
end

-- Formate une commande git
M.format_command = function(cmd, ...)
    local args = {...}
    for i, arg in ipairs(args) do
        if arg:match("%s") then
            args[i] = string.format('"%s"', arg)
        end
    end
    return string.format(cmd, unpack(args))
end

return M
