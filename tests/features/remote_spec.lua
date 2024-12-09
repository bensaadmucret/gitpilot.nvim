-- tests/features/remote_spec.lua

-- Mock des dépendances
local mock_ui = {
    show_error = function() end,
    show_success = function() end,
    show_warning = function() end,
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
local remote = require('gitpilot.features.remote')

describe("remote", function()
    local original_execute_command

    before_each(function()
        -- Réinitialisation des spies avant chaque test
        spy.on(mock_ui, "show_error")
        spy.on(mock_ui, "show_success")
        spy.on(mock_ui, "show_warning")
        spy.on(mock_ui, "input")
        spy.on(mock_ui, "select")
        original_execute_command = mock_utils.execute_command
    end)

    after_each(function()
        -- Nettoyage des spies après chaque test
        mock_ui.show_error:revert()
        mock_ui.show_success:revert()
        mock_ui.show_warning:revert()
        mock_ui.input:revert()
        mock_ui.select:revert()
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

            local result = remote.list()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('remote.error.not_git_repo')
        end)

        it("should show error when listing fails", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git remote" then
                    return false
                end
                return false
            end

            local result = remote.list()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('remote.error.list_failed')
        end)

        it("should show error when no remotes exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git remote" then
                    return true, ""
                end
                return false
            end

            local result = remote.list()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('remote.error.no_remotes')
        end)

        it("should list remotes successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git remote" then
                    return true, "origin\nupstream"
                end
                return false
            end

            local result = remote.list()
            assert.is_true(result)
            assert.spy(mock_ui.select).was_called()
        end)
    end)

    describe("add", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = remote.add("origin", "https://github.com/user/repo.git")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('remote.error.not_git_repo')
        end)

        it("should show error when remote name is invalid", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return false
            end

            local result = remote.add("", "https://github.com/user/repo.git")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('remote.error.invalid_name')
        end)

        it("should show error when URL is invalid", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return false
            end

            local result = remote.add("origin", "")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('remote.error.invalid_url')
        end)

        it("should show error when remote already exists", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git remote get%-url") then
                    return true
                end
                return false
            end

            local result = remote.add("origin", "https://github.com/user/repo.git")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('remote.error.already_exists')
        end)

        it("should add remote successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git remote get%-url") then
                    return false
                elseif cmd:match("^git remote add") then
                    return true
                end
                return false
            end

            local result = remote.add("origin", "https://github.com/user/repo.git")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('remote.success.added')
        end)
    end)

    describe("remove", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = remote.remove("origin")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('remote.error.not_git_repo')
        end)

        it("should show error when remote name is invalid", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return false
            end

            local result = remote.remove("")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('remote.error.invalid_name')
        end)

        it("should show error when remote does not exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git remote get%-url") then
                    return false
                end
                return false
            end

            local result = remote.remove("origin")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('remote.error.not_found')
        end)

        it("should remove remote successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git remote get%-url") then
                    return true
                elseif cmd:match("^git remote remove") then
                    return true
                end
                return false
            end

            local result = remote.remove("origin")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('remote.success.removed')
        end)
    end)

    describe("fetch", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = remote.fetch("origin")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('remote.error.not_git_repo')
        end)

        it("should show error when remote name is invalid", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return false
            end

            local result = remote.fetch("")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('remote.error.invalid_name')
        end)

        it("should show error when remote does not exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git remote get%-url") then
                    return false
                end
                return false
            end

            local result = remote.fetch("origin")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('remote.error.not_found')
        end)

        it("should fetch from remote successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git remote get%-url") then
                    return true
                elseif cmd:match("^git fetch") then
                    return true
                end
                return false
            end

            local result = remote.fetch("origin")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('remote.success.fetched')
        end)
    end)

    describe("pull", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = remote.pull("origin")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('remote.error.not_git_repo')
        end)

        it("should show error when remote name is invalid", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return false
            end

            local result = remote.pull("")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('remote.error.invalid_name')
        end)

        it("should show error when remote does not exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git remote get%-url") then
                    return false
                end
                return false
            end

            local result = remote.pull("origin")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('remote.error.not_found')
        end)

        it("should show warning when there are uncommitted changes", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git remote get%-url") then
                    return true
                elseif cmd == "git status --porcelain" then
                    return true, "M file.txt"
                end
                return false
            end

            local result = remote.pull("origin")
            assert.is_false(result)
            assert.spy(mock_ui.show_warning).was_called_with('remote.warning.uncommitted_changes')
        end)

        it("should pull from remote successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git remote get%-url") then
                    return true
                elseif cmd == "git status --porcelain" then
                    return true, ""
                elseif cmd:match("^git pull") then
                    return true
                end
                return false
            end

            local result = remote.pull("origin")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('remote.success.pulled')
        end)
    end)

    describe("push", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = remote.push("origin")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('remote.error.not_git_repo')
        end)

        it("should show error when remote name is invalid", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return false
            end

            local result = remote.push("")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('remote.error.invalid_name')
        end)

        it("should show error when remote does not exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git remote get%-url") then
                    return false
                end
                return false
            end

            local result = remote.push("origin")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('remote.error.not_found')
        end)

        it("should push to remote successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git remote get%-url") then
                    return true
                elseif cmd:match("^git push") then
                    return true
                end
                return false
            end

            local result = remote.push("origin")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('remote.success.pushed')
        end)
    end)
end)
