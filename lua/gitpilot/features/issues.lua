local M = {}
local utils = require("gitpilot.utils")
local config = require("gitpilot.config")
local curl = require("plenary.curl")

-- Configuration par défaut
local default_config = {
    github_token = nil,
    gitlab_token = nil,
    github_api_url = "https://api.github.com",
    gitlab_api_url = "https://gitlab.com/api/v4",
    templates_dir = vim.fn.stdpath('data') .. '/gitpilot/templates/issues',
    cache_dir = vim.fn.stdpath('data') .. '/gitpilot/cache/issues',
    cache_timeout = 300,  -- 5 minutes
    max_issues = 100,
    auto_refresh = true
}

-- Configuration actuelle
local current_config = vim.deepcopy(default_config)

-- Configure le module
function M.setup(opts)
    current_config = vim.tbl_deep_extend("force", current_config, opts or {})
    
    -- Crée les répertoires nécessaires
    vim.fn.mkdir(current_config.templates_dir, "p")
    vim.fn.mkdir(current_config.cache_dir, "p")
    
    -- Charge les tokens depuis la configuration globale
    current_config.github_token = config.get("github.token") or current_config.github_token
    current_config.gitlab_token = config.get("gitlab.token") or current_config.gitlab_token
end

-- Détecte le type de dépôt (GitHub ou GitLab)
local function detect_repo_type()
    local cmd = "git remote get-url origin"
    local success, result = utils.execute_command(cmd)
    if not success then
        return nil
    end
    
    if result:match("github.com") then
        return "github"
    elseif result:match("gitlab.com") then
        return "gitlab"
    end
    return nil
end

-- Extrait le propriétaire et le nom du dépôt de l'URL
local function get_repo_info()
    local cmd = "git remote get-url origin"
    local success, result = utils.execute_command(cmd)
    if not success then
        return nil, nil
    end
    
    local owner, repo = result:match("[:/]([^/]+)/([^/%.]+)")
    return owner, repo
end

-- Fonctions pour GitHub
local github = {
    create_issue = function(title, body, labels, assignees)
        local owner, repo = get_repo_info()
        if not owner or not repo then
            return false, "Cannot determine repository info"
        end
        
        local url = string.format("%s/repos/%s/%s/issues",
            current_config.github_api_url or default_config.github_api_url,
            owner, repo
        )
        
        local response = curl.post(url, {
            headers = {
                Authorization = "token " .. (current_config.github_token or ""),
                Accept = "application/vnd.github.v3+json"
            },
            body = vim.fn.json_encode({
                title = title,
                body = body,
                labels = labels,
                assignees = assignees
            })
        })
        
        if response.status ~= 201 then
            return false, "Failed to create issue: " .. (response.body or "")
        end
        
        return true, vim.fn.json_decode(response.body)
    end,
    
    list_issues = function(filters)
        local owner, repo = get_repo_info()
        if not owner or not repo then
            return false, "Cannot determine repository info"
        end
        
        local url = string.format("%s/repos/%s/%s/issues",
            current_config.github_api_url or default_config.github_api_url,
            owner, repo
        )
        
        if filters then
            local params = {}
            for k, v in pairs(filters) do
                table.insert(params, k .. "=" .. v)
            end
            if #params > 0 then
                url = url .. "?" .. table.concat(params, "&")
            end
        end
        
        local response = curl.get(url, {
            headers = {
                Authorization = "token " .. (current_config.github_token or ""),
                Accept = "application/vnd.github.v3+json"
            }
        })
        
        if response.status ~= 200 then
            return false, "Failed to list issues: " .. (response.body or "")
        end
        
        return true, vim.fn.json_decode(response.body)
    end,
    
    update_issue = function(issue_number, updates)
        local owner, repo = get_repo_info()
        if not owner or not repo then
            return false, "Cannot determine repository info"
        end
        
        local url = string.format("%s/repos/%s/%s/issues/%s",
            current_config.github_api_url or default_config.github_api_url,
            owner, repo, issue_number
        )
        
        local response = curl.patch(url, {
            headers = {
                Authorization = "token " .. (current_config.github_token or ""),
                Accept = "application/vnd.github.v3+json"
            },
            body = vim.fn.json_encode(updates)
        })
        
        if response.status ~= 200 then
            return false, "Failed to update issue: " .. (response.body or "")
        end
        
        return true, vim.fn.json_decode(response.body)
    end,
    
    get_templates = function()
        local templates_dir = current_config.templates_dir
        local templates = {}
        
        if vim.fn.isdirectory(templates_dir) == 1 then
            local files = vim.fn.glob(templates_dir .. "/*.md", false, true)
            for _, file in ipairs(files) do
                local name = vim.fn.fnamemodify(file, ":t:r")
                local content = vim.fn.readfile(file)
                templates[name] = table.concat(content, "\n")
            end
        end
        
        return templates
    end
}

