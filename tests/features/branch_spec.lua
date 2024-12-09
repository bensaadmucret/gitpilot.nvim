-- tests/features/branch_spec.lua

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
local branch = require('gitpilot.features.branch')

describe("branch", function()
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

    describe("list_branches", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function() return false end

            local branches, current = branch.list_branches()

            assert.spy(mock_ui.show_error).was_called_with('branch.error.not_git_repo')
            assert.are.same({}, branches)
            assert.is_nil(current)
        end)

        it("should list branches and identify current branch", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd == "git branch --no-color" then
                    return true, "  main\n* develop\n  feature/test"
                end
            end

            local branches, current = branch.list_branches()

            assert.are.same({"main", "develop", "feature/test"}, branches)
            assert.are.same("develop", current)
        end)
    end)

    describe("create_branch", function()
        it("should show error when branch name is invalid", function()
            branch.create_branch("")

            assert.spy(mock_ui.show_error).was_called_with('branch.error.invalid_name')
        end)

        it("should create branch successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git show%-ref") then
                    return false
                elseif cmd:match("^git branch feature/new") then
                    return true
                end
                return false
            end

            local result = branch.create_branch("feature/new")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('branch.success.created')
        end)

        it("should show error when branch already exists", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git show%-ref") then
                    return true
                end
            end

            branch.create_branch("existing-branch")

            assert.spy(mock_ui.show_error).was_called_with('branch.error.already_exists')
        end)
    end)

    describe("delete_branch", function()
        it("should show error when branch name is invalid", function()
            branch.delete_branch("")

            assert.spy(mock_ui.show_error).was_called_with('branch.error.invalid_name')
        end)

        it("should delete branch successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git show%-ref") then
                    return true
                elseif cmd:match("^git branch %-d") then
                    return true
                end
                return false
            end

            local result = branch.delete_branch("feature/old")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('branch.success.deleted')
        end)

        it("should force delete branch when specified", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git show%-ref") then
                    return true
                elseif cmd:match("^git branch %-D") then
                    return true
                end
                return false
            end

            local result = branch.delete_branch("feature/old", true)
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('branch.success.deleted')
        end)

        it("should show error when branch does not exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git show%-ref") then
                    return false
                end
            end

            branch.delete_branch("non-existing")

            assert.spy(mock_ui.show_error).was_called_with('branch.error.not_found')
        end)
    end)
end)
