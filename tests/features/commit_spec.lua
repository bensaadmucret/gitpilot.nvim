-- tests/features/commit_spec.lua

-- Mock des dépendances
local mock_ui = {
    show_error = function() end,
    show_success = function() end,
    input = function() end,
    select = function() end
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
    end
}

-- Configuration des mocks
package.loaded['gitpilot.ui'] = mock_ui
package.loaded['gitpilot.utils'] = mock_utils
package.loaded['gitpilot.i18n'] = mock_i18n

-- Import du module à tester
local commit = require('gitpilot.features.commit')

describe("commit", function()
    local original_execute_command

    before_each(function()
        -- Réinitialisation des spies avant chaque test
        spy.on(mock_ui, "show_error")
        spy.on(mock_ui, "show_success")
        spy.on(mock_ui, "input")
        spy.on(mock_ui, "select")
        original_execute_command = mock_utils.execute_command
    end)

    after_each(function()
        -- Nettoyage des spies après chaque test
        mock_ui.show_error:revert()
        mock_ui.show_success:revert()
        mock_ui.input:revert()
        mock_ui.select:revert()
        mock_utils.execute_command = original_execute_command
    end)

    describe("create_commit", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = commit.create_commit()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('commit.error.not_git_repo')
        end)

        it("should show error when no changes to commit", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" then
                    return true, ""
                end
                return false
            end

            local result = commit.create_commit()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('commit.error.no_changes')
        end)

        it("should create commit successfully with builtin editor", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" then
                    return true, "M file.txt"
                elseif cmd:match("^git commit %-m") then
                    return true
                end
                return false
            end

            commit.setup({ commit_editor = "builtin" })
            local result = commit.create_commit()
            assert.is_true(result)
            assert.spy(mock_ui.input).was_called()
        end)
    end)

    describe("amend_commit", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = commit.amend_commit()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('commit.error.not_git_repo')
        end)

        it("should show error when no commits exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git rev-parse HEAD" then
                    return false
                end
                return false
            end

            local result = commit.amend_commit()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('commit.error.no_commits')
        end)

        it("should amend commit successfully with builtin editor", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git rev-parse HEAD" then
                    return true
                elseif cmd == "git log -1 --pretty=%B" then
                    return true, "previous message"
                elseif cmd:match("^git commit %-%-amend %-m") then
                    return true
                end
                return false
            end

            commit.setup({ commit_editor = "builtin" })
            local result = commit.amend_commit()
            assert.is_true(result)
            assert.spy(mock_ui.input).was_called()
        end)
    end)

    describe("fixup_commit", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = commit.fixup_commit("abc123")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('commit.error.not_git_repo')
        end)

        it("should show error when commit does not exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return false
                end
                return false
            end

            local result = commit.fixup_commit("invalid")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('commit.error.invalid_commit')
        end)

        it("should show error when no changes to commit", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return true
                elseif cmd == "git status --porcelain" then
                    return true, ""
                end
                return false
            end

            local result = commit.fixup_commit("abc123")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('commit.error.no_changes')
        end)

        it("should fixup commit successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return true
                elseif cmd == "git status --porcelain" then
                    return true, "M file.txt"
                elseif cmd:match("^git commit %-%-fixup") then
                    return true
                end
                return false
            end

            local result = commit.fixup_commit("abc123")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('commit.success.fixup')
        end)
    end)

    describe("revert_commit", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = commit.revert_commit("abc123")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('commit.error.not_git_repo')
        end)

        it("should show error when commit does not exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return false
                end
                return false
            end

            local result = commit.revert_commit("invalid")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('commit.error.invalid_commit')
        end)

        it("should revert commit successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return true
                elseif cmd:match("^git revert") then
                    return true
                end
                return false
            end

            local result = commit.revert_commit("abc123")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('commit.success.reverted')
        end)
    end)

    describe("cherry_pick_commit", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = commit.cherry_pick_commit("abc123")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('commit.error.not_git_repo')
        end)

        it("should show error when commit does not exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return false
                end
                return false
            end

            local result = commit.cherry_pick_commit("invalid")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('commit.error.invalid_commit')
        end)

        it("should cherry-pick commit successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return true
                elseif cmd:match("^git cherry%-pick") then
                    return true
                end
                return false
            end

            local result = commit.cherry_pick_commit("abc123")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('commit.success.cherry_picked')
        end)
    end)
end)
