local assert = require('luassert')
local remote = require('gitpilot.features.remote')

describe('remote', function()
    before_each(function()
        -- Reset remote state before each test
        remote.setup({})
        -- Ensure we're in test mode
        vim.env.GITPILOT_TEST = "1"
    end)

    describe('add_remote', function()
        it('should add remote successfully', function()
            local result = remote.add_remote('origin', 'https://github.com/user/repo.git')
            assert.is_true(result.success)
            assert.matches("Remote added successfully", result.output)
        end)

        it('should handle empty remote name', function()
            local result = remote.add_remote('', 'https://github.com/user/repo.git')
            assert.is_false(result.success)
            assert.matches("Remote name cannot be empty", result.error)
        end)

        it('should handle empty remote URL', function()
            local result = remote.add_remote('origin', '')
            assert.is_false(result.success)
            assert.matches("Remote URL cannot be empty", result.error)
        end)

        it('should handle existing remote', function()
            -- First addition should succeed
            remote.add_remote('origin', 'https://github.com/user/repo.git')
            -- Second addition should fail
            local result = remote.add_remote('origin', 'https://github.com/user/other.git')
            assert.is_false(result.success)
            assert.matches("Remote 'origin' already exists", result.error)
        end)
    end)

    describe('remove_remote', function()
        it('should remove remote successfully', function()
            -- First add a remote
            remote.add_remote('origin', 'https://github.com/user/repo.git')
            -- Then remove it
            local result = remote.remove_remote('origin')
            assert.is_true(result.success)
            assert.matches("Remote removed successfully", result.output)
        end)

        it('should handle empty remote name', function()
            local result = remote.remove_remote('')
            assert.is_false(result.success)
            assert.matches("Remote name cannot be empty", result.error)
        end)

        it('should handle non-existent remote', function()
            local result = remote.remove_remote('nonexistent')
            assert.is_false(result.success)
            assert.matches("Remote 'nonexistent' does not exist", result.error)
        end)
    end)

    describe('push', function()
        it('should push changes successfully', function()
            local result = remote.push('origin', 'main')
            assert.is_true(result.success)
            assert.matches("Changes pushed successfully", result.output)
        end)

        it('should handle force push', function()
            local result = remote.push('origin', 'main', { force = true })
            assert.is_true(result.success)
            assert.matches("Changes force pushed successfully", result.output)
        end)

        it('should handle empty remote name', function()
            local result = remote.push('', 'main')
            assert.is_false(result.success)
            assert.matches("Remote name cannot be empty", result.error)
        end)

        it('should handle empty branch name', function()
            local result = remote.push('origin', '')
            assert.is_false(result.success)
            assert.matches("Branch name cannot be empty", result.error)
        end)
    end)

    describe('pull', function()
        it('should pull changes successfully', function()
            local result = remote.pull('origin', 'main')
            assert.is_true(result.success)
            assert.matches("Changes pulled successfully", result.output)
        end)

        it('should handle empty remote name', function()
            local result = remote.pull('', 'main')
            assert.is_false(result.success)
            assert.matches("Remote name cannot be empty", result.error)
        end)

        it('should handle empty branch name', function()
            local result = remote.pull('origin', '')
            assert.is_false(result.success)
            assert.matches("Branch name cannot be empty", result.error)
        end)

        it('should handle conflicts', function()
            -- Simulate conflicts in test mode
            vim.env.GITPILOT_TEST_CONFLICTS = "1"
            local result = remote.pull('origin', 'main')
            assert.is_false(result.success)
            assert.matches("Merge conflicts detected", result.error)
            vim.env.GITPILOT_TEST_CONFLICTS = nil
        end)
    end)
end)
