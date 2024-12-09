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

-- Nettoie le cache expiré
local function clean_cache()
    local now = vim.loop.now()
    for key, timeout in pairs(cache.timeout) do
        if now > timeout then
            cache.data[key] = nil
            cache.timeout[key] = nil
        end
    end
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
        local now = vim.loop.now()
        if now < cache.timeout[opts.cache_key] then
            return true, cache.data[opts.cache_key]
        end
    end
    
    -- Prépare la commande
    local cmd = string.format("%s %s", config.git.command, table.concat(args, " "))
    
    -- Lance la commande
    local output = vim.fn.system(cmd)
    local success = vim.v.shell_error == 0
    
    -- Met en cache si nécessaire
    if opts.cache_key and success then
        cache.data[opts.cache_key] = output
        cache.timeout[opts.cache_key] = vim.loop.now() + opts.cache_timeout
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

-- Initialisation du module
function M.setup(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})
end

-- Réinitialise le cache
function M.reset_cache()
    cache.data = {}
    cache.timeout = {}
end

-- Vérifie si nous sommes dans un environnement de test
function M.is_test_env()
    return vim.env.GITPILOT_TEST == "1"
end

return M