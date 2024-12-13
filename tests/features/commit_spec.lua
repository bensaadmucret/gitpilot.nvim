-- tests/features/commit_spec.lua

-- Mock des dépendances
local mock_ui = {
    show_error = function() end,
    show_success = function() end,
    input = function() end,
    select = function() end,
    float_window = function() end
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
    local original_float_window

    before_each(function()
        -- Réinitialisation des spies avant chaque test
        spy.on(mock_ui, "show_error")
        spy.on(mock_ui, "show_success")
        spy.on(mock_ui, "input")
        spy.on(mock_ui, "select")
        spy.on(mock_ui, "float_window")
        original_execute_command = mock_utils.execute_command
        original_float_window = mock_ui.float_window
    end)

    after_each(function()
        -- Nettoyage des spies après chaque test
        mock_utils.execute_command = original_execute_command
        mock_ui.float_window = original_float_window
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

    describe("create_commit with builtin editor", function()
        before_each(function()
            commit.setup({ commit_editor = "builtin" })
        end)

        it("should show git status before commit input", function()
            -- Mock git status
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" then
                    return true, " M file1.txt\n?? file2.txt"
                elseif cmd == "git status -s" then
                    return true, " M file1.txt\n?? file2.txt"
                end
                return false
            end

            -- Mock float_window pour capturer le contenu et simuler le callback
            mock_ui.float_window = function(content, opts)
                -- Vérifie que le contenu contient les fichiers modifiés et non suivis
                assert.truthy(content[1]:match("file1.txt"))
                assert.truthy(content[1]:match("file2.txt"))
                -- Simule la fermeture de la fenêtre
                opts.callback()
            end

            -- Mock input pour simuler la saisie du message
            mock_ui.input = function(opts, callback)
                callback("test commit")
            end

            commit.create_commit()

            -- Vérifie que float_window a été appelé avant input
            assert.spy(mock_ui.float_window).was_called(1)
            assert.spy(mock_ui.input).was_called(1)
        end)

        it("should parse git status correctly", function()
            -- Mock git status avec différents types de changements
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" or cmd == "git status -s" then
                    return true, [[
 M modified.txt
A  added.txt
D  deleted.txt
R  renamed.txt -> new_name.txt
?? untracked.txt
]]
                end
                return false
            end

            -- Mock float_window pour vérifier le contenu
            mock_ui.float_window = function(content, opts)
                local status_text = content[1]
                -- Vérifie que chaque type de fichier est correctement catégorisé
                assert.truthy(status_text:match("modified.txt"))
                assert.truthy(status_text:match("added.txt"))
                assert.truthy(status_text:match("deleted.txt"))
                assert.truthy(status_text:match("renamed.txt"))
                assert.truthy(status_text:match("untracked.txt"))
                opts.callback()
            end

            -- Mock input
            mock_ui.input = function(opts, callback)
                callback("test commit")
            end

            commit.create_commit()

            assert.spy(mock_ui.float_window).was_called(1)
        end)

        it("should not show status window when no changes", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" then
                    return true, ""
                end
                return false
            end

            commit.create_commit()

            assert.spy(mock_ui.float_window).was_not_called()
            assert.spy(mock_ui.show_error).was_called_with('commit.error.no_changes')
        end)

        it("should handle git status command failure", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" or cmd == "git status -s" then
                    return false
                end
                return false
            end

            commit.create_commit()

            assert.spy(mock_ui.float_window).was_not_called()
            assert.spy(mock_ui.show_error).was_called()
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
