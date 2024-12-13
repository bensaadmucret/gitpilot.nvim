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
    local original_input
    local original_float_window
    local original_show_error
    local original_show_success
    local original_select

    before_each(function()
        -- Sauvegarder les fonctions originales
        original_execute_command = mock_utils.execute_command
        original_input = mock_ui.input
        original_float_window = mock_ui.float_window
        original_show_error = mock_ui.show_error
        original_show_success = mock_ui.show_success
        original_select = mock_ui.select

        -- Réinitialisation des spies
        spy.on(mock_ui, "show_error")
        spy.on(mock_ui, "show_success")
        spy.on(mock_ui, "input")
        spy.on(mock_ui, "select")
        spy.on(mock_ui, "float_window")
    end)

    after_each(function()
        -- Restaurer les fonctions originales
        mock_utils.execute_command = original_execute_command
        mock_ui.input = original_input
        mock_ui.float_window = original_float_window
        mock_ui.show_error = original_show_error
        mock_ui.show_success = original_show_success
        mock_ui.select = original_select
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

        it("should handle special characters in commit message", function()
            -- Mock git status and commands
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" or cmd == "git status -s" then
                    return true, " M file1.txt"
                elseif cmd:match('^git commit') then
                    -- Vérifie que le message est correctement échappé
                    assert.truthy(cmd:match('"'))  -- Doit utiliser des guillemets doubles
                    assert.truthy(not cmd:match("'"))  -- Ne doit pas utiliser de guillemets simples
                    return true
                end
                return false
            end

            -- Simuler l'affichage du statut
            mock_ui.float_window = function(content, opts)
                opts.callback()
            end

            -- Simuler l'entrée avec des caractères spéciaux
            mock_ui.input = function(opts, callback)
                callback('Test message with "quotes" and `backticks` & special chars!')
            end

            commit.create_commit()

            assert.spy(mock_ui.show_success).was_called_with('commit.success.created')
        end)

        it("should handle empty commit message", function()
            -- Mock git status and commands
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" or cmd == "git status -s" then
                    return true, " M file1.txt"
                end
                return false
            end

            -- Simuler l'affichage du statut
            mock_ui.float_window = function(content, opts)
                opts.callback()
            end

            -- Simuler l'entrée avec un message vide
            mock_ui.input = function(opts, callback)
                callback("")
            end

            commit.create_commit()

            -- Vérifie qu'aucun commit n'a été créé
            assert.spy(mock_ui.show_success).was_not_called()
            assert.spy(mock_ui.show_error).was_not_called()
        end)

        it("should format git status with correct categories", function()
            -- Mock git status avec différents types de fichiers
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" or cmd == "git status -s" then
                    return true, [[
M  modified1.txt
 M modified2.txt
MM modified3.txt
A  added.txt
D  deleted.txt
R  old.txt -> new.txt
?? untracked.txt]]
                end
                return false
            end

            local categories_found = {
                modified = false,
                added = false,
                deleted = false,
                renamed = false,
                untracked = false
            }

            -- Vérifie que chaque catégorie est présente et correctement formatée
            mock_ui.float_window = function(content, opts)
                for _, line in ipairs(content) do
                    if line:match(i18n.t('commit.status.modified')) then
                        assert.truthy(line:match("modified1.txt") or line:match("modified2.txt") or line:match("modified3.txt"))
                        categories_found.modified = true
                    elseif line:match(i18n.t('commit.status.added')) then
                        assert.truthy(line:match("added.txt"))
                        categories_found.added = true
                    elseif line:match(i18n.t('commit.status.deleted')) then
                        assert.truthy(line:match("deleted.txt"))
                        categories_found.deleted = true
                    elseif line:match(i18n.t('commit.status.renamed')) then
                        assert.truthy(line:match("old.txt") and line:match("new.txt"))
                        categories_found.renamed = true
                    elseif line:match(i18n.t('commit.status.untracked')) then
                        assert.truthy(line:match("untracked.txt"))
                        categories_found.untracked = true
                    end
                end
                opts.callback()
            end

            mock_ui.input = function(opts, callback)
                -- Vérifie que toutes les catégories ont été trouvées
                assert.truthy(categories_found.modified, "Modified files category not found")
                assert.truthy(categories_found.added, "Added files category not found")
                assert.truthy(categories_found.deleted, "Deleted files category not found")
                assert.truthy(categories_found.renamed, "Renamed files category not found")
                assert.truthy(categories_found.untracked, "Untracked files category not found")
                callback("test commit")
            end

            commit.create_commit()
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
            local has_modified_file = false
            local has_untracked_file = false

            mock_ui.float_window = function(content, opts)
                status_shown = true
                -- Vérifie que le contenu contient les fichiers modifiés et non suivis
                for _, line in ipairs(content) do
                    if line:match("file1.txt") then
                        has_modified_file = true
                    end
                    if line:match("file2.txt") then
                        has_untracked_file = true
                    end
                end
                -- Simule la fermeture de la fenêtre
                opts.callback()
            end

            local input_shown = false
            mock_ui.input = function(opts, callback)
                assert.truthy(status_shown, "Status should be shown before input")
                assert.truthy(has_modified_file, "Modified file should be shown")
                assert.truthy(has_untracked_file, "Untracked file should be shown")
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

            local files_found = {
                modified = false,
                added = false,
                deleted = false,
                renamed = false,
                untracked = false
            }

            mock_ui.float_window = function(content, opts)
                for _, line in ipairs(content) do
                    if line:match("modified.txt") then files_found.modified = true end
                    if line:match("added.txt") then files_found.added = true end
                    if line:match("deleted.txt") then files_found.deleted = true end
                    if line:match("renamed.txt") then files_found.renamed = true end
                    if line:match("untracked.txt") then files_found.untracked = true end
                end
                opts.callback()
            end

            mock_ui.input = function(opts, callback)
                callback("test commit")
            end

            commit.create_commit()

            -- Vérifie que chaque type de fichier est correctement catégorisé
            assert.truthy(files_found.modified, "Modified file should be shown")
            assert.truthy(files_found.added, "Added file should be shown")
            assert.truthy(files_found.deleted, "Deleted file should be shown")
            assert.truthy(files_found.renamed, "Renamed file should be shown")
            assert.truthy(files_found.untracked, "Untracked file should be shown")
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
