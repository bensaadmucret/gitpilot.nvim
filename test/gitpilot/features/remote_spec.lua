local assert = require('luassert')
local remote = require('gitpilot.features.remote')
local ui = require('gitpilot.ui')

describe('remote', function()
    before_each(function()
        -- Reset remote state before each test
        remote.setup({test_mode = true})
        -- Ensure we're in test mode
        vim.env.GITPILOT_TEST = "1"
        -- Reset last notification
        vim.notify.last_notification = nil
        -- Reset git response
        vim.env.GIT_RESPONSE = ""
    end)

    describe('list_remotes', function()
        it('should return empty list when no remotes exist', function()
            vim.env.GIT_RESPONSE = ""
            local result = remote.list_remotes()
            assert.same({}, result)
        end)

        it('should parse remotes correctly', function()
            vim.env.GIT_RESPONSE = "origin\thttps://github.com/user/repo.git (fetch)\norigin\thttps://github.com/user/repo.git (push)"
            local result = remote.list_remotes()
            assert.same({
                {name = "origin", url = "https://github.com/user/repo.git"}
            }, result)
        end)
    end)

    describe('add_remote', function()
        it('should add remote successfully', function()
            local inputs = {
                name = "origin",
                url = "https://github.com/user/repo.git"
            }
            local current_input = "name"
            vim.ui.input = function(opts, callback)
                callback(inputs[current_input])
                current_input = "url"
            end
            remote.add_remote()
            assert.is_not_nil(vim.notify.last_notification)
            assert.equals("info", vim.notify.last_notification.level)
            assert.matches("Remote.*added successfully", vim.notify.last_notification.message)
        end)

        it('should handle empty remote name', function()
            vim.ui.input = function(opts, callback)
                callback("")
            end
            remote.add_remote()
            assert.is_not_nil(vim.notify.last_notification)
            assert.equals("error", vim.notify.last_notification.level)
            assert.equals("Remote name cannot be empty", vim.notify.last_notification.message)
        end)

        it('should handle empty remote URL', function()
            local inputs = {
                name = "origin",
                url = ""
            }
            local current_input = "name"
            vim.ui.input = function(opts, callback)
                callback(inputs[current_input])
                current_input = "url"
            end
            remote.add_remote()
            assert.is_not_nil(vim.notify.last_notification)
            assert.equals("error", vim.notify.last_notification.level)
            assert.equals("Remote URL cannot be empty", vim.notify.last_notification.message)
        end)

        it('should handle git errors', function()
            local inputs = {
                name = "origin",
                url = "https://github.com/user/repo.git"
            }
            local current_input = "name"
            vim.ui.input = function(opts, callback)
                callback(inputs[current_input])
                current_input = "url"
            end
            vim.env.GIT_RESPONSE = "fatal: remote origin already exists."
            remote.add_remote()
            assert.is_not_nil(vim.notify.last_notification)
            assert.equals("error", vim.notify.last_notification.level)
            assert.matches("Failed to add remote", vim.notify.last_notification.message)
        end)
    end)

    describe('push_remote', function()
        it('should handle no remotes case', function()
            vim.env.GIT_RESPONSE = ""
            remote.push_remote()
            assert.is_not_nil(vim.notify.last_notification)
            assert.equals("warn", vim.notify.last_notification.level)
            assert.equals("No remotes found", vim.notify.last_notification.message)
        end)

        it('should handle successful push', function()
            vim.env.GIT_RESPONSE = "origin\thttps://github.com/user/repo.git (fetch)\norigin\thttps://github.com/user/repo.git (push)"
            vim.ui.select = function(items, opts, callback)
                callback(items[1])
            end
            remote.push_remote()
            assert.is_not_nil(vim.notify.last_notification)
            assert.equals("info", vim.notify.last_notification.level)
            assert.matches("Successfully pushed to remote", vim.notify.last_notification.message)
        end)

        it('should handle push errors', function()
            vim.env.GIT_RESPONSE = "origin\thttps://github.com/user/repo.git (fetch)\norigin\thttps://github.com/user/repo.git (push)"
            vim.ui.select = function(items, opts, callback)
                callback(items[1])
            end
            vim.env.GIT_RESPONSE = "fatal: The current branch has no upstream branch"
            remote.push_remote()
            assert.is_not_nil(vim.notify.last_notification)
            assert.equals("error", vim.notify.last_notification.level)
            assert.matches("Failed to push to remote", vim.notify.last_notification.message)
        end)
    end)

    describe('pull_remote', function()
        it('should handle no remotes case', function()
            vim.env.GIT_RESPONSE = ""
            remote.pull_remote()
            assert.is_not_nil(vim.notify.last_notification)
            assert.equals("warn", vim.notify.last_notification.level)
            assert.equals("No remotes found", vim.notify.last_notification.message)
        end)

        it('should handle successful pull', function()
            vim.env.GIT_RESPONSE = "origin\thttps://github.com/user/repo.git (fetch)\norigin\thttps://github.com/user/repo.git (push)"
            vim.ui.select = function(items, opts, callback)
                callback(items[1])
            end
            remote.pull_remote()
            assert.is_not_nil(vim.notify.last_notification)
            assert.equals("info", vim.notify.last_notification.level)
            assert.matches("Successfully pulled from remote", vim.notify.last_notification.message)
        end)

        it('should handle pull errors', function()
            vim.env.GIT_RESPONSE = "origin\thttps://github.com/user/repo.git (fetch)\norigin\thttps://github.com/user/repo.git (push)"
            vim.ui.select = function(items, opts, callback)
                callback(items[1])
            end
            vim.env.GIT_RESPONSE = "fatal: couldn't find remote ref"
            remote.pull_remote()
            assert.is_not_nil(vim.notify.last_notification)
            assert.equals("error", vim.notify.last_notification.level)
            assert.matches("Failed to pull from remote", vim.notify.last_notification.message)
        end)
    end)
end)
