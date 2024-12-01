-- Load test helpers
local helpers = require('test.helpers')

-- Set up test environment
helpers.setup()

-- Load minimal init
require('test.minimal_init')

-- Set up test mode
vim.env.GITPILOT_TEST = "1"

-- Set up test path
local plugin_root = vim.fn.getcwd()
vim.opt.runtimepath:append(plugin_root)

-- Set up test UI
vim.ui = {
    input = function(opts, callback)
        if callback then
            callback("")
        end
        return ""
    end,
    select = function(items, opts, callback)
        if callback then
            callback(items[1])
        end
    end
}

-- Set up test notification
vim.notify = function(msg, level, opts)
    vim.notify.last_notification = {
        message = msg,
        level = level,
        opts = opts
    }
end

-- Set up test git response
vim.env.GIT_RESPONSE = vim.env.GIT_RESPONSE or ""

-- Set up test utils
_G.assert = require('luassert')
_G.match = require('luassert.match')
_G.spy = require('luassert.spy')
_G.stub = require('luassert.stub')

-- Set up before_each hook
before_each(function()
    helpers.reset()
    vim.env.GIT_RESPONSE = ""
    vim.notify.last_notification = nil
end)

-- Set up after_each hook
after_each(function()
    helpers.reset()
end)

-- Mock core modules first
package.loaded['gitpilot.ui'] = {
    notify = function(msg, level)
        package.loaded['gitpilot.ui'].last_notification = {
            message = msg,
            level = level or "info"
        }
    end,
    prompt = function() return true end,
    select = function(_, _, callback) 
        if callback then callback(1) end
        return 1 
    end,
    create_window = function() return true end,
    close_window = function() end,
    input = function(opts, callback)
        if callback then
            callback("test-input")
        end
        return "test-input"
    end,
    last_notification = nil
}

-- Mock gitpilot.i18n module
package.loaded['gitpilot.i18n'] = {
    t = function(key) return key end
}

-- Mock gitpilot.utils module with proper git_command_with_error implementation
package.loaded['gitpilot.utils'] = {
    setup = function() end,
    git_command = function() return "" end,
    git_command_with_error = function(command)
        local output = vim.fn.system(command)
        return true, output
    end,
    file_exists = function() return true end,
    get_file_status = function() return { status = "M" } end,
    config = {
        git = {
            cmd = "git"
        }
    }
}

