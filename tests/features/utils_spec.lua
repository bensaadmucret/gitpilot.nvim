-- Mock des fonctions Neovim
local mock = {
    fn = {
        system = function(cmd) return "mock output" end,
        getcwd = function() return "/mock/path" end
    },
    v = { shell_error = 0 },
    api = {
        nvim_err_writeln = function(msg) end,
        nvim_command = function(cmd) end,
        nvim_echo = function(chunks, history, opts) end
    },
    notify = function(msg, level, opts) end,
    tbl_deep_extend = function(mode, t1, t2)
        local result = {}
        for k, v in pairs(t1) do result[k] = v end
        for k, v in pairs(t2) do result[k] = v end
        return result
    end,
    loop = {
        fs_stat = function(path) return { type = "directory" } end
    },
    log = {
        levels = {
            ERROR = 1,
            WARN = 2,
            INFO = 3,
            DEBUG = 4
        }
    }
}

-- Initialiser le mock vim avant de charger les modules
_G.vim = mock

describe("Utils Module", function()
    local utils = require("gitpilot.utils")
    
    -- Sauvegarde des fonctions originales
    local original = {
        vim = mock,
        popen = io.popen
    }
    
    before_each(function()
        _G.vim = mock
        io.popen = function()
            return {
                read = function() return "git version 2.34.1" end,
                close = function() end
            }
        end
    end)
    
    after_each(function()
        _G.vim = original.vim
        io.popen = original.popen
        mock.v.shell_error = 0
    end)

    describe("setup", function()
        it("should update git configuration", function()
            local opts = { git = { timeout = 10000 } }
            assert.has_no.errors(function()
                utils.setup(opts)
            end)
        end)
        
        it("should handle nil options", function()
            assert.has_no.errors(function()
                utils.setup(nil)
            end)
        end)
    end)
    
    describe("execute_command", function()
        it("should execute command successfully", function()
            local result = utils.execute_command("git status")
            assert.is_not_nil(result)
            assert.equals("mock output", result)
        end)
        
        it("should handle command failure", function()
            mock.v.shell_error = 1
            local result = utils.execute_command("git invalid-command")
            assert.is_nil(result)
        end)

        it("should handle empty command", function()
            local result = utils.execute_command("")
            assert.is_nil(result)
        end)

        it("should handle nil command", function()
            local result = utils.execute_command(nil)
            assert.is_nil(result)
        end)
    end)
    
    describe("check_git", function()
        it("should detect git installation", function()
            assert.is_true(utils.check_git())
        end)
        
        it("should handle missing git", function()
            io.popen = function() return nil end
            assert.is_false(utils.check_git())
        end)

        it("should handle invalid git version", function()
            io.popen = function()
                return {
                    read = function() return "not git" end,
                    close = function() end
                }
            end
            assert.is_false(utils.check_git())
        end)
    end)
    
    describe("is_git_repo", function()
        it("should detect git repository", function()
            assert.is_true(utils.is_git_repo())
        end)
        
        it("should handle non-git directory", function()
            mock.v.shell_error = 1
            assert.is_false(utils.is_git_repo())
        end)
    end)
    
    describe("get_git_root", function()
        it("should return git root directory", function()
            mock.fn.system = function() return "/path/to/repo\n" end
            assert.equals("/path/to/repo", utils.get_git_root())
        end)
        
        it("should return nil outside git repo", function()
            mock.v.shell_error = 1
            assert.is_nil(utils.get_git_root())
        end)

        it("should handle trailing whitespace", function()
            mock.fn.system = function() return "/path/to/repo  \n  " end
            assert.equals("/path/to/repo", utils.get_git_root())
        end)
    end)
    
    describe("escape_string", function()
        it("should escape special characters", function()
            local result = utils.escape_string("test*string")
            assert.equals("test\\*string", result)
        end)

        it("should escape multiple special characters", function()
            local result = utils.escape_string("test*string(with)special?chars")
            assert.equals("test\\*string\\(with\\)special\\?chars", result)
        end)

        it("should not escape alphanumeric characters", function()
            local result = utils.escape_string("testString123")
            assert.equals("testString123", result)
        end)
    end)
    
    describe("format_message", function()
        it("should format message with parameters", function()
            local msg = "Branch %{name} created"
            local params = { name = "feature/test" }
            local result = utils.format_message(msg, params)
            assert.equals("Branch feature/test created", result)
        end)
        
        it("should handle missing parameters", function()
            local msg = "Branch %{name} created"
            local result = utils.format_message(msg)
            assert.equals(msg, result)
        end)

        it("should handle empty parameters", function()
            local msg = "Branch %{name} created"
            local result = utils.format_message(msg, {})
            assert.equals("Branch  created", result)
        end)

        it("should handle multiple parameters", function()
            local msg = "Branch %{name} created by %{user}"
            local params = { name = "feature/test", user = "john" }
            local result = utils.format_message(msg, params)
            assert.equals("Branch feature/test created by john", result)
        end)
    end)
end)