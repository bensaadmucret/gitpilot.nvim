-- tests/features/stash_spec.lua

-- Mock des dépendances
local mock_ui = {
    show_error = function() end,
    show_success = function() end,
    input = function() end,
    select = function() end,
    show_preview = function() end
}

local mock_utils = {
    execute_command = function() end,
    escape_string = function(str) return str end
}

local mock_i18n = {
    t = function(key) return key end
}

-- Mock de vim
_G.vim = {
    tbl_deep_extend = function(mode, tbl1, tbl2)
        for k, v in pairs(tbl2) do
            tbl1[k] = v
        end
        return tbl1
    end,
    tbl_contains = function(list, value)
        for i, v in ipairs(list) do
            if v == value then
                return i
            end
        end
        return false
    end
}

-- Configuration des mocks
package.loaded['gitpilot.ui'] = mock_ui
package.loaded['gitpilot.utils'] = mock_utils
package.loaded['gitpilot.i18n'] = mock_i18n

-- Import du module à tester
local stash = require('gitpilot.features.stash')

describe("stash", function()
    local original_execute_command

    before_each(function()
        -- Réinitialisation des spies avant chaque test
        spy.on(mock_ui, "show_error")
        spy.on(mock_ui, "show_success")
        spy.on(mock_ui, "input")
        spy.on(mock_ui, "select")
        spy.on(mock_ui, "show_preview")
        original_execute_command = mock_utils.execute_command
    end)

    after_each(function()
        -- Nettoyage des spies après chaque test
        mock_ui.show_error:revert()
        mock_ui.show_success:revert()
        mock_ui.input:revert()
        mock_ui.select:revert()
        mock_ui.show_preview:revert()
        mock_utils.execute_command = original_execute_command
    end)

    describe("list", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = stash.list()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('stash.error.not_git_repo')
        end)

        it("should show error when listing fails", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git stash list") then
                    return false
                end
                return false
            end

            local result = stash.list()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('stash.error.list_failed')
        end)

        it("should show error when no stashes exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git stash list") then
                    return true, ""
                end
                return false
            end

            local result = stash.list()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('stash.error.no_stashes')
        end)

        it("should list stashes successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git stash list") then
                    return true, "stash@{0} - WIP on main\nstash@{1} - feature work"
                end
                return false
            end

            local result = stash.list()
            assert.is_true(result)
            assert.spy(mock_ui.select).was_called()
        end)
    end)

    describe("save", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = stash.save()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('stash.error.not_git_repo')
        end)

        it("should show error when no changes to stash", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" then
                    return true, ""
                end
                return false
            end

            local result = stash.save()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('stash.error.no_changes')
        end)

        it("should save stash successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" then
                    return true, "M file.txt"
                elseif cmd:match("^git stash push") then
                    return true
                end
                return false
            end

            local result = stash.save("test message")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('stash.success.saved')
        end)
    end)

    describe("pop", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = stash.pop("stash@{0}")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('stash.error.not_git_repo')
        end)

        it("should show error when stash does not exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return false
                end
                return false
            end

            local result = stash.pop("invalid")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('stash.error.invalid_stash')
        end)

        it("should pop stash successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return true
                elseif cmd:match("^git stash pop") then
                    return true
                end
                return false
            end

            local result = stash.pop("stash@{0}")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('stash.success.popped')
        end)
    end)

    describe("apply", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = stash.apply("stash@{0}")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('stash.error.not_git_repo')
        end)

        it("should show error when stash does not exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return false
                end
                return false
            end

            local result = stash.apply("invalid")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('stash.error.invalid_stash')
        end)

        it("should show error when apply fails", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return true
                elseif cmd:match("^git stash apply") then
                    return false
                end
                return false
            end

            local result = stash.apply("stash@{0}")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('stash.error.apply_failed')
        end)

        it("should apply stash successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return true
                elseif cmd:match("^git stash apply") then
                    return true
                end
                return false
            end

            local result = stash.apply("stash@{0}")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('stash.success.applied')
        end)
    end)

    describe("show", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = stash.show("stash@{0}")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('stash.error.not_git_repo')
        end)

        it("should show error when stash does not exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return false
                end
                return false
            end

            local result = stash.show("invalid")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('stash.error.invalid_stash')
        end)

        it("should show error when show command fails", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return true
                elseif cmd:match("^git stash show") then
                    return false
                end
                return false
            end

            local result = stash.show("stash@{0}")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('stash.error.show_failed')
        end)

        it("should show stash details successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return true
                elseif cmd:match("^git stash show") then
                    return true, "Modified: file.txt\n+1 -1"
                end
                return false
            end

            local result = stash.show("stash@{0}")
            assert.is_true(result)
            assert.spy(mock_ui.show_preview).was_called()
        end)
    end)

    describe("clear", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = stash.clear()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('stash.error.not_git_repo')
        end)

        it("should show error when clear fails", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git stash clear" then
                    return false
                end
                return false
            end

            local result = stash.clear()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('stash.error.clear_failed')
        end)

        it("should clear all stashes successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git stash clear" then
                    return true
                end
                return false
            end

            local result = stash.clear()
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('stash.success.cleared')
        end)
    end)

    describe("drop", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = stash.drop("stash@{0}")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('stash.error.not_git_repo')
        end)

        it("should show error when stash does not exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return false
                end
                return false
            end

            local result = stash.drop("invalid")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('stash.error.invalid_stash')
        end)

        it("should drop stash successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return true
                elseif cmd:match("^git stash drop") then
                    return true
                end
                return false
            end

            local result = stash.drop("stash@{0}")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('stash.success.dropped')
        end)
    end)
end)
