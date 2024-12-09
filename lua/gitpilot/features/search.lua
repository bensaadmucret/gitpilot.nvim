-- lua/gitpilot/features/search.lua

local M = {}
local ui = require('gitpilot.ui')
local utils = require('gitpilot.utils')
local i18n = require('gitpilot.i18n')

-- Configuration locale
local config = {
    max_results = 100,
    preview_lines = 10
}

-- Initialisation du module
function M.setup(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})
end

-- Vérifie si le répertoire courant est un dépôt git
local function is_git_repo()
    local success, _ = utils.execute_command("git rev-parse --is-inside-work-tree")
    return success
end

-- Recherche dans les commits
function M.commits(query)
    if not is_git_repo() then
        ui.show_error(i18n.t('search.error.not_git_repo'))
        return false
    end

    if not query or query == "" then
        ui.show_error(i18n.t('search.error.empty_query'))
        return false
    end

    local success, results = utils.execute_command(string.format(
        "git log -n %d --pretty=format:'%%h - %%s (%%cr) <%%an>' --grep=%s -i",
        config.max_results,
        utils.escape_string(query)
    ))
    if not success then
        ui.show_error(i18n.t('search.error.commits_failed'))
        return false
    end

    local commits = {}
    local hashes = {}
    for line in results:gmatch("[^\r\n]+") do
        local hash = line:match("^([^%s]+)")
        if hash then
            table.insert(commits, line)
            table.insert(hashes, hash)
        end
    end

    if #commits == 0 then
        ui.show_info(i18n.t('search.info.no_commits_found'))
        return false
    end

    ui.select(commits, {
        prompt = i18n.t("search.select_commit")
    }, function(choice)
        if choice then
            local index = vim.tbl_contains(commits, choice)
            if index then
                local hash = hashes[index]
                local success, details = utils.execute_command("git show " .. utils.escape_string(hash))
                if success then
                    ui.show_preview({
                        title = i18n.t('search.preview.commit_title', {hash = hash:sub(1,7)}),
                        content = details
                    })
                end
            end
        end
    end)

    return true
end

-- Recherche dans les fichiers
function M.files(query)
    if not is_git_repo() then
        ui.show_error(i18n.t('search.error.not_git_repo'))
        return false
    end

    if not query or query == "" then
        ui.show_error(i18n.t('search.error.empty_query'))
        return false
    end

    local success, results = utils.execute_command(string.format(
        "git grep -n -l -i %s",
        utils.escape_string(query)
    ))
    if not success then
        ui.show_error(i18n.t('search.error.files_failed'))
        return false
    end

    local files = {}
    for line in results:gmatch("[^\r\n]+") do
        if line ~= "" then
            table.insert(files, line)
        end
    end

    if #files == 0 then
        ui.show_info(i18n.t('search.info.no_files_found'))
        return false
    end

    ui.select(files, {
        prompt = i18n.t("search.select_file")
    }, function(choice)
        if choice then
            local success, content = utils.execute_command(string.format(
                "git grep -n -i %s %s | head -n %d",
                utils.escape_string(query),
                utils.escape_string(choice),
                config.preview_lines
            ))
            if success then
                ui.show_preview({
                    title = i18n.t('search.preview.file_title', {file = choice}),
                    content = content
                })
            end
        end
    end)

    return true
end

-- Recherche dans les branches
function M.branches(query)
    if not is_git_repo() then
        ui.show_error(i18n.t('search.error.not_git_repo'))
        return false
    end

    if not query or query == "" then
        ui.show_error(i18n.t('search.error.empty_query'))
        return false
    end

    local success, results = utils.execute_command("git branch --no-color")
    if not success then
        ui.show_error(i18n.t('search.error.branches_failed'))
        return false
    end

    local branches = {}
    local query_lower = query:lower()
    for line in results:gmatch("[^\r\n]+") do
        local branch = line:match("^%s*%*?%s*(.+)$")
        if branch and branch:lower():find(query_lower) then
            table.insert(branches, branch)
        end
    end

    if #branches == 0 then
        ui.show_info(i18n.t('search.info.no_branches_found'))
        return false
    end

    ui.select(branches, {
        prompt = i18n.t("search.select_branch")
    }, function(choice)
        if choice then
            local success, log = utils.execute_command(string.format(
                "git log -n %d %s --pretty=format:'%%h - %%s (%%cr) <%%an>'",
                config.preview_lines,
                utils.escape_string(choice)
            ))
            if success then
                ui.show_preview({
                    title = i18n.t('search.preview.branch_title', {branch = choice}),
                    content = log
                })
            end
        end
    end)

    return true
end

-- Recherche dans les tags
function M.tags(query)
    if not is_git_repo() then
        ui.show_error(i18n.t('search.error.not_git_repo'))
        return false
    end

    if not query or query == "" then
        ui.show_error(i18n.t('search.error.empty_query'))
        return false
    end

    local success, results = utils.execute_command("git tag")
    if not success then
        ui.show_error(i18n.t('search.error.tags_failed'))
        return false
    end

    local tags = {}
    local query_lower = query:lower()
    for line in results:gmatch("[^\r\n]+") do
        if line:lower():find(query_lower) then
            table.insert(tags, line)
        end
    end

    if #tags == 0 then
        ui.show_info(i18n.t('search.info.no_tags_found'))
        return false
    end

    ui.select(tags, {
        prompt = i18n.t("search.select_tag")
    }, function(choice)
        if choice then
            local success, details = utils.execute_command("git show " .. utils.escape_string(choice))
            if success then
                ui.show_preview({
                    title = i18n.t('search.preview.tag_title', {tag = choice}),
                    content = details
                })
            end
        end
    end)

    return true
end

return M
