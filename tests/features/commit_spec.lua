-- tests/features/commit_spec.lua

-- Mock des dépendances
local mock_ui = {
    show_error = mock(function() end),
    show_success = mock(function() end),
    input = mock(function(opts, callback) end),
    select = mock(function() end),
    float_window = mock(function(content, opts)
        -- Convert table to string for matching
        content = table.concat(content, "\n")
        -- Vérifie que le contenu est correctement formaté
        assert.truthy(content:match("Modified:"))
        assert.truthy(content:match("Added:"))
        assert.truthy(content:match("Deleted:"))
        assert.truthy(content:match("Renamed:"))
        assert.truthy(content:match("Untracked:"))
        if opts and opts.callback then
            opts.callback()
        end
    end)
}

local mock_utils = {
    execute_command = mock(function() return true end),
    escape_string = mock(function(str) return str end)
}

local mock_i18n = {
    t = mock(function(key) return key end)
}

-- Mock de vim
_G.vim = {
    api = {
        nvim_command = mock(function() end)
    },
    fn = {
        executable = mock(function() return 1 end)
    },
    tbl_deep_extend = mock(function(mode, tbl1, tbl2)
        for k, v in pairs(tbl2 or {}) do
            tbl1[k] = v
        end
        return tbl1
    end)
}

