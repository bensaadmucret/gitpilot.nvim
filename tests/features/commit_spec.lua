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

    before_each(function()
        -- Réinitialisation des spies avant chaque test
        spy.on(mock_ui, "show_error")
        spy.on(mock_ui, "show_success")
        spy.on(mock_ui, "input")
        spy.on(mock_ui, "select")
        spy.on(mock_ui, "float_window")
        original_execute_command = mock_utils.execute_command
    end)

    after_each(function()
        -- Nettoyage des spies après chaque test
        mock_utils.execute_command = original_execute_command
        mock_ui.show_error:revert()
        mock_ui.show_success:revert()
        mock_ui.input:revert()
        mock_ui.select:revert()
        mock_ui.float_window:revert()
    end)

    describe("create_commit", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            commit.create_commit()

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

            commit.create_commit()

            assert.spy(mock_ui.show_error).was_called_with('commit.error.no_changes')
        end)

        it("should create commit successfully with builtin editor", function()
            commit.setup({ commit_editor = "builtin" })

            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" or cmd == "git status -s" then
                    return true, " M file1.txt"
                elseif cmd:match("^git commit") then
                    return true
                end
                return false
            end

            mock_ui.float_window = function(content, opts)
                opts.callback()
            end

            mock_ui.input = function(opts, callback)
                callback("test commit")
            end

            commit.create_commit()

            assert.spy(mock_ui.show_success).was_called_with('commit.success.created')
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
                elseif cmd:match("^git commit") then
                    return true
                end
                return false
            end

            local status_shown = false
            mock_ui.float_window = function(content, opts)
                status_shown = true
                -- Vérifie que le contenu contient les fichiers modifiés et non suivis
                assert.truthy(content[1]:match("file1.txt"))
                assert.truthy(content[1]:match("file2.txt"))
                -- Simule la fermeture de la fenêtre
                opts.callback()
            end

            local input_shown = false
            mock_ui.input = function(opts, callback)
                assert.truthy(status_shown, "Status should be shown before input")
                input_shown = true
                callback("test commit")
            end

            commit.create_commit()

            assert.truthy(status_shown, "Status window should be shown")
            assert.truthy(input_shown, "Input window should be shown")
            assert.spy(mock_ui.show_success).was_called_with('commit.success.created')
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
                elseif cmd:match("^git commit") then
                    return true
                end
                return false
            end

            local status_content = nil
            mock_ui.float_window = function(content, opts)
                status_content = content[1]
                opts.callback()
            end

            mock_ui.input = function(opts, callback)
                callback("test commit")
            end

            commit.create_commit()

            -- Vérifie que chaque type de fichier est correctement catégorisé
            assert.truthy(status_content:match("modified.txt"))
            assert.truthy(status_content:match("added.txt"))
            assert.truthy(status_content:match("deleted.txt"))
            assert.truthy(status_content:match("renamed.txt"))
            assert.truthy(status_content:match("untracked.txt"))
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

            local status_shown = false
            mock_ui.float_window = function()
                status_shown = true
            end

            commit.create_commit()

            assert.falsy(status_shown, "Status window should not be shown")
            assert.spy(mock_ui.show_error).was_called_with('commit.error.no_changes')
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
