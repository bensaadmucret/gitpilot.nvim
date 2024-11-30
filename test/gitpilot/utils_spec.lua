local assert = require('luassert')
local utils = require('gitpilot.utils')

describe('utils', function()
    before_each(function()
        -- Reset utils configuration before each test
        utils.setup({})
        -- Ensure we're in test mode
        vim.env.GITPILOT_TEST = "1"
    end)

    describe('git_command', function()
        it('should handle empty command', function()
            local result = utils.git_command('')
            assert.is_false(result.success)
            assert.equals("", result.output)
            assert.matches("Invalid git command", result.error)
        end)

        it('should handle nil command', function()
            local result = utils.git_command(nil)
            assert.is_false(result.success)
            assert.equals("", result.output)
            assert.matches("Command cannot be empty", result.error)
        end)

        it('should reject unsafe commands', function()
            local result = utils.git_command('status; rm -rf /')
            assert.is_false(result.success)
            assert.equals("", result.output)
            assert.matches("Command contains unsafe characters", result.error)
        end)

        it('should reject unknown git commands', function()
            local result = utils.git_command('unknown_command')
            assert.is_false(result.success)
            assert.equals("", result.output)
            assert.matches("Git command 'unknown_command' not allowed", result.error)
        end)

        it('should allow valid git commands', function()
            local result = utils.git_command('status')
            assert.is_true(result.success)
            assert.matches("Test output for: status", result.output)
            assert.equals("", result.error)
        end)

        it('should handle command with arguments', function()
            local result = utils.git_command('add file.txt')
            assert.is_true(result.success)
            assert.matches("Test output for: add file.txt", result.output)
            assert.equals("", result.error)
        end)

        it('should handle command with options', function()
            local result = utils.git_command('commit -m "test"')
            assert.is_true(result.success)
            assert.matches('Test output for: commit %-m "test"', result.output)
            assert.equals("", result.error)
        end)

        it('should execute git command with default configuration', function()
            local result = utils.git_command('--version')
            assert.is_true(result.success)
            assert.matches('git version', result.output)
            assert.equals('', result.error)
        end)

        it('should use custom git command from config', function()
            utils.setup({
                git = {
                    cmd = '/usr/bin/git'
                }
            })
            local result = utils.git_command('--version')
            assert.is_true(result.success)
            assert.matches('git version', result.output)
        end)

        it('should handle command timeout', function()
            utils.setup({
                git = {
                    timeout = 1  -- 1ms timeout
                }
            })
            local result = utils.git_command('status')  -- Should timeout
            assert.is_false(result.success)
            assert.equals('TIMEOUT', result.error_type)
        end)

        it('should handle git errors', function()
            local result = utils.git_command('invalid-command')
            assert.is_false(result.success)
            assert.equals('COMMAND_ERROR', result.error_type)
            assert.matches("'invalid%-command' is not a git command", result.error)
        end)
    end)

    describe('get_file_status', function()
        it('should handle empty file path', function()
            local result = utils.get_file_status('')
            assert.is_false(result.success)
            assert.equals('INVALID_INPUT', result.error_type)
            assert.matches('File path cannot be empty', result.message)
        end)

        it('should handle nil file path', function()
            local result = utils.get_file_status(nil)
            assert.is_false(result.success)
            assert.equals('INVALID_INPUT', result.error_type)
            assert.matches('File path cannot be empty', result.message)
        end)

        it('should get status of existing file', function()
            -- Create a temporary file
            local file = os.tmpname()
            local f = io.open(file, 'w')
            f:write('test content')
            f:close()

            local result = utils.get_file_status(file)
            assert.is_true(result.success)
            assert.is_string(result.status)

            -- Clean up
            os.remove(file)
        end)

        it('should handle non-existent file', function()
            local result = utils.get_file_status('/path/to/nonexistent/file')
            assert.is_false(result.success)
            assert.equals('FILE_ERROR', result.error_type)
        end)
    end)

    describe('setup', function()
        it('should use default configuration when no options provided', function()
            utils.setup()
            local result = utils.git_command('status')
            assert.is_true(result.success)
        end)

        it('should apply custom configuration', function()
            utils.setup({
                git = {
                    cmd = "/usr/local/bin/git",
                    timeout = 10000
                }
            })
            local result = utils.git_command('status')
            assert.is_true(result.success)
        end)
    end)
end)
