local assert = require('luassert')
local rebase = require('gitpilot.features.rebase')

describe('rebase', function()
    before_each(function()
        -- Reset rebase configuration before each test
        rebase.setup({})
        -- Ensure we're in test mode
        vim.env.GITPILOT_TEST = "1"
    end)

    describe('start_rebase', function()
        it('should start rebase successfully', function()
            local result = rebase.start_rebase('main')
            assert.is_true(result.success)
            assert.is_nil(result.error)
        end)

        it('should handle empty branch name', function()
            local result = rebase.start_rebase('')
            assert.is_false(result.success)
            assert.equals('rebase.error.no_base', result.error)
        end)

        it('should handle non-existent branch', function()
            vim.env.GITPILOT_TEST_NONEXISTENT = "1"
            local result = rebase.start_rebase('nonexistent')
            assert.is_false(result.success)
            assert.equals('rebase.error.invalid_base', result.error)
            vim.env.GITPILOT_TEST_NONEXISTENT = nil
        end)

        it('should handle conflicts', function()
            vim.env.GITPILOT_TEST_CONFLICTS = "1"
            local result = rebase.start_rebase('main')
            assert.is_false(result.success)
            assert.equals('rebase.error.conflicts', result.error)
            vim.env.GITPILOT_TEST_CONFLICTS = nil
        end)
    end)

    describe('continue_rebase', function()
        it('should continue rebase successfully', function()
            local result = rebase.continue_rebase()
            assert.is_true(result.success)
            assert.is_nil(result.error)
        end)

        it('should handle no rebase in progress', function()
            vim.env.GITPILOT_TEST_NONEXISTENT = "1"
            local result = rebase.continue_rebase()
            assert.is_false(result.success)
            assert.equals('rebase.error.no_rebase', result.error)
            vim.env.GITPILOT_TEST_NONEXISTENT = nil
        end)

        it('should handle unresolved conflicts', function()
            vim.env.GITPILOT_TEST_CONFLICTS = "1"
            local result = rebase.continue_rebase()
            assert.is_false(result.success)
            assert.equals('rebase.error.unresolved', result.error)
            vim.env.GITPILOT_TEST_CONFLICTS = nil
        end)
    end)

    describe('abort_rebase', function()
        it('should abort rebase successfully', function()
            local result = rebase.abort_rebase()
            assert.is_true(result.success)
            assert.is_nil(result.error)
        end)

        it('should handle no rebase in progress', function()
            vim.env.GITPILOT_TEST_NONEXISTENT = "1"
            local result = rebase.abort_rebase()
            assert.is_false(result.success)
            assert.equals('rebase.error.no_rebase', result.error)
            vim.env.GITPILOT_TEST_NONEXISTENT = nil
        end)
    end)

    describe('interactive_rebase', function()
        it('should start interactive rebase successfully', function()
            local result = rebase.interactive_rebase('HEAD~3')
            assert.is_true(result.success)
            assert.is_nil(result.error)
        end)

        it('should handle empty commit reference', function()
            local result = rebase.interactive_rebase('')
            assert.is_false(result.success)
            assert.equals('rebase.error.no_base', result.error)
        end)

        it('should handle invalid commit reference', function()
            vim.env.GITPILOT_TEST_NONEXISTENT = "1"
            local result = rebase.interactive_rebase('invalid')
            assert.is_false(result.success)
            assert.equals('rebase.error.invalid_base', result.error)
            vim.env.GITPILOT_TEST_NONEXISTENT = nil
        end)
    end)
end)
