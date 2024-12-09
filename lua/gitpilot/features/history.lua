local M = {}
local utils = require("gitpilot.utils")
local config = require("gitpilot.config")

-- Configuration par défaut
local default_config = {
    max_commits = 1000,
    cache_timeout = 300,  -- 5 minutes
    date_format = "%Y-%m-%d %H:%M:%S",
    show_signature = true,
    show_stats = true
}

-- Configuration actuelle
local current_config = vim.deepcopy(default_config)

-- Configure le module
function M.setup(opts)
    current_config = vim.tbl_deep_extend("force", current_config, opts or {})
end

-- Récupère l'historique des commits avec formatage personnalisé
-- @param options: table avec les options de filtrage
--   - author: filtrer par auteur
--   - since: date de début
--   - until: date de fin
--   - path: filtrer par fichier/dossier
--   - branch: filtrer par branche
--   - limit: nombre maximum de commits à retourner
function M.get_commits(options)
    options = options or {}
    local cmd = "git log --pretty=format:'%H|%an|%ad|%s' --date=format:'%Y-%m-%d %H:%M:%S'"
    
    if options.author then
        cmd = cmd .. " --author=" .. utils.shell_escape(options.author)
    end
    if options.since then
        cmd = cmd .. " --since=" .. utils.shell_escape(options.since)
    end
    if options.until then
        cmd = cmd .. " --until=" .. utils.shell_escape(options.until)
    end
    if options.path then
        cmd = cmd .. " -- " .. utils.shell_escape(options.path)
    end
    if options.branch then
        cmd = cmd .. " " .. utils.shell_escape(options.branch)
    end
    if options.limit then
        cmd = cmd .. " -n " .. options.limit
    end
    
    local success, result = utils.execute_command(cmd)
    if not success then
        return false, {}
    end
    
    local commits = {}
    for line in result:gmatch("[^\r\n]+") do
        local hash, author, date, subject = line:match("([^|]+)|([^|]+)|([^|]+)|(.+)")
        table.insert(commits, {
            hash = hash,
            author = author,
            date = date,
            subject = subject
        })
    end
    
    return true, commits
end

-- Récupère les détails d'un commit spécifique
function M.get_commit_details(hash)
    local cmd = "git show --pretty=format:'%H|%an|%ae|%ad|%s%n%n%b' --date=format:'%Y-%m-%d %H:%M:%S' " .. utils.shell_escape(hash)
    local success, result = utils.execute_command(cmd)
    if not success then
        return false, nil
    end
    
    local header, body = result:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^\n]+)\n\n(.+)")
    if not header then
        return false, nil
    end
    
    -- Récupère les fichiers modifiés
    local cmd_files = "git show --pretty='' --name-status " .. utils.shell_escape(hash)
    local files_success, files_result = utils.execute_command(cmd_files)
    local files = {}
    if files_success then
        for line in files_result:gmatch("[^\r\n]+") do
            local status, file = line:match("([AMD])\t(.+)")
            if status and file then
                table.insert(files, {status = status, file = file})
            end
        end
    end
    
    return true, {
        hash = hash,
        author = author,
        email = email,
        date = date,
        subject = subject,
        body = body,
        files = files
    }
end

-- Récupère le graphe des branches
function M.get_graph(options)
    options = options or {}
    local cmd = "git log --graph --pretty=format:'%h|%d|%s|%cr|%an' --abbrev-commit --date=relative"
    
    if options.all then
        cmd = cmd .. " --all"
    end
    if options.limit then
        cmd = cmd .. " -n " .. options.limit
    end
    
    local success, result = utils.execute_command(cmd)
    if not success then
        return false, {}
    end
    
    local graph = {}
    for line in result:gmatch("[^\r\n]+") do
        local graph_part = line:match("^([^|]+)")
        local hash, refs, subject, date, author = line:match("|([^|]+)|([^|]*)|([^|]+)|([^|]+)|(.+)")
        
        table.insert(graph, {
            graph = graph_part,
            hash = hash,
            refs = refs,
            subject = subject,
            date = date,
            author = author
        })
    end
    
    return true, graph
end

-- Recherche dans l'historique
function M.search_commits(query, options)
    options = options or {}
    local cmd = "git log -S" .. utils.shell_escape(query) .. " --pretty=format:'%H|%an|%ad|%s' --date=format:'%Y-%m-%d %H:%M:%S'"
    
    if options.limit then
        cmd = cmd .. " -n " .. options.limit
    end
    
    local success, result = utils.execute_command(cmd)
    if not success then
        return false, {}
    end
    
    local commits = {}
    for line in result:gmatch("[^\r\n]+") do
        local hash, author, date, subject = line:match("([^|]+)|([^|]+)|([^|]+)|(.+)")
        table.insert(commits, {
            hash = hash,
            author = author,
            date = date,
            subject = subject
        })
    end
    
    return true, commits
end

-- Obtient les statistiques d'un commit
function M.get_commit_stats(hash)
    local cmd = "git show --numstat --format='' " .. utils.shell_escape(hash)
    local success, result = utils.execute_command(cmd)
    if not success then
        return false, {}
    end
    
    local stats = {}
    for line in result:gmatch("[^\r\n]+") do
        local added, deleted, file = line:match("(%d+)\t(%d+)\t(.+)")
        if added and deleted and file then
            table.insert(stats, {
                file = file,
                added = tonumber(added),
                deleted = tonumber(deleted)
            })
        end
    end
    
    return true, stats
end

return M