-- Fonctions pour GitLab
local gitlab = {
    create_issue = function(title, body, labels, assignees)
        local owner, repo = get_repo_info()
        if not owner or not repo then
            return false, "Cannot determine repository info"
        end
        
        local project_id = vim.fn.system(string.format("curl --silent '%s/projects/%s%%2F%s' --header 'PRIVATE-TOKEN: %s' | jq .id",
            current_config.gitlab_api_url or default_config.gitlab_api_url,
            owner, repo,
            current_config.gitlab_token or ""
        ))
        
        local url = string.format("%s/projects/%s/issues",
            current_config.gitlab_api_url or default_config.gitlab_api_url,
            project_id
        )
        
        local response = curl.post(url, {
            headers = {
                ["PRIVATE-TOKEN"] = current_config.gitlab_token or ""
            },
            body = vim.fn.json_encode({
                title = title,
                description = body,
                labels = table.concat(labels or {}, ","),
                assignee_ids = assignees
            })
        })
        
        if response.status ~= 201 then
            return false, "Failed to create issue: " .. (response.body or "")
        end
        
        return true, vim.fn.json_decode(response.body)
    end,
    
    list_issues = function(filters)
        local owner, repo = get_repo_info()
        if not owner or not repo then
            return false, "Cannot determine repository info"
        end
        
        local project_id = vim.fn.system(string.format("curl --silent '%s/projects/%s%%2F%s' --header 'PRIVATE-TOKEN: %s' | jq .id",
            current_config.gitlab_api_url or default_config.gitlab_api_url,
            owner, repo,
            current_config.gitlab_token or ""
        ))
        
        local url = string.format("%s/projects/%s/issues",
            current_config.gitlab_api_url or default_config.gitlab_api_url,
            project_id
        )
        
        if filters then
            local params = {}
            for k, v in pairs(filters) do
                table.insert(params, k .. "=" .. v)
            end
            if #params > 0 then
                url = url .. "?" .. table.concat(params, "&")
            end
        end
        
        local response = curl.get(url, {
            headers = {
                ["PRIVATE-TOKEN"] = current_config.gitlab_token or ""
            }
        })
        
        if response.status ~= 200 then
            return false, "Failed to list issues: " .. (response.body or "")
        end
        
        return true, vim.fn.json_decode(response.body)
    end,
    
    update_issue = function(issue_iid, updates)
        local owner, repo = get_repo_info()
        if not owner or not repo then
            return false, "Cannot determine repository info"
        end
        
        local project_id = vim.fn.system(string.format("curl --silent '%s/projects/%s%%2F%s' --header 'PRIVATE-TOKEN: %s' | jq .id",
            current_config.gitlab_api_url or default_config.gitlab_api_url,
            owner, repo,
            current_config.gitlab_token or ""
        ))
        
        local url = string.format("%s/projects/%s/issues/%s",
            current_config.gitlab_api_url or default_config.gitlab_api_url,
            project_id, issue_iid
        )
        
        local response = curl.put(url, {
            headers = {
                ["PRIVATE-TOKEN"] = current_config.gitlab_token or ""
            },
            body = vim.fn.json_encode(updates)
        })
        
        if response.status ~= 200 then
            return false, "Failed to update issue: " .. (response.body or "")
        end
        
        return true, vim.fn.json_decode(response.body)
    end,
    
    get_templates = function()
        local templates_dir = current_config.templates_dir
        local templates = {}
        
        if vim.fn.isdirectory(templates_dir) == 1 then
            local files = vim.fn.glob(templates_dir .. "/*.md", false, true)
            for _, file in ipairs(files) do
                local name = vim.fn.fnamemodify(file, ":t:r")
                local content = vim.fn.readfile(file)
                templates[name] = table.concat(content, "\n")
            end
        end
        
        return templates
    end
}

-- Interface publique
function M.create_issue(title, body, labels, assignees)
    local repo_type = detect_repo_type()
    if repo_type == "github" then
        return github.create_issue(title, body, labels, assignees)
    elseif repo_type == "gitlab" then
        return gitlab.create_issue(title, body, labels, assignees)
    end
    return false, "Unsupported repository type"
end

function M.list_issues(filters)
    local repo_type = detect_repo_type()
    if repo_type == "github" then
        return github.list_issues(filters)
    elseif repo_type == "gitlab" then
        return gitlab.list_issues(filters)
    end
    return false, "Unsupported repository type"
end

function M.update_issue(issue_id, updates)
    local repo_type = detect_repo_type()
    if repo_type == "github" then
        return github.update_issue(issue_id, updates)
    elseif repo_type == "gitlab" then
        return gitlab.update_issue(issue_id, updates)
    end
    return false, "Unsupported repository type"
end

function M.get_templates()
    local repo_type = detect_repo_type()
    if repo_type == "github" then
        return github.get_templates()
    elseif repo_type == "gitlab" then
        return gitlab.get_templates()
    end
    return {}
end

-- Fonction pour lier un commit à une issue
function M.link_commit_to_issue(commit_hash, issue_id)
    local repo_type = detect_repo_type()
    local owner, repo = get_repo_info()
    
    if not owner or not repo then
        return false, "Cannot determine repository info"
    end
    
    local message = string.format("Fixes #%s", issue_id)
    local cmd = string.format("git notes append -m '%s' %s", message, commit_hash)
    
    local success, result = utils.execute_command(cmd)
    if not success then
        return false, "Failed to link commit to issue: " .. result
    end
    
    return true
end

return M