describe("commit", function()
    local commit

    before_each(function()
        -- Clear mocks before each test
        mock_ui.show_error:clear()
        mock_ui.show_success:clear()
        mock_ui.input:clear()
        mock_ui.select:clear()
        mock_ui.float_window:clear()
        mock_utils.execute_command:clear()
        mock_utils.escape_string:clear()
        mock_i18n.t:clear()

        -- Reset mocks
        package.loaded['gitpilot.ui'] = mock_ui
        package.loaded['gitpilot.utils'] = mock_utils
        package.loaded['gitpilot.i18n'] = mock_i18n

        -- Load commit module
        commit = require('gitpilot.features.commit')
    end)

    after_each(function()
        package.loaded['gitpilot.features.commit'] = nil
        package.loaded['gitpilot.ui'] = nil
        package.loaded['gitpilot.utils'] = nil
        package.loaded['gitpilot.i18n'] = nil

        -- Clear all mocks
        mock.clear()
    end)

    describe("create_commit", function()
        it("should show error if not in git repo", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end)

            commit.create_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_error).was_called_with('commit.error.not_git_repo')
            mock_utils.execute_command = original_execute
        end)

        it("should show error if no changes to commit", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" then
                    return true, ""
                end
                return false
            end)

            commit.create_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_error).was_called_with('commit.error.no_changes')
            mock_utils.execute_command = original_execute
        end)

        it("should handle special characters in commit message", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" or cmd == "git status -s" then
                    return true, " M file1.txt"
                elseif cmd:match('^git commit') then
                    return true
                end
                return true
            end)

            mock_ui.float_window = mock(function(content, opts)
                assert.truthy(content)  -- Vérifie que le contenu existe
                assert.truthy(content[1])  -- Vérifie qu'il y a au moins une ligne
                if opts and opts.callback then
                    opts.callback()
                end
            end)

            mock_ui.input = mock(function(opts, callback)
                callback('Test message with "quotes"')
            end)

            commit.create_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.input).was_called()
            assert.spy(mock_ui.show_success).was_called_with('commit.success.created')
            mock_utils.execute_command = original_execute
        end)

        it("should handle empty commit message", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" or cmd == "git status -s" then
                    return true, " M file1.txt"
                end
                return true
            end)

            mock_ui.float_window = mock(function(content, opts)
                if opts and opts.callback then
                    opts.callback()
                end
            end)

            mock_ui.input = mock(function(opts, callback)
                callback("")
            end)

            commit.create_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_error).was_called_with('commit.error.empty_message')
            mock_utils.execute_command = original_execute
        end)

        it("should format git status with correct categories", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" or cmd == "git status -s" then
                    return true, [[
M  modified.txt
A  added.txt
D  deleted.txt
R  old.txt -> new.txt
?? untracked.txt]]
                elseif cmd:match("^git commit") then
                    return true
                end
                return true
            end)

            mock_ui.float_window = mock(function(content, opts)
                -- Convert table to string for matching
                local content_str = table.concat(content, "\n")
                -- Vérifie que le contenu est correctement formaté
                assert.truthy(content_str:match("modified.txt"))
                assert.truthy(content_str:match("added.txt"))
                assert.truthy(content_str:match("deleted.txt"))
                assert.truthy(content_str:match("old.txt"))
                assert.truthy(content_str:match("untracked.txt"))
                if opts and opts.callback then
                    opts.callback()
                end
            end)

            mock_ui.input = mock(function(opts, callback)
                callback("Test commit message")
            end)

            commit.create_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.float_window).was_called()
            assert.spy(mock_ui.input).was_called()
            assert.spy(mock_ui.show_success).was_called_with('commit.success.created')
            mock_utils.execute_command = original_execute
        end)

        it("should handle multiline commit messages", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" or cmd == "git status -s" then
                    return true, " M file1.txt"
                elseif cmd:match('^git commit') then
                    assert.truthy(cmd:match("\n"))  -- Vérifie que les sauts de ligne sont préservés
                    return true
                end
                return false
            end)

            mock_ui.float_window = mock(function(content, opts)
                if opts and opts.callback then
                    opts.callback()
                end
            end)

            mock_ui.input = mock(function(opts, callback)
                callback('First line\nSecond line\nThird line')
            end)

            commit.create_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.input).was_called()
            assert.spy(mock_ui.show_success).was_called_with('commit.success.created')
            mock_utils.execute_command = original_execute
        end)

        it("should handle commit failure gracefully", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" or cmd == "git status -s" then
                    return true, " M file1.txt"
                elseif cmd:match('^git commit') then
                    return false, "Erreur de commit"  -- Simule un échec du commit
                end
                return true
            end)

            mock_ui.float_window = mock(function(content, opts)
                if opts and opts.callback then
                    opts.callback()
                end
            end)

            mock_ui.input = mock(function(opts, callback)
                callback("Test commit message")
            end)

            commit.create_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_error).was_called_with('commit.error.create_failed\nErreur de commit')
            mock_utils.execute_command = original_execute
        end)

        it("should handle external editor commit", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" then
                    return true, " M file1.txt"
                elseif cmd == "git commit" then
                    return true
                end
                return false
            end)

            -- Configure pour utiliser l'éditeur externe
            commit.setup({ commit_editor = "external" })

            commit.create_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_success).was_called_with('commit.success.created')
            mock_utils.execute_command = original_execute

            -- Remettre la configuration par défaut
            commit.setup({ commit_editor = "builtin" })
        end)
    end)

    describe("create_commit with builtin editor", function()
        before_each(function()
            commit.setup({ commit_editor = "builtin" })
        end)

        it("should show git status before commit input", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" or cmd == "git status -s" then
                    return true, " M modified.txt"
                elseif cmd:match("^git commit") then
                    return true
                end
                return false
            end)

            mock_ui.float_window = mock(function(content, opts)
                -- Convert table to string for matching
                content = table.concat(content, "\n")
                assert.truthy(content:match("Modified:"))
                assert.truthy(content:match("modified.txt"))
                if opts and opts.callback then
                    opts.callback()
                end
            end)

            mock_ui.input = mock(function(opts, callback)
                callback("Test commit message")
            end)

            commit.create_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.float_window).was_called()
            assert.spy(mock_ui.input).was_called()
            assert.spy(mock_ui.show_success).was_called_with('commit.success.created')
            mock_utils.execute_command = original_execute
        end)

        it("should parse git status correctly", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" or cmd == "git status -s" then
                    return true, [[
A  added.txt
D  deleted.txt
R  renamed.txt -> new_name.txt
?? untracked.txt]]
                elseif cmd:match("^git commit") then
                    return true
                end
                return false
            end)

            mock_ui.float_window = mock(function(content, opts)
                -- Convert table to string for matching
                content = table.concat(content, "\n")
                assert.truthy(content:match("Added:"))
                assert.truthy(content:match("Deleted:"))
                assert.truthy(content:match("Renamed:"))
                assert.truthy(content:match("Untracked:"))
                if opts and opts.callback then
                    opts.callback()
                end
            end)

            mock_ui.input = mock(function(opts, callback)
                callback("Test commit message")
            end)

            commit.create_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.float_window).was_called()
            assert.spy(mock_ui.input).was_called()
            assert.spy(mock_ui.show_success).was_called_with('commit.success.created')
            mock_utils.execute_command = original_execute
        end)

        it("should not show status window when no changes", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" then
                    return true, ""
                end
                return false
            end)

            commit.create_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_error).was_called_with('commit.error.no_changes')
            mock_utils.execute_command = original_execute
        end)
    end)

    describe("amend_commit", function()
        it("should show error when not in a git repo", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end)

            commit.amend_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_error).was_called_with('commit.error.not_git_repo')
            mock_utils.execute_command = original_execute
        end)

        it("should show error when no commits exist", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git log -1 --format=%B" then
                    return false
                end
                return true
            end)

            commit.amend_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_error).was_called_with('commit.error.no_commits')
            mock_utils.execute_command = original_execute
        end)

        it("should amend commit successfully with builtin editor", function()
            commit.setup({ commit_editor = "builtin" })
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git rev-parse HEAD" then
                    return true
                elseif cmd == "git log -1 --pretty=%B" then
                    return true, "Previous commit message"
                elseif cmd == "git commit --amend -m \"New commit message\"" then
                    return true
                end
                return true
            end)

            mock_ui.input = mock(function(opts, callback)
                callback("New commit message")
            end)

            commit.amend_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_success).was_called_with('commit.success.amended')
            mock_utils.execute_command = original_execute
        end)

        it("should handle amend with empty message", function()
            commit.setup({ commit_editor = "builtin" })
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git rev-parse HEAD" then
                    return true
                elseif cmd == "git log -1 --pretty=%B" then
                    return true, "Original commit message"
                end
                return true
            end)

            mock_ui.input = mock(function(opts, callback)
                callback("")
            end)

            commit.amend_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_error).was_called_with('commit.error.empty_message')
            mock_utils.execute_command = original_execute
        end)

        it("should handle amend failure gracefully", function()
            commit.setup({ commit_editor = "builtin" })
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git rev-parse HEAD" then
                    return true
                elseif cmd == "git log -1 --pretty=%B" then
                    return true, "Previous commit message"
                elseif cmd == "git commit --amend -m \"New commit message\"" then
                    return false, "Erreur d'amend"
                end
                return true
            end)

            mock_ui.input = mock(function(opts, callback)
                callback("New commit message")
            end)

            commit.amend_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_error).was_called_with('commit.error.amend_failed\nErreur d\'amend')
            mock_utils.execute_command = original_execute
        end)
    end)

    describe("fixup_commit", function()
        it("should show error when not in a git repo", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end)

            commit.fixup_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_error).was_called_with('commit.error.not_git_repo')
            mock_utils.execute_command = original_execute
        end)

        it("should show error when commit does not exist", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git log --oneline" then
                    return false
                end
                return true
            end)

            commit.fixup_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_error).was_called_with('commit.error.no_commits')
            mock_utils.execute_command = original_execute
        end)

        it("should show error when no changes to commit", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git log --oneline" then
                    return true, "abc123 commit message"
                elseif cmd == "git status --porcelain" then
                    return true, ""
                end
                return false
            end)

            commit.fixup_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_error).was_called_with('commit.error.no_changes')
            mock_utils.execute_command = original_execute
        end)

        it("should fixup commit successfully", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git log --oneline" then
                    return true, "abc123 commit message"
                elseif cmd == "git status --porcelain" then
                    return true, "M file.txt"
                elseif cmd:match("^git commit %-%-fixup") then
                    return true
                end
                return true
            end)

            commit.fixup_commit("abc123")

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_success).was_called_with('commit.success.fixup')
            mock_utils.execute_command = original_execute
        end)
    end)

    describe("revert_commit", function()
        it("should show error when not in a git repo", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end)

            commit.revert_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_error).was_called_with('commit.error.not_git_repo')
            mock_utils.execute_command = original_execute
        end)

        it("should show error when commit does not exist", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git log --oneline" then
                    return false
                end
                return true
            end)

            commit.revert_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_error).was_called_with('commit.error.no_commits')
            mock_utils.execute_command = original_execute
        end)

        it("should revert commit successfully", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git rev-parse --verify --quiet abc123" then
                    return true
                elseif cmd:match("^git revert") then
                    return true
                end
                return true
            end)

            commit.revert_commit("abc123")

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_success).was_called_with('commit.success.reverted')
            mock_utils.execute_command = original_execute
        end)
    end)

    describe("cherry_pick_commit", function()
        it("should show error when not in a git repo", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end)

            commit.cherry_pick_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_error).was_called_with('commit.error.not_git_repo')
            mock_utils.execute_command = original_execute
        end)

        it("should show error when commit does not exist", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git log --oneline" then
                    return false
                end
                return true
            end)

            commit.cherry_pick_commit()

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_error).was_called_with('commit.error.no_commits')
            mock_utils.execute_command = original_execute
        end)

        it("should cherry-pick commit successfully", function()
            local original_execute = mock_utils.execute_command
            mock_utils.execute_command = mock(function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git rev-parse --verify --quiet abc123" then
                    return true
                elseif cmd:match("^git cherry-pick") then
                    return true
                end
                return true
            end)

            commit.cherry_pick_commit("abc123")

            assert.spy(mock_utils.execute_command).was_called()
            assert.spy(mock_ui.show_success).was_called_with('commit.success.cherry_picked')
            mock_utils.execute_command = original_execute
        end)
    end)
end)
