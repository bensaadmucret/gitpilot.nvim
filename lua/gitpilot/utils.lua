-- lua/gitpilot/utils.lua

local M = {}

-- Configuration par défaut
local config = {
    git = {
        timeout = 5000,
        command = "git"
    }
}

-- Cache pour les résultats des commandes
local cache = {
    data = {},
    timeout = {}
}

-- Configure le module
function M.setup(opts)
    if opts and opts.git then
        config.git = vim.tbl_deep_extend("force", config.git, opts.git)
    end
end

-- Nettoie le cache expiré
local function clean_cache()
    local now = vim and vim.loop.now() or os.time() * 1000
    for key, timeout in pairs(cache.timeout) do
        if now > timeout then
            cache.data[key] = nil
            cache.timeout[key] = nil
        end
    end
end

-- Exécute une commande shell et retourne le résultat
function M.execute_command(cmd)
    local output = vim.fn.system(cmd)
    local success = vim.v.shell_error == 0
    if success then
        output = output:gsub("^%s*(.-)%s*$", "%1")
    end
    return success, output
end

-- Exécute une commande git de manière asynchrone
function M.git_async(args, callback, opts)
    opts = vim.tbl_deep_extend("force", {
        cwd = vim.fn.getcwd(),
        timeout = config.git.timeout,
        cache_key = nil,
        cache_timeout = 5000
    }, opts or {})
    
    -- Vérifie le cache
    if opts.cache_key and cache.data[opts.cache_key] then
        local now = vim.loop.now()
        if now < cache.timeout[opts.cache_key] then
            vim.schedule(function()
                callback(true, cache.data[opts.cache_key])
            end)
            return
        end
    end
    
    -- Prépare la commande
    local cmd = config.git.command
    local stdout = {}
    local stderr = {}
    
    -- Lance la commande
    local job_id = vim.fn.jobstart({cmd, unpack(args)}, {
        cwd = opts.cwd,
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
            if data then
                vim.list_extend(stdout, data)
            end
        end,
        on_stderr = function(_, data)
            if data then
                vim.list_extend(stderr, data)
            end
        end,
        on_exit = function(_, code)
            -- Nettoie les sorties
            local out = table.concat(stdout, "\n"):gsub("^%s*(.-)%s*$", "%1")
            local err = table.concat(stderr, "\n"):gsub("^%s*(.-)%s*$", "%1")
            
            -- Met en cache si nécessaire
            if opts.cache_key and code == 0 then
                cache.data[opts.cache_key] = out
                cache.timeout[opts.cache_key] = vim.loop.now() + opts.cache_timeout
                clean_cache()
            end
            
            -- Appelle le callback
            vim.schedule(function()
                callback(code == 0, code == 0 and out or err)
            end)
        end
    })
    
    -- Configure le timeout
    if job_id > 0 and opts.timeout > 0 then
        vim.defer_fn(function()
            if vim.fn.jobwait({job_id}, 0)[1] == -1 then
                vim.fn.jobstop(job_id)
                vim.schedule(function()
                    callback(false, "Command timed out")
                end)
            end
        end, opts.timeout)
    end
    
    return job_id > 0
end

-- Exécute une commande git de manière synchrone
function M.git_sync(args, opts)
    opts = vim.tbl_deep_extend("force", {
        cwd = vim.fn.getcwd(),
        timeout = config.git.timeout,
        cache_key = nil,
        cache_timeout = 5000
    }, opts or {})
    
    -- Vérifie le cache
    if opts.cache_key and cache.data[opts.cache_key] then
        local now = vim and vim.loop.now() or os.time() * 1000
        if now < cache.timeout[opts.cache_key] then
            return true, cache.data[opts.cache_key]
        end
    end
    
    -- Prépare la commande
    local success, output
    if M.system then
        success, output = M.system(config.git.command, args)
    else
        local cmd = string.format("%s %s", config.git.command, table.concat(args, " "))
        output = vim.fn.system(cmd)
        success = vim.v.shell_error == 0
    end
    
    -- Met en cache si nécessaire
    if opts.cache_key and success then
        cache.data[opts.cache_key] = output
        cache.timeout[opts.cache_key] = (vim and vim.loop.now() or os.time() * 1000) + opts.cache_timeout
        clean_cache()
    end
    
    return success, output
end

-- Vérifie si le répertoire courant est un dépôt git
function M.is_git_repo(path)
    path = path or vim.fn.getcwd()
    local success = M.git_sync({"rev-parse", "--is-inside-work-tree"}, {
        cwd = path,
        cache_key = "is_git_repo:" .. path,
        cache_timeout = 30000
    })
    return success
end

-- Obtient la branche courante
function M.get_current_branch(path)
    path = path or vim.fn.getcwd()
    local success, output = M.git_sync({"symbolic-ref", "--short", "HEAD"}, {
        cwd = path,
        cache_key = "current_branch:" .. path,
        cache_timeout = 1000
    })
    return success and output:gsub("%s+", "") or nil
end

-- Liste toutes les branches
function M.list_branches(path)
    path = path or vim.fn.getcwd()
    local success, output = M.git_sync({"branch", "--list", "--no-color"}, {
        cwd = path,
        cache_key = "branches:" .. path,
        cache_timeout = 1000
    })
    
    if not success then
        return nil
    end
    
    local branches = {}
    for branch in output:gmatch("[%s*]+(.-)\n") do
        table.insert(branches, branch:gsub("^%s*(.-)%s*$", "%1"))
    end
    
    return branches
end

-- Vérifie si une branche existe
function M.branch_exists(branch, path)
    path = path or vim.fn.getcwd()
    local success = M.git_sync({"show-ref", "--verify", "--quiet", "refs/heads/" .. branch}, {
        cwd = path
    })
    return success
end

-- Vérifie si un fichier existe
function M.is_file(path)
    local stat = vim.loop.fs_stat(path)
    return stat and stat.type == "file" or false
end

-- Lit le contenu d'un fichier
function M.read_file(path)
    local fd = vim.loop.fs_open(path, "r", 438)
    if not fd then
        return nil
    end
    
    local stat = vim.loop.fs_fstat(fd)
    if not stat then
        vim.loop.fs_close(fd)
        return nil
    end
    
    local data = vim.loop.fs_read(fd, stat.size, 0)
    vim.loop.fs_close(fd)
    
    return data
end

-- Échappe une chaîne de caractères pour une utilisation sûre dans les commandes shell
function M.escape_string(str)
    if not str then return "" end
    -- Échappe les caractères spéciaux
    return str:gsub('([%(%)%[%]%{%}%\\%*%+%-%~%`%!%@%#%$%%%^%&%*%=%|%<%>%,%?%\'%"%_%/%.])', '\\%1')
end

-- Function to check if we're in a test environment
function M.is_test_env()
    return false
end

return M