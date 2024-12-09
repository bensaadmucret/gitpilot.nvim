local M = {}
local issues = require("gitpilot.features.issues")
local ui = require("gitpilot.ui")
local i18n = require("gitpilot.i18n")

local function format_issue(issue)
    local status = issue.state or issue.status
    local labels = issue.labels and table.concat(issue.labels, ", ") or ""
    return string.format("#%s [%s] %s %s",
        issue.number or issue.iid,
        status,
        issue.title,
        labels ~= "" and "(" .. labels .. ")" or ""
    )
end

local function show_issue_details(issue)
    local content = {
        i18n.t("issues.details.number", {number = issue.number or issue.iid}),
        i18n.t("issues.details.title", {title = issue.title}),
        i18n.t("issues.details.status", {status = issue.state or issue.status}),
        i18n.t("issues.details.author", {author = issue.user and issue.user.login or issue.author and issue.author.username}),
        "",
        issue.body or issue.description,
        "",
        i18n.t("issues.details.labels") .. ":",
        table.concat(issue.labels or {}, ", "),
        "",
        i18n.t("issues.details.assignees") .. ":",
    }
    
    local assignees = issue.assignees or {issue.assignee}
    for _, assignee in ipairs(assignees) do
        if assignee then
            table.insert(content, "- " .. (assignee.login or assignee.username))
        end
    end
    
    ui.show_text(table.concat(content, "\n"))
end

function M.show_issues_menu()
    local menu_items = {
        {
            label = i18n.t("issues.create.title"),
            description = i18n.t("issues.create.description"),
            action = M.create_issue
        },
        {
            label = i18n.t("issues.list.title"),
            description = i18n.t("issues.list.description"),
            action = M.list_issues
        },
        {
            label = i18n.t("issues.search.title"),
            description = i18n.t("issues.search.description"),
            action = M.search_issues
        },
        {
            label = i18n.t("issues.link.title"),
            description = i18n.t("issues.link.description"),
            action = M.link_commit_to_issue
        }
    }
    
    ui.show_menu(i18n.t("issues.menu.title"), menu_items)
end

function M.create_issue()
    -- Vérifie les templates disponibles
    local templates = issues.get_templates()
    local template_content = ""
    
    if next(templates) then
        local template_menu = {}
        for name, content in pairs(templates) do
            table.insert(template_menu, {
                label = name,
                action = function()
                    template_content = content
                    M.create_issue_with_template(template_content)
                end
            })
        end
        
        ui.show_menu(i18n.t("issues.create.select_template"), template_menu)
    else
        M.create_issue_with_template("")
    end
end

function M.create_issue_with_template(template)
    ui.input(i18n.t("issues.create.title_prompt"), function(title)
        if title == "" then
            ui.error(i18n.t("issues.create.title_empty"))
            return
        end
        
        ui.input(i18n.t("issues.create.body_prompt"), function(body)
            body = body ~= "" and body or template
            
            ui.input(i18n.t("issues.create.labels_prompt"), function(labels_str)
                local labels = {}
                if labels_str ~= "" then
                    for label in labels_str:gmatch("[^,]+") do
                        table.insert(labels, vim.trim(label))
                    end
                end
                
                ui.input(i18n.t("issues.create.assignees_prompt"), function(assignees_str)
                    local assignees = {}
                    if assignees_str ~= "" then
                        for assignee in assignees_str:gmatch("[^,]+") do
                            table.insert(assignees, vim.trim(assignee))
                        end
                    end
                    
                    local success, result = issues.create_issue(title, body, labels, assignees)
                    if success then
                        ui.info(i18n.t("issues.create.success", {number = result.number or result.iid}))
                    else
                        ui.error(i18n.t("issues.create.error", {error = result}))
                    end
                end)
            end)
        end)
    end)
end

function M.list_issues()
    local success, result = issues.list_issues()
    if not success then
        ui.error(i18n.t("issues.list.error", {error = result}))
        return
    end
    
    if #result == 0 then
        ui.info(i18n.t("issues.list.empty"))
        return
    end
    
    local menu_items = {}
    for _, issue in ipairs(result) do
        table.insert(menu_items, {
            label = format_issue(issue),
            action = function()
                show_issue_details(issue)
            end
        })
    end
    
    ui.show_menu(i18n.t("issues.list.title"), menu_items)
end

function M.search_issues()
    local filter_menu = {
        {
            label = i18n.t("issues.search.by_author"),
            action = function()
                ui.input(i18n.t("issues.search.author_prompt"), function(author)
                    local success, result = issues.list_issues({author = author})
                    if success then
                        M.show_filtered_issues(result)
                    end
                end)
            end
        },
        {
            label = i18n.t("issues.search.by_label"),
            action = function()
                ui.input(i18n.t("issues.search.label_prompt"), function(label)
                    local success, result = issues.list_issues({labels = label})
                    if success then
                        M.show_filtered_issues(result)
                    end
                end)
            end
        },
        {
            label = i18n.t("issues.search.by_status"),
            action = function()
                local status_menu = {
                    {
                        label = i18n.t("issues.status.open"),
                        action = function()
                            local success, result = issues.list_issues({state = "open"})
                            if success then
                                M.show_filtered_issues(result)
                            end
                        end
                    },
                    {
                        label = i18n.t("issues.status.closed"),
                        action = function()
                            local success, result = issues.list_issues({state = "closed"})
                            if success then
                                M.show_filtered_issues(result)
                            end
                        end
                    }
                }
                ui.show_menu(i18n.t("issues.search.select_status"), status_menu)
            end
        }
    }
    
    ui.show_menu(i18n.t("issues.search.title"), filter_menu)
end

function M.show_filtered_issues(issues_list)
    if #issues_list == 0 then
        ui.info(i18n.t("issues.search.no_results"))
        return
    end
    
    local menu_items = {}
    for _, issue in ipairs(issues_list) do
        table.insert(menu_items, {
            label = format_issue(issue),
            action = function()
                show_issue_details(issue)
            end
        })
    end
    
    ui.show_menu(i18n.t("issues.search.results"), menu_items)
end

function M.link_commit_to_issue()
    ui.input(i18n.t("issues.link.commit_prompt"), function(commit_hash)
        if commit_hash == "" then
            ui.error(i18n.t("issues.link.commit_empty"))
            return
        end
        
        ui.input(i18n.t("issues.link.issue_prompt"), function(issue_id)
            if issue_id == "" then
                ui.error(i18n.t("issues.link.issue_empty"))
                return
            end
            
            local success, result = issues.link_commit_to_issue(commit_hash, issue_id)
            if success then
                ui.info(i18n.t("issues.link.success"))
            else
                ui.error(i18n.t("issues.link.error", {error = result}))
            end
        end)
    end)
end

function M.setup()
    ui.add_menu_item({
        label = i18n.t("issues.menu.title"),
        description = i18n.t("issues.menu.description"),
        action = M.show_issues_menu
    })
end

return M
