local assert = require('luassert')
local branch = require('gitpilot.features.branch')
local i18n = require('gitpilot.i18n')

describe('branch', function()
    before_each(function()
        -- Reset branch state before each test
        branch.setup({
            git_cmd = 'git',
            timeout = 5000,
            test_mode = true
        })
        -- Ensure we're in test mode
        vim.env.GITPILOT_TEST = "1"
        -- Set default language
        i18n.setup({ lang = "en" })
    end)

    after_each(function()
        -- Clean up environment variables
        vim.env.GITPILOT_TEST = nil
        vim.env.GITPILOT_TEST_CONFLICTS = nil
        vim.env.GITPILOT_TEST_NONEXISTENT = nil
    end)

    describe('create_branch', function()
        it('should handle empty branch name', function()
            local result = branch.create_branch('')
            assert.is_false(result.success)
            assert.equals(i18n.t("branch.create.invalid_name"), result.error)
        end)

        it('should handle nil branch name', function()
            local result = branch.create_branch(nil)
            assert.is_false(result.success)
            assert.equals(i18n.t("branch.create.invalid_name"), result.error)
        end)

        it('should create branch successfully', function()
            local result = branch.create_branch('feature/test')
            assert.is_true(result.success)
            assert.equals(i18n.t("branch.create.success", { name = 'feature/test' }), result.output)
        end)

        it('should handle existing branch', function()
            vim.env.GITPILOT_TEST_CONFLICTS = "1"
            local result = branch.create_branch('feature/test')
            assert.is_false(result.success)
            assert.equals(i18n.t("branch.error.already_exists", { name = 'feature/test' }), result.error)
        end)
    end)

    describe('delete_branch', function()
        it('should handle empty branch name', function()
            local result = branch.delete_branch('')
            assert.is_false(result.success)
            assert.equals(i18n.t("branch.delete.invalid_name"), result.error)
        end)

        it('should handle nil branch name', function()
            local result = branch.delete_branch(nil)
            assert.is_false(result.success)
            assert.equals(i18n.t("branch.delete.invalid_name"), result.error)
        end)

        it('should delete branch successfully', function()
            local result = branch.delete_branch('feature/test')
            assert.is_true(result.success)
            assert.equals(i18n.t("branch.delete.success", { name = 'feature/test' }), result.output)
        end)

        it('should handle non-existent branch', function()
            vim.env.GITPILOT_TEST_NONEXISTENT = "1"
            local result = branch.delete_branch('feature/nonexistent')
            assert.is_false(result.success)
            assert.equals(i18n.t("branch.error.not_found", { name = 'feature/nonexistent' }), result.error)
        end)
    end)

    describe('switch_branch', function()
        it('should handle empty branch name', function()
            local result = branch.switch_branch('')
            assert.is_false(result.success)
            assert.equals(i18n.t("branch.switch.invalid_name"), result.error)
        end)

        it('should handle nil branch name', function()
            local result = branch.switch_branch(nil)
            assert.is_false(result.success)
            assert.equals(i18n.t("branch.switch.invalid_name"), result.error)
        end)

        it('should switch branch successfully', function()
            -- First create a branch
            branch.create_branch('feature/test-switch')
            -- Then switch to it
            local result = branch.switch_branch('feature/test-switch')
            assert.is_true(result.success)
            assert.equals(i18n.t("branch.switch.success", { name = 'feature/test-switch' }), result.output)
        end)

        it('should handle non-existent branch', function()
            vim.env.GITPILOT_TEST_NONEXISTENT = "1"
            local result = branch.switch_branch('feature/nonexistent')
            assert.is_false(result.success)
            assert.equals(i18n.t("branch.error.not_found", { name = 'feature/nonexistent' }), result.error)
        end)
    end)
end)
