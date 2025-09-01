local M = {}
local utils = require('gitpilot.utils')
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')

-- Get the repository owner and name from the remote URL
local function get_repo_info()
    local success, remote_url = utils.execute_command("git config --get remote.origin.url")
    if not success then
        return nil, nil
    end

    local owner, repo = remote_url:match("github.com[/:]([^/]+)/([^/]+)%.git")
    return owner, repo
end

function M.get_pull_requests(callback)
    local owner, repo = get_repo_info()
    if not owner or not repo then
        ui.show_error(i18n.t("pull_request.error.no_repo_info"))
        callback({})
        return
    end

    local url = string.format("https://api.github.com/repos/%s/%s/pulls", owner, repo)
    local cmd = string.format("curl -s %s", url)

    utils.execute_command_async(cmd, function(success, output)
        if not success then
            ui.show_error(i18n.t("pull_request.error.fetch_failed"))
            callback({})
            return
        end

        local ok, prs = pcall(vim.json.decode, output)
        if not ok then
            ui.show_error(i18n.t("pull_request.error.parse_failed"))
            callback({})
            return
        end

        callback(prs)
    end)
end

function M.setup(opts)
    -- TODO: Add setup logic
end

return M
