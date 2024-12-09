-- tests/features/commit_message_spec.lua

local mock_utils = {
    execute_command = function() end
}

local mock_ui = {
    show_error = function() end,
    show_success = function() end
}

-- Mock des dépendances
package.loaded['gitpilot.utils'] = mock_utils
package.loaded['gitpilot.ui'] = mock_ui

-- Import du module à tester
local commit_message = require('gitpilot.features.commit_message')

describe("commit_message", function()
    local original_execute_command

    before_each(function()
        original_execute_command = mock_utils.execute_command
        spy.on(mock_ui, "show_error")
    end)

    after_each(function()
        mock_utils.execute_command = original_execute_command
        mock_ui.show_error:clear()
    end)

    describe("generate_message", function()
        it("should handle non-git repository", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return false
            end

            local message, err = commit_message.generate_message()
            assert.is_nil(message)
            assert.equals("Le répertoire courant n'est pas un dépôt git", err)
            assert.spy(mock_ui.show_error).was_called_with(err)
        end)

        it("should handle git status error", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" then
                    return false, "Error"
                end
                return false
            end

            local message, err = commit_message.generate_message()
            assert.is_nil(message)
            assert.equals("Impossible d'obtenir le statut git", err)
            assert.spy(mock_ui.show_error).was_called_with(err)
        end)

        it("should handle no changes", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" then
                    return true, ""
                end
                return false
            end

            local message, err = commit_message.generate_message()
            assert.is_nil(message)
            assert.equals("Aucun changement à valider", err)
            assert.spy(mock_ui.show_error).was_called_with(err)
        end)

        it("should handle invalid file paths", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" then
                    return true, " M \n"
                end
                return false
            end

            local message, err = commit_message.generate_message()
            assert.is_nil(message)
            assert.equals("Aucun changement valide détecté", err)
            assert.spy(mock_ui.show_error).was_called_with(err)
        end)

        it("should generate message for test changes", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" then
                    return true, [[
 M tests/features/stash_spec.lua
 M tests/features/commit_spec.lua
]]
                end
                return false
            end

            local message = commit_message.generate_message()
            assert.is_not_nil(message)
            assert.matches("^test:", message)
            assert.matches("features/stash_spec", message)
            assert.matches("features/commit_spec", message)
        end)

        it("should generate message for feature changes", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" then
                    return true, [[
 M lua/gitpilot/features/stash.lua
 M lua/gitpilot/features/commit.lua
]]
                end
                return false
            end

            local message = commit_message.generate_message()
            assert.is_not_nil(message)
            assert.matches("^feat:", message)
            assert.matches("features/stash", message)
            assert.matches("features/commit", message)
        end)

        it("should handle special characters in file paths", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" then
                    return true, [[
 M lua/gitpilot/features/test-file.lua
 M lua/gitpilot/features/file_with_underscore.lua
]]
                end
                return false
            end

            local message = commit_message.generate_message()
            assert.is_not_nil(message)
            assert.matches("features/test%-file", message)
            assert.matches("features/file_with_underscore", message)
        end)

        it("should handle mixed changes", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git status --porcelain" then
                    return true, [[
 M lua/gitpilot/features/stash.lua
 M tests/features/stash_spec.lua
 M README.md
]]
                end
                return false
            end

            local message = commit_message.generate_message()
            assert.is_not_nil(message)
            assert.matches("^feat:", message)
            assert.matches("features/stash", message)
            assert.matches("tests/features/stash_spec", message)
            assert.matches("README.md", message)
        end)
    end)
end)
