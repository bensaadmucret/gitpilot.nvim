local assert = require('luassert')
local search = require('gitpilot.features.search')

describe('search', function()
    before_each(function()
        -- Reset search state before each test
        search.setup({})
        -- Ensure we're in test mode
        vim.env.GITPILOT_TEST = "1"
    end)

    describe('search_commits', function()
        it('should search commits successfully', function()
            local result = search.search_commits('feat: add new feature')
            assert.is_true(result.success)
            assert.is_table(result.commits)
            assert.is_true(#result.commits > 0)
        end)

        it('should handle empty search term', function()
            local result = search.search_commits('')
            assert.is_false(result.success)
            assert.matches("Search term cannot be empty", result.error)
        end)

        it('should handle no results', function()
            -- Simulate no results in test mode
            vim.env.GITPILOT_TEST_NO_RESULTS = "1"
            local result = search.search_commits('nonexistent')
            assert.is_true(result.success)
            assert.equals(0, #result.commits)
            vim.env.GITPILOT_TEST_NO_RESULTS = nil
        end)
    end)

    describe('search_files', function()
        it('should search files successfully', function()
            local result = search.search_files('*.lua')
            assert.is_true(result.success)
            assert.is_table(result.files)
            assert.is_true(#result.files > 0)
        end)

        it('should handle empty pattern', function()
            local result = search.search_files('')
            assert.is_false(result.success)
            assert.matches("Search pattern cannot be empty", result.error)
        end)

        it('should handle no results', function()
            -- Simulate no results in test mode
            vim.env.GITPILOT_TEST_NO_RESULTS = "1"
            local result = search.search_files('nonexistent')
            assert.is_true(result.success)
            assert.equals(0, #result.files)
            vim.env.GITPILOT_TEST_NO_RESULTS = nil
        end)
    end)

    describe('search_by_author', function()
        it('should search by author successfully', function()
            local result = search.search_by_author('John Doe')
            assert.is_true(result.success)
            assert.is_table(result.commits)
            assert.is_true(#result.commits > 0)
        end)

        it('should handle empty author name', function()
            local result = search.search_by_author('')
            assert.is_false(result.success)
            assert.matches("Author name cannot be empty", result.error)
        end)

        it('should handle no commits by author', function()
            -- Simulate no results in test mode
            vim.env.GITPILOT_TEST_NO_RESULTS = "1"
            local result = search.search_by_author('Unknown Author')
            assert.is_true(result.success)
            assert.equals(0, #result.commits)
            vim.env.GITPILOT_TEST_NO_RESULTS = nil
        end)
    end)

    describe('search_branches', function()
        it('should search branches successfully', function()
            local result = search.search_branches('feature/')
            assert.is_true(result.success)
            assert.is_table(result.branches)
            assert.is_true(#result.branches > 0)
        end)

        it('should handle empty pattern', function()
            local result = search.search_branches('')
            assert.is_false(result.success)
            assert.matches("Search pattern cannot be empty", result.error)
        end)

        it('should handle no matching branches', function()
            -- Simulate no results in test mode
            vim.env.GITPILOT_TEST_NO_RESULTS = "1"
            local result = search.search_branches('nonexistent')
            assert.is_true(result.success)
            assert.equals(0, #result.branches)
            vim.env.GITPILOT_TEST_NO_RESULTS = nil
        end)
    end)
end)
