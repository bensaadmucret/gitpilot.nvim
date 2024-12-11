-- tests/features/search_spec.lua

local mock_utils = {
    execute_command = function() end,
    escape_string = function(str) return str end
}

local mock_ui = {
    show_error = function() end,
    show_success = function() end
}

-- Mock des dépendances
package.loaded['gitpilot.utils'] = mock_utils
package.loaded['gitpilot.ui'] = mock_ui
package.loaded['vim'] = require('tests.mocks.vim')
package.loaded['gitpilot.i18n'] = {
    t = function(key) return key end
}

-- Import du module à tester
local search = require('gitpilot.features.search')

describe("search", function()
    local original_execute_command

    before_each(function()
        original_execute_command = mock_utils.execute_command
        spy.on(mock_ui, "show_error")
    end)

    after_each(function()
        mock_utils.execute_command = original_execute_command
        mock_ui.show_error:clear()
    end)

    describe("commits", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return false
            end

            local result = search.commits("test")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('search.error.not_git_repo')
        end)

        it("should show error when query is empty", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return false
            end

            local result = search.commits("")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('search.error.empty_query')
        end)

        it("should show error when search fails", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return false
            end

            local result = search.commits("test")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('search.error.commits_failed')
        end)

        it("should return commits when search succeeds", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return true, "abc123 - Test commit (2 days ago) <user>\ndef456 - Another commit (1 day ago) <user>"
            end

            local result = search.commits("test")
            assert.is_true(result)
        end)
    end)

    describe("branches", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return false
            end

            local result = search.branches("test")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('search.error.not_git_repo')
        end)

        it("should show error when query is empty", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return false
            end

            local result = search.branches("")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('search.error.empty_query')
        end)

        it("should show error when search fails", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return false
            end

            local result = search.branches("test")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('search.error.branches_failed')
        end)

        it("should return branches when search succeeds", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return true, "* main\n  feature/test\n  develop"
            end

            local result = search.branches("test")
            assert.is_true(result)
        end)
    end)
end)
