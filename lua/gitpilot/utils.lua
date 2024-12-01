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
    ["--version"] = true
}

-- Setup function
M.setup = function(opts)
    config = vim.tbl_deep_extend('force', config, opts or {})
end

-- Git command with error handling
M.git_command = function(command)
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
    if not allowed_commands[cmd_name] then
        return false, "Command not allowed: " .. cmd_name
    end

    -- Execute git command
    local full_cmd = config.git.cmd .. " " .. command
    local output = fn.system(full_cmd)
    local success = fn.v:shell_error == 0

    if not success then
        return false, output
    end
    return true, output
end

-- Get git version
M.get_git_version = function()
    local success, output = M.git_command("--version")
    if not success then
        return nil
    end
    return output:match("git version ([%d%.]+)")
end

-- Check if path is in a git repository
M.is_git_repo = function()
    local success = M.git_command("rev-parse --is-inside-work-tree")
    return success
end

-- Get current branch
M.get_current_branch = function()
    local success, output = M.git_command("branch --show-current")
    if not success then
        return nil
    end
    return output:gsub("\n", "")
end

-- Get repository root
M.get_repo_root = function()
    local success, output = M.git_command("rev-parse --show-toplevel")
    if not success then
        return nil
    end
    return output:gsub("\n", "")
end

-- Get file status
M.get_file_status = function(file)
    if not file or file == "" then
        return nil, "File path cannot be empty"
    end
    
    local success, output = M.git_command("status --porcelain " .. file)
    if not success then
        return nil, output
    end
    
    if output == "" then
        return "unmodified"
    end
    
    local status = output:sub(1, 2)
    if status:match("M") then
        return "modified"
    elseif status:match("A") then
        return "added"
    elseif status:match("D") then
        return "deleted"
    elseif status:match("R") then
        return "renamed"
    elseif status:match("C") then
        return "copied"
    elseif status:match("U") then
        return "updated"
    elseif status:match("%?%?") then
        return "untracked"
    else
        return "unknown"
    end
end

return M
