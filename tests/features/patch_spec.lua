-- tests/features/patch_spec.lua

local mock_utils = {
    execute_command = function() return true, "" end,
    escape_string = function(str) return str end
}

local mock_vim = {
    fn = {
        stdpath = function() return "/tmp" end
    }
}

-- Mock des dépendances
package.loaded['gitpilot.utils'] = mock_utils
package.loaded['vim'] = mock_vim
package.loaded['gitpilot.config'] = {}
package.loaded['gitpilot.i18n'] = {
    t = function(key) return key end
}

-- Import du module à tester
local patch = require('gitpilot.features.patch')

describe("patch", function()
    local original_execute_command

    before_each(function()
        original_execute_command = mock_utils.execute_command
        spy.on(mock_utils, "execute_command")
    end)

    after_each(function()
        if type(mock_utils.execute_command) == "table" and mock_utils.execute_command.clear then
            mock_utils.execute_command:clear()
        end
    end)

    describe("setup", function()
        it("should create template directory", function()
            patch.setup()
            assert.spy(mock_utils.execute_command).was_called_with("mkdir -p /tmp/gitpilot/templates/patches")
        end)

        it("should use custom template directory", function()
            patch.setup({ template_directory = "/custom/path" })
            assert.spy(mock_utils.execute_command).was_called_with("mkdir -p /custom/path")
        end)
    end)

    describe("create_patch", function()
        it("should create patch for last commit by default", function()
            mock_utils.execute_command = function(cmd)
                assert.equals("git format-patch -1", cmd)
                return true, "Created patch file"
            end

            local success, result = patch.create_patch()
            assert.is_true(success)
            assert.equals("Created patch file", result)
        end)

        it("should create patch between two commits", function()
            mock_utils.execute_command = function(cmd)
                assert.equals("git format-patch abc123..def456", cmd)
                return true, "Created patch file"
            end

            local success, result = patch.create_patch("abc123", "def456")
            assert.is_true(success)
            assert.equals("Created patch file", result)
        end)

        it("should create patch from specific commit", function()
            mock_utils.execute_command = function(cmd)
                assert.equals("git format-patch abc123", cmd)
                return true, "Created patch file"
            end

            local success, result = patch.create_patch("abc123")
            assert.is_true(success)
            assert.equals("Created patch file", result)
        end)

        it("should use custom output directory", function()
            mock_utils.execute_command = function(cmd)
                assert.equals("git format-patch -1 -o /custom/output", cmd)
                return true, "Created patch file"
            end

            local success, result = patch.create_patch(nil, nil, "/custom/output")
            assert.is_true(success)
            assert.equals("Created patch file", result)
        end)

        it("should handle patch creation failure", function()
            mock_utils.execute_command = function(cmd)
                return false, "Error creating patch"
            end

            local success, result = patch.create_patch()
            assert.is_false(success)
            assert.equals("Error creating patch", result)
        end)
    end)
end)
