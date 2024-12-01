local M = {}
local fn = vim.fn
local uv = vim.loop

-- Configuration locale
local config = {
    git = {
        cmd = "git",
        timeout = 5000,
        test_mode = false
    }
}

-- Liste des commandes git autorisées
local allowed_commands = {
    ["status"] = true,
    ["add"] = true,
    ["commit"] = true,
    ["branch"] = true,
    ["checkout"] = true,
    ["merge"] = true,
    ["push"] = true,
    ["pull"] = true,
    ["fetch"] = true,
    ["tag"] = true,
    ["stash"] = true,
    ["rebase"] = true,
    ["remote"] = true,
    ["log"] = true,
    ["diff"] = true,
    ["reset"] = true,
    ["rev-parse"] = true,
    ["--version"] = true
}

-- Setup function
M.setup = function(opts)
    if opts then
        config = vim.tbl_deep_extend('force', config, opts or {})
    end
end

-- Git command with error handling
M.git_command = function(command)
    -- Validate input
    if type(command) ~= "string" then
        return false, "Command must be a string"
    end

    if config.git.test_mode then
        -- In test mode, return GIT_RESPONSE from environment
        local response = vim.env.GIT_RESPONSE or ""
        if response:match("^fatal:") or response:match("^error:") then
            return false, response
        end
        return true, response
    end

    -- Check if command is allowed
    local cmd_name = command:match("^(%S+)")
    if not cmd_name then
        return false, "Invalid command format"
    end

    if not allowed_commands[cmd_name] then
        return false, "Command not allowed: " .. cmd_name
    end

    -- Execute git command
    local full_cmd = config.git.cmd .. " " .. command
    local output = fn.system(full_cmd)
    local shell_error = fn.v:shell_error
    local success = shell_error == 0

    if not success then
        return false, output
    end
    return true, output
end

-- Get git version
M.get_git_version = function()
    local success, output = M.git_command("--version")
    if not success then
        return nil, output
    end
    local version = output:match("git version ([%d%.]+)")
    if not version then
        return nil, "Could not parse git version"
    end
    return version
end

-- Check if path is git repository
M.is_git_repo = function()
    local success, _ = M.git_command("rev-parse --git-dir")
    return success
end

-- Get current branch
M.get_current_branch = function()
    local success, output = M.git_command("branch --show-current")
    if not success then
        return nil, output
    end
    return vim.trim(output)
end

-- Get all branches
M.get_branches = function()
    local success, output = M.git_command("branch")
    if not success then
        return nil, output
    end
    
    local branches = {}
    for branch in output:gmatch("[%s*]+([^%s]+)") do
        table.insert(branches, branch)
    end
    return branches
end

-- Get all remotes
M.get_remotes = function()
    local success, output = M.git_command("remote")
    if not success then
        return nil, output
    end
    
    local remotes = {}
    for remote in output:gmatch("[^%s]+") do
        table.insert(remotes, remote)
    end
    return remotes
end

-- Get status
M.get_status = function()
    local success, output = M.git_command("status --porcelain")
    if not success then
        return nil, output
    end
    return output
end

return M
