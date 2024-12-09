-- tests/features/tag_spec.lua

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
    end
}

-- Configuration des mocks
package.loaded['gitpilot.ui'] = mock_ui
package.loaded['gitpilot.utils'] = mock_utils
package.loaded['gitpilot.i18n'] = mock_i18n

-- Import du module à tester
local tag = require('gitpilot.features.tag')

describe("tag", function()
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

            local result = tag.list()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.not_git_repo')
        end)

        it("should show error when listing fails", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git tag") then
                    return false
                end
                return false
            end

            local result = tag.list()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.list_failed')
        end)

        it("should show error when no tags exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git tag") then
                    return true, ""
                end
                return false
            end

            local result = tag.list()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.no_tags')
        end)

        it("should list tags successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git tag") then
                    return true, "v1.0.0\nv1.1.0"
                end
                return false
            end

            local result = tag.list()
            assert.is_true(result)
            assert.spy(mock_ui.select).was_called()
        end)
    end)

    describe("create", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = tag.create("v1.0.0")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.not_git_repo')
        end)

        it("should show error when tag name is invalid", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return false
            end

            local result = tag.create("")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.invalid_name')
        end)

        it("should show error when tag already exists", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return true
                end
                return false
            end

            local result = tag.create("v1.0.0")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.already_exists')
        end)

        it("should create lightweight tag successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return false
                elseif cmd:match("^git tag v1.0.0$") then
                    return true
                end
                return false
            end

            local result = tag.create("v1.0.0")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('tag.success.created')
        end)

        it("should create annotated tag successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return false
                elseif cmd:match("^git tag %-a") then
                    return true
                end
                return false
            end

            local result = tag.create("v1.0.0", "Release version 1.0.0")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('tag.success.created')
        end)
    end)

    describe("delete", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = tag.delete("v1.0.0")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.not_git_repo')
        end)

        it("should show error when tag name is invalid", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return false
            end

            local result = tag.delete("")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.invalid_name')
        end)

        it("should show error when tag does not exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return false
                end
                return false
            end

            local result = tag.delete("v1.0.0")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.not_found')
        end)

        it("should delete tag successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return true
                elseif cmd:match("^git tag %-d") then
                    return true
                end
                return false
            end

            local result = tag.delete("v1.0.0")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('tag.success.deleted')
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

            local result = tag.push("v1.0.0")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.not_git_repo')
        end)

        it("should show error when tag name is invalid", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return false
            end

            local result = tag.push("")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.invalid_name')
        end)

        it("should show error when tag does not exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return false
                end
                return false
            end

            local result = tag.push("v1.0.0")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.not_found')
        end)

        it("should push tag successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return true
                elseif cmd:match("^git push origin") then
                    return true
                end
                return false
            end

            local result = tag.push("v1.0.0")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('tag.success.pushed')
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

            local result = tag.show("v1.0.0")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.not_git_repo')
        end)

        it("should show error when tag name is invalid", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return false
            end

            local result = tag.show("")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.invalid_name')
        end)

        it("should show error when tag does not exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return false
                end
                return false
            end

            local result = tag.show("v1.0.0")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.not_found')
        end)

        it("should show tag details successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return true
                elseif cmd:match("^git show") then
                    return true, "commit abc123\nAuthor: Test\nDate: 2023-01-01\n\nRelease v1.0.0"
                end
                return false
            end

            local result = tag.show("v1.0.0")
            assert.is_true(result)
            assert.spy(mock_ui.show_preview).was_called()
        end)
    end)
end)
