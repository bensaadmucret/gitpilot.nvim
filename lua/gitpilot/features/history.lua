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
local current_config = (vim and vim.deepcopy or function(tbl) return tbl end)(default_config)

-- Configure le module
function M.setup(opts)
    current_config = (vim and vim.tbl_deep_extend or function(_, t, _) return t end)("force", current_config, opts or {})
end

-- Récupère l'historique des commits avec formatage personnalisé
-- @param options: table avec les options de filtrage
--   - author: filtrer par auteur
--   - since: date de début
--   - until_date: date de fin
--   - path: filtrer par fichier/dossier
--   - branch: filtrer par branche
--   - limit: nombre maximum de commits à retourner
-- Version asynchrone de get_commits
function M.get_commits_async(options, callback)
    options = options or {}
    local cmd = "git log --pretty=format:'%H|%an|%ad|%s' --date=format:'%Y-%m-%d %H:%M:%S'"
    if options.author then
        cmd = cmd .. " --author=" .. utils.shell_escape(options.author)
    end
    if options.since then
        cmd = cmd .. " --since=" .. utils.shell_escape(options.since)
    end
    if options.until_date then
        cmd = cmd .. " --until=" .. utils.shell_escape(options.until_date)
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
    utils.execute_command_async(cmd, function(success, result)
        if not success then
            if vim and vim.notify then vim.notify('Erreur lors de la récupération des commits', vim.log.levels.ERROR) end
            callback(false, {})
            return
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
        callback(true, commits)
    end)
end

-- Version synchrone (dépréciée)
function M.get_commits(options)
    (vim and vim.schedule or function(f) f() end)(function()
      if vim and vim.notify then vim.notify('get_commits synchrone est déprécié. Utilisez get_commits_async.', vim.log.levels.WARN) end
    end)
    options = options or {}
    local cmd = "git log --pretty=format:'%H|%an|%ad|%s' --date=format:'%Y-%m-%d %H:%M:%S'"
    if options.author then
        cmd = cmd .. " --author=" .. utils.shell_escape(options.author)
    end
    if options.since then
        cmd = cmd .. " --since=" .. utils.shell_escape(options.since)
    end
    if options.until_date then
        cmd = cmd .. " --until=" .. utils.shell_escape(options.until_date)
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
-- Version asynchrone de get_commit_details
function M.get_commit_details_async(hash, callback)
    local cmd = "git show --pretty=format:'%H|%an|%ae|%ad|%s%n%n%b' --date=format:'%Y-%m-%d %H:%M:%S' " .. utils.shell_escape(hash)
    utils.execute_command_async(cmd, function(success, result)
        if not success then
            if vim and vim.notify then vim.notify('Erreur lors de la récupération des détails du commit', vim.log.levels.ERROR) end
            callback(false, nil)
            return
        end
        local header, body = result:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^\n]+)\n\n(.+)")
        if not header then
            callback(false, nil)
            return
        end
        -- Récupère les fichiers modifiés (asynchrone imbriqué)
        local cmd_files = "git show --pretty='' --name-status " .. utils.shell_escape(hash)
        utils.execute_command_async(cmd_files, function(files_success, files_result)
            local files = {}
            if files_success then
                for line in files_result:gmatch("[^\r\n]+") do
                    local status, file = line:match("([AMD])\t(.+)")
                    if status and file then
                        table.insert(files, {status = status, file = file})
                    end
                end
            end
            callback(true, {
                hash = hash,
                author = author,
                email = email,
                date = date,
                subject = subject,
                body = body,
                files = files
            })
        end)
    end)
end

-- Version synchrone (dépréciée)
function M.get_commit_details(hash)
    (vim and vim.schedule or function(f) f() end)(function()
      if vim and vim.notify then vim.notify('get_commit_details synchrone est déprécié. Utilisez get_commit_details_async.', vim.log.levels.WARN) end
    end)
    local cmd = "git show --pretty=format:'%H|%an|%ae|%ad|%s%n%n%b' --date=format:'%Y-%m-%d %H:%M:%S' " .. utils.shell_escape(hash)
    local success, result = utils.execute_command(cmd)
    if not success then
        return false, nil
    end
    local header, body = result:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^\n]+)\n\n(.+)")
    if not header then
        return false, nil
    end
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
-- Version asynchrone de get_graph
function M.get_graph_async(options, callback)
    options = options or {}
    local cmd = "git log --graph --pretty=format:'%h|%d|%s|%cr|%an' --abbrev-commit --date=relative"
    if options.all then
        cmd = cmd .. " --all"
    end
    if options.limit then
        cmd = cmd .. " -n " .. options.limit
    end
    utils.execute_command_async(cmd, function(success, result)
        if not success then
            if vim and vim.notify then vim.notify('Erreur lors de la récupération du graphe git', vim.log.levels.ERROR) end
            callback(false, {})
            return
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
        callback(true, graph)
    end)
end

-- Version synchrone (dépréciée)
function M.get_graph(options)
    (vim and vim.schedule or function(f) f() end)(function()
      if vim and vim.notify then vim.notify('get_graph synchrone est déprécié. Utilisez get_graph_async.', vim.log.levels.WARN) end
    end)
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
-- Version asynchrone de search_commits
function M.search_commits_async(query, options, callback)
    options = options or {}
    local cmd = "git log -S" .. utils.shell_escape(query) .. " --pretty=format:'%H|%an|%ad|%s' --date=format:'%Y-%m-%d %H:%M:%S'"
    if options.limit then
        cmd = cmd .. " -n " .. options.limit
    end
    utils.execute_command_async(cmd, function(success, result)
        if not success then
            if vim and vim.notify then vim.notify('Erreur lors de la recherche dans l\'historique', vim.log.levels.ERROR) end
            callback(false, {})
            return
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
        callback(true, commits)
    end)
end

-- Version synchrone (dépréciée)
function M.search_commits(query, options)
    (vim and vim.schedule or function(f) f() end)(function()
      if vim and vim.notify then vim.notify('search_commits synchrone est déprécié. Utilisez search_commits_async.', vim.log.levels.WARN) end
    end)
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
-- Version asynchrone de get_commit_stats
function M.get_commit_stats_async(hash, callback)
    local cmd = "git show --numstat --format='' " .. utils.shell_escape(hash)
    utils.execute_command_async(cmd, function(success, result)
        if not success then
            if vim and vim.notify then vim.notify('Erreur lors de la récupération des stats du commit', vim.log.levels.ERROR) end
            callback(false, {})
            return
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
        callback(true, stats)
    end)
end

-- Version synchrone (dépréciée)
function M.get_commit_stats(hash)
    (vim and vim.schedule or function(f) f() end)(function()
      if vim and vim.notify then vim.notify('get_commit_stats synchrone est déprécié. Utilisez get_commit_stats_async.', vim.log.levels.WARN) end
    end)
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
