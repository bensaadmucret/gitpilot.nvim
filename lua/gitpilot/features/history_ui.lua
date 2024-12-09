local M = {}
local history = require("gitpilot.features.history")
local ui = require("gitpilot.ui")
local i18n = require("gitpilot.i18n")

local function format_commit_line(commit)
    return string.format("%s | %s | %s | %s",
        commit.hash:sub(1, 7),
        commit.date,
        commit.author,
        commit.subject
    )
end

local function show_commit_details(commit_hash)
    local success, details = history.get_commit_details(commit_hash)
    if not success then
        ui.error(i18n.t("history.error.details"))
        return
    end
    
    local content = {
        i18n.t("history.details.commit", {hash = details.hash}),
        i18n.t("history.details.author", {author = details.author, email = details.email}),
        i18n.t("history.details.date", {date = details.date}),
        i18n.t("history.details.subject", {subject = details.subject}),
        "",
        details.body,
        "",
        i18n.t("history.details.files"),
        ""
    }
    
    for _, file in ipairs(details.files) do
        local status_symbol = {
            A = "+",
            M = "~",
            D = "-"
        }
        table.insert(content, string.format("%s %s", status_symbol[file.status], file.file))
    end
    
    -- Récupère les statistiques
    local stats_success, stats = history.get_commit_stats(commit_hash)
    if stats_success then
        table.insert(content, "")
        table.insert(content, i18n.t("history.details.stats"))
        for _, stat in ipairs(stats) do
            table.insert(content, string.format("%s: +%d -%d", stat.file, stat.added, stat.deleted))
        end
    end
    
    ui.show_text(table.concat(content, "\n"))
end

function M.show_history_menu()
    local menu_items = {
        {
            label = i18n.t("history.browse.title"),
            description = i18n.t("history.browse.description"),
            action = M.browse_history
        },
        {
            label = i18n.t("history.search.title"),
            description = i18n.t("history.search.description"),
            action = M.search_history
        },
        {
            label = i18n.t("history.graph.title"),
            description = i18n.t("history.graph.description"),
            action = M.show_graph
        },
        {
            label = i18n.t("history.filter.title"),
            description = i18n.t("history.filter.description"),
            action = M.filter_history
        }
    }
    
    ui.show_menu(i18n.t("history.menu.title"), menu_items)
end

function M.browse_history()
    local success, commits = history.get_commits({limit = 50})
    if not success then
        ui.error(i18n.t("history.error.fetch"))
        return
    end
    
    local menu_items = {}
    for _, commit in ipairs(commits) do
        table.insert(menu_items, {
            label = format_commit_line(commit),
            action = function()
                show_commit_details(commit.hash)
            end
        })
    end
    
    ui.show_menu(i18n.t("history.browse.title"), menu_items)
end

function M.search_history()
    ui.input(i18n.t("history.search.prompt"), function(query)
        if query == "" then
            ui.error(i18n.t("history.search.empty"))
            return
        end
        
        local success, commits = history.search_commits(query)
        if not success then
            ui.error(i18n.t("history.error.search"))
            return
        end
        
        if #commits == 0 then
            ui.info(i18n.t("history.search.no_results"))
            return
        end
        
        local menu_items = {}
        for _, commit in ipairs(commits) do
            table.insert(menu_items, {
                label = format_commit_line(commit),
                action = function()
                    show_commit_details(commit.hash)
                end
            })
        end
        
        ui.show_menu(i18n.t("history.search.results"), menu_items)
    end)
end

function M.show_graph()
    local success, graph = history.get_graph({all = true, limit = 50})
    if not success then
        ui.error(i18n.t("history.error.graph"))
        return
    end
    
    local content = {}
    for _, entry in ipairs(graph) do
        table.insert(content, string.format("%s %s %s (%s) - %s",
            entry.graph,
            entry.hash,
            entry.subject,
            entry.date,
            entry.author
        ))
    end
    
    ui.show_text(table.concat(content, "\n"))
end

function M.filter_history()
    local filter_menu = {
        {
            label = i18n.t("history.filter.by_author"),
            action = function()
                ui.input(i18n.t("history.filter.author_prompt"), function(author)
                    local success, commits = history.get_commits({author = author})
                    if success then
                        M.show_filtered_commits(commits)
                    end
                end)
            end
        },
        {
            label = i18n.t("history.filter.by_date"),
            action = function()
                ui.input(i18n.t("history.filter.date_prompt"), function(date)
                    local success, commits = history.get_commits({since = date})
                    if success then
                        M.show_filtered_commits(commits)
                    end
                end)
            end
        },
        {
            label = i18n.t("history.filter.by_file"),
            action = function()
                ui.input(i18n.t("history.filter.file_prompt"), function(file)
                    local success, commits = history.get_commits({path = file})
                    if success then
                        M.show_filtered_commits(commits)
                    end
                end)
            end
        }
    }
    
    ui.show_menu(i18n.t("history.filter.title"), filter_menu)
end

function M.show_filtered_commits(commits)
    if #commits == 0 then
        ui.info(i18n.t("history.filter.no_results"))
        return
    end
    
    local menu_items = {}
    for _, commit in ipairs(commits) do
        table.insert(menu_items, {
            label = format_commit_line(commit),
            action = function()
                show_commit_details(commit.hash)
            end
        })
    end
    
    ui.show_menu(i18n.t("history.filter.results"), menu_items)
end

function M.setup()
    ui.add_menu_item({
        label = i18n.t("history.menu.title"),
        description = i18n.t("history.menu.description"),
        action = M.show_history_menu
    })
end

return M