-- Mock git features with proper return values
local function create_mock_git_feature(name)
    local feature = {
        setup = function() end,
        -- Remote operations
        list_remotes = function() return {} end,
        add_remote = function(name, url) 
            if not name or name == "" then
                return { success = false, error = "Remote name cannot be empty" }
            end
            if not url or url == "" then
                return { success = false, error = "Remote URL cannot be empty" }
            end
            return { success = true, output = "Remote added successfully" }
        end,
        remove_remote = function(name)
            if not name or name == "" then
                return { success = false, error = "Remote name cannot be empty" }
            end
            return { success = true, output = "Remote removed successfully" }
        end,
        push = function(remote, branch, force)
            if not remote or remote == "" then
                return { success = false, error = "Remote name cannot be empty" }
            end
            if not branch or branch == "" then
                return { success = false, error = "Branch name cannot be empty" }
            end
            return { success = true, output = force and "Force pushed successfully" or "Pushed successfully" }
        end,
        pull = function(remote, branch)
            if not remote or remote == "" then
                return { success = false, error = "Remote name cannot be empty" }
            end
            if not branch or branch == "" then
                return { success = false, error = "Branch name cannot be empty" }
            end
            return { success = true, output = "Pulled successfully" }
        end,
        fetch = function(remote)
            if not remote or remote == "" then
                return { success = false, error = "Remote name cannot be empty" }
            end
            return { success = true, output = "Fetched successfully" }
        end,

        -- Search operations
        search_commits = function(term)
            if not term or term == "" then
                return { success = false, error = "Search term cannot be empty" }
            end
            return { success = true, commits = {} }
        end,
        search_files = function(pattern)
            if not pattern or pattern == "" then
                return { success = false, error = "Search pattern cannot be empty" }
            end
            return { success = true, files = {} }
        end,
        search_by_author = function(author)
            if not author or author == "" then
                return { success = false, error = "Author name cannot be empty" }
            end
            return { success = true, commits = {} }
        end,
        search_branches = function(pattern)
            if not pattern or pattern == "" then
                return { success = false, error = "Search pattern cannot be empty" }
            end
            return { success = true, branches = {} }
        end,

        -- Stash operations
        setup = function() end,
        create_stash = function(message)
            if not message or message == "" then
                return { success = false, error = "Stash message cannot be empty" }
            end
            return { success = true, stash_id = "stash@{0}", output = "Changes stashed successfully" }
        end,
        apply_stash = function(stash_id)
            if not stash_id or stash_id == "" then
                return { success = false, error = "Invalid stash ID" }
            end
            return { success = true, output = "Stash applied successfully" }
        end,
        drop_stash = function(stash_id)
            if not stash_id or stash_id == "" then
                return { success = false, error = "Invalid stash ID" }
            end
            return { success = true, output = "Stash dropped successfully" }
        end,
        list_stash = function()
            return { success = true, stashes = {}, output = "No stashes found" }
        end,

        -- Rebase operations
        start_rebase = function(branch)
            if not branch or branch == "" then
                return { success = false, error = "rebase.error.no_base" }
            end
            return { success = true, output = "Rebase started successfully" }
        end,
        continue_rebase = function()
            return { success = true, output = "Rebase continued successfully" }
        end,
        abort_rebase = function()
            return { success = true, output = "Rebase aborted successfully" }
        end,
        interactive_rebase = function(commit)
            if not commit or commit == "" then
                return { success = false, error = "rebase.error.no_base" }
            end
            return { success = true, output = "Interactive rebase started successfully" }
        end,

        -- Conflict operations
        find_conflicts = function()
            return { success = true, conflicts = {} }
        end,
        show_diff = function(file)
            if not file or file == "" then
                return { success = false, error = "conflict.messages.no_conflicts" }
            end
            return { success = true, output = "Diff shown successfully" }
        end,
        resolve_conflict = function(file, strategy)
            if not file or file == "" or not strategy then
                return { success = false, error = "conflict.messages.resolve_error" }
            end
            return { success = true, output = "Conflict resolved successfully" }
        end,
        show_history = function()
            return { success = true, history = {}, output = "History shown successfully" }
        end,

        -- Branch operations
        setup = function() end,
        create_branch = function(name)
            if not name or name == "" then
                return { success = false, error = "Branch name cannot be empty" }
            end
            return { success = true, output = "Branch created successfully" }
        end,
        delete_branch = function(name)
            if not name or name == "" then
                return { success = false, error = "Branch name cannot be empty" }
            end
            return { success = true, output = "Branch deleted successfully" }
        end,
        switch_branch = function(name)
            if not name or name == "" then
                return { success = false, error = "Branch name cannot be empty" }
            end
            return { success = true, output = "Switched to branch successfully" }
        end,
        merge_branch = function(name)
            if not name or name == "" then
                return { success = false, error = "Branch name cannot be empty" }
            end
            return { success = true, output = "Branch merged successfully" }
        end,
        list_branches = function()
            return { success = true, branches = {}, output = "No branches found" }
        end,
        rename_branch = function(old_name, new_name)
            if not old_name or old_name == "" or not new_name or new_name == "" then
                return { success = false, error = "Branch name cannot be empty" }
            end
            return { success = true, output = "Branch renamed successfully" }
        end,
        get_current_branch = function()
            return { success = true, branch = "main", output = "Current branch retrieved" }
        end,
        has_upstream = function(branch)
            if not branch or branch == "" then
                return { success = false, error = "Branch name cannot be empty" }
            end
            return { success = true, output = "Branch has upstream" }
        end,
        set_upstream = function(branch, remote)
            if not branch or branch == "" or not remote or remote == "" then
                return { success = false, error = "Invalid arguments" }
            end
            return { success = true, output = "Upstream set successfully" }
        end,
        unset_upstream = function(branch)
            if not branch or branch == "" then
                return { success = false, error = "Branch name cannot be empty" }
            end
            return { success = true, output = "Upstream unset successfully" }
        end,
        get_upstream = function(branch)
            if not branch or branch == "" then
                return { success = false, error = "Branch name cannot be empty" }
            end
            return { success = true, upstream = "origin/main", output = "Upstream retrieved" }
        end,

        -- Tag operations
        setup = function() end,
        create_tag = function(name, message)
            if not name or name == "" then
                return { success = false, error = "Tag name cannot be empty" }
            end
            return { success = true, output = "Tag created successfully" }
        end,
        delete_tag = function(name)
            if not name or name == "" then
                return { success = false, error = "Tag name cannot be empty" }
            end
            return { success = true, output = "Tag deleted successfully" }
        end,
        list_tags = function()
            return { success = true, tags = {}, output = "No tags found" }
        end,
        push_tag = function(name, remote)
            if not name or name == "" or not remote or remote == "" then
                return { success = false, error = "Invalid arguments" }
            end
            return { success = true, output = "Tag pushed successfully" }
        end
    }
    package.loaded['gitpilot.features.' .. name] = feature
    return feature
end

-- Create mock features
local features = {'remote', 'search', 'stash', 'rebase', 'conflict', 'branch', 'tag'}
for _, name in ipairs(features) do
    create_mock_git_feature(name)
end

-- Ajoute le chemin de recherche pour les modules
package.path = "./?.lua;./lua/?.lua;./lua/?/init.lua;" .. package.path
