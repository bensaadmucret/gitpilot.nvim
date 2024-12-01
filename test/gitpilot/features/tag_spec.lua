local assert = require('luassert')
local tag = require('gitpilot.features.tag')
local i18n = require('gitpilot.i18n')

describe('tag', function()
    before_each(function()
        -- Reset tag state before each test
        tag.setup({})
        -- Ensure we're in test mode
        vim.env.GITPILOT_TEST = "1"
        -- Set default language
        i18n.setup({ lang = "en" })
    end)

    describe('create_tag', function()
        it('should create tag successfully', function()
            local result = tag.create_tag('v1.0.0', 'Version 1.0.0')
            assert.is_true(result.success)
            assert.equals(i18n.t("tag.create.success", { name = 'v1.0.0' }), result.output)
        end)

        it('should create tag without message', function()
            local result = tag.create_tag('v1.0.1')
            assert.is_true(result.success)
            assert.equals(i18n.t("tag.create.success", { name = 'v1.0.1' }), result.output)
        end)

        it('should handle empty tag name', function()
            local result = tag.create_tag('')
            assert.is_false(result.success)
            assert.equals(i18n.t("tag.create.invalid_name"), result.error)
        end)

        it('should handle existing tag', function()
            vim.env.GITPILOT_TEST_CONFLICTS = "1"
            local result = tag.create_tag('v1.0.0')
            assert.is_false(result.success)
            assert.equals(i18n.t("tag.error.already_exists", { name = 'v1.0.0' }), result.error)
            vim.env.GITPILOT_TEST_CONFLICTS = nil
        end)
    end)

    describe('delete_tag', function()
        it('should delete tag successfully', function()
            local result = tag.delete_tag('v1.0.0')
            assert.is_true(result.success)
            assert.equals(i18n.t("tag.delete.success", { name = 'v1.0.0' }), result.output)
        end)

        it('should handle empty tag name', function()
            local result = tag.delete_tag('')
            assert.is_false(result.success)
            assert.equals(i18n.t("tag.delete.invalid_name"), result.error)
        end)

        it('should handle non-existent tag', function()
            vim.env.GITPILOT_TEST_NONEXISTENT = "1"
            local result = tag.delete_tag('v999.999.999')
            assert.is_false(result.success)
            assert.equals(i18n.t("tag.error.not_found", { name = 'v999.999.999' }), result.error)
            vim.env.GITPILOT_TEST_NONEXISTENT = nil
        end)
    end)

    describe('push_tags', function()
        it('should push all tags successfully', function()
            local result = tag.push_tags()
            assert.is_true(result.success)
            assert.equals(i18n.t("tag.push.success"), result.output)
        end)

        it('should push specific tag successfully', function()
            local result = tag.push_tags('v1.0.0')
            assert.is_true(result.success)
            assert.equals(i18n.t("tag.push.success"), result.output)
        end)

        it('should handle non-existent tag push', function()
            vim.env.GITPILOT_TEST_NONEXISTENT = "1"
            local result = tag.push_tags('v999.999.999')
            assert.is_false(result.success)
            assert.equals(i18n.t("tag.error.not_found", { name = 'v999.999.999' }), result.error)
            vim.env.GITPILOT_TEST_NONEXISTENT = nil
        end)
    end)

    describe('list_tags', function()
        it('should list tags successfully', function()
            local result = tag.list_tags()
            assert.is_true(result.success)
            assert.is_table(result.output)
            assert.equals(2, #result.output)
            -- Verify structure of returned tags
            for _, tag_item in ipairs(result.output) do
                assert.is_string(tag_item.name)
                assert.is_string(tag_item.hash)
                assert.is_string(tag_item.message)
            end
        end)

        it('should handle no tags', function()
            vim.env.GITPILOT_TEST_NO_RESULTS = "1"
            local result = tag.list_tags()
            assert.is_true(result.success)
            assert.equals(0, #result.output)
            vim.env.GITPILOT_TEST_NO_RESULTS = nil
        end)
    end)
end)
