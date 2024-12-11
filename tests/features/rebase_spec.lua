-- tests/features/rebase_spec.lua

local mock_utils = {
    execute_command = function() end,
    escape_string = function(str) return str end
}

local mock_ui = {
    show_error = function() end,
    show_warning = function() end,
    show_success = function() end
}

-- Mock des dépendances
package.loaded['gitpilot.utils'] = mock_utils
package.loaded['gitpilot.ui'] = mock_ui
package.loaded['vim'] = nil  -- On désactive vim pour les tests
package.loaded['gitpilot.i18n'] = {
    t = function(key) return key end
}

-- Import du module à tester
local rebase = require('gitpilot.features.rebase')

describe("rebase", function()
    local original_execute_command

    before_each(function()
        original_execute_command = mock_utils.execute_command
        spy.on(mock_ui, "show_error")
        spy.on(mock_ui, "show_warning")
        spy.on(mock_ui, "show_success")
    end)

    after_each(function()
        mock_utils.execute_command = original_execute_command
        mock_ui.show_error:clear()
        mock_ui.show_warning:clear()
        mock_ui.show_success:clear()
    end)

    describe("start", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return false
            end

            local result = rebase.start()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('rebase.error.not_git_repo')
        end)

        it("should show error when already rebasing", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git rev-parse --git-dir" then
                    return true
                elseif cmd == "test -d .git/rebase-merge -o -d .git/rebase-apply" then
                    return true
                end
                return false
            end

            local result = rebase.start()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('rebase.error.already_rebasing')
        end)

        it("should show warning when there are uncommitted changes", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git rev-parse --git-dir" then
                    return true
                elseif cmd == "test -d .git/rebase-merge -o -d .git/rebase-apply" then
                    return false
                elseif cmd == "git status --porcelain" then
                    return true, " M file.txt"
                end
                return false
            end

            local result = rebase.start()
            assert.is_false(result)
            assert.spy(mock_ui.show_warning).was_called_with('rebase.warning.uncommitted_changes')
        end)

        it("should start rebase successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git rev-parse --git-dir" then
                    return true
                elseif cmd == "test -d .git/rebase-merge -o -d .git/rebase-apply" then
                    return false
                elseif cmd == "git status --porcelain" then
                    return true, ""
                elseif cmd:match("^git log") then
                    return true, "abc123 - First commit (2 days ago) <user>\ndef456 - Second commit (1 day ago) <user>"
                end
                return true
            end

            local result = rebase.start()
            assert.is_true(result)
        end)
    end)

    describe("interactive", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return false
            end

            local result = rebase.interactive()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('rebase.error.not_git_repo')
        end)

        it("should show error when already rebasing", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git rev-parse --git-dir" then
                    return true
                elseif cmd == "test -d .git/rebase-merge -o -d .git/rebase-apply" then
                    return true
                end
                return false
            end

            local result = rebase.interactive()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('rebase.error.already_rebasing')
        end)

        it("should show warning when there are uncommitted changes", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git rev-parse --git-dir" then
                    return true
                elseif cmd == "test -d .git/rebase-merge -o -d .git/rebase-apply" then
                    return false
                elseif cmd == "git status --porcelain" then
                    return true, " M file.txt"
                end
                return false
            end

            local result = rebase.interactive()
            assert.is_false(result)
            assert.spy(mock_ui.show_warning).was_called_with('rebase.warning.uncommitted_changes')
        end)

        it("should start interactive rebase successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git rev-parse --git-dir" then
                    return true
                elseif cmd == "test -d .git/rebase-merge -o -d .git/rebase-apply" then
                    return false
                elseif cmd == "git status --porcelain" then
                    return true, ""
                elseif cmd:match("^git log") then
                    return true, "abc123 - First commit (2 days ago) <user>\ndef456 - Second commit (1 day ago) <user>"
                end
                return true
            end

            local result = rebase.interactive()
            assert.is_true(result)
        end)
    end)
end)
