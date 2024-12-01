local assert = require('luassert')
local stash = require('gitpilot.features.stash')
local i18n = require('gitpilot.i18n')

describe('stash', function()
    before_each(function()
        -- Reset stash state before each test
        stash.setup({
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
        vim.env.GITPILOT_TEST_NO_RESULTS = nil
    end)

    describe('create_stash', function()
        it('should create stash with message', function()
            local result = stash.create_stash('test stash')
            assert.is_true(result.success)
            assert.equals(i18n.t("stash.create.success"), result.output)
        end)

        it('should create stash without message', function()
            local result = stash.create_stash()
            assert.is_true(result.success)
            assert.equals(i18n.t("stash.create.success"), result.output)
        end)

        it('should handle no changes to stash', function()
            vim.env.GITPILOT_TEST_NO_RESULTS = "1"
            local result = stash.create_stash()
            assert.is_false(result.success)
            assert.equals(i18n.t("stash.error.no_changes"), result.error)
        end)
    end)

    describe('apply_stash', function()
        it('should apply stash successfully', function()
            local result = stash.apply_stash(0)
            assert.is_true(result.success)
            assert.equals(i18n.t("stash.apply.success", { index = 0 }), result.output)
        end)

        it('should handle invalid stash index', function()
            vim.env.GITPILOT_TEST_NONEXISTENT = "1"
            local result = stash.apply_stash(999)
            assert.is_false(result.success)
            assert.equals(i18n.t("stash.error.not_found", { index = 999 }), result.error)
        end)
    end)

    describe('drop_stash', function()
        it('should drop stash successfully', function()
            local result = stash.drop_stash(0)
            assert.is_true(result.success)
            assert.equals(i18n.t("stash.drop.success", { index = 0 }), result.output)
        end)

        it('should handle invalid stash index', function()
            vim.env.GITPILOT_TEST_NONEXISTENT = "1"
            local result = stash.drop_stash(999)
            assert.is_false(result.success)
            assert.equals(i18n.t("stash.error.not_found", { index = 999 }), result.error)
        end)
    end)

    describe('list_stash', function()
        it('should list stashes successfully', function()
            local result = stash.list_stash()
            assert.is_true(result.success)
            assert.is_true(#result.output > 0)
            assert.equals('stash@{0}', result.output[1].ref)
        end)

        it('should handle no stashes', function()
            vim.env.GITPILOT_TEST_NO_RESULTS = "1"
            local result = stash.list_stash()
            assert.is_true(result.success)
            assert.equals(0, #result.output)
        end)
    end)
end)
