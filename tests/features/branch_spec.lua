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

describe("Branch Module", function()
    local branch = require("gitpilot.features.branch")
    local utils = require("gitpilot.utils")
    local i18n = require("gitpilot.i18n")
    
    -- Sauvegarde des fonctions originales
    local original = {
        vim = mock,
        execute_command = utils.execute_command
    }
    
    before_each(function()
        _G.vim = mock
        utils.execute_command = function(cmd)
            return "mock output"
        end
    end)
    
    after_each(function()
        _G.vim = original.vim
        utils.execute_command = original.execute_command
        mock.v.shell_error = 0
    end)
    
    describe("list_branches", function()
        it("should return list of branches and current branch", function()
            utils.execute_command = function(cmd)
                return "* main\n  develop\n  feature/test"
            end
            local branches, current = branch.list_branches()
            assert.are.same({"main", "develop", "feature/test"}, branches)
            assert.equals("main", current)
        end)
        
        it("should handle no current branch", function()
            utils.execute_command = function(cmd)
                return "  main\n  develop\n  feature/test"
            end
            local branches, current = branch.list_branches()
            assert.are.same({"main", "develop", "feature/test"}, branches)
            assert.is_nil(current)
        end)
        
        it("should return empty results when no branches", function()
            utils.execute_command = function(cmd)
                return nil
            end
            local branches, current = branch.list_branches()
            assert.are.same({}, branches)
            assert.is_nil(current)
        end)
    end)
    
    describe("create_branch", function()
        it("should create branch successfully", function()
            local notify_called = false
            mock.notify = function(msg, level)
                notify_called = true
                assert.equals(vim.log.levels.INFO, level)
            end
            
            utils.execute_command = function(cmd)
                assert.matches("git checkout %-b feature/new$", cmd)
                return true
            end
            
            local success, _ = branch.create_branch("feature/new")
            assert.is_true(success)
            assert.is_true(notify_called)
        end)
        
        it("should create branch with start point", function()
            utils.execute_command = function(cmd)
                assert.matches("git checkout %-b feature/new main$", cmd)
                return true
            end
            
            local success, _ = branch.create_branch("feature/new", "main")
            assert.is_true(success)
        end)
        
        it("should fail with empty branch name", function()
            local success, message = branch.create_branch("")
            assert.is_false(success)
            assert.equals(i18n.t("branch.error.invalid_name"), message)
        end)
        
        it("should handle creation failure", function()
            local notify_called = false
            mock.notify = function(msg, level)
                notify_called = true
                assert.equals(vim.log.levels.ERROR, level)
            end
            
            utils.execute_command = function(cmd)
                return nil
            end
            
            local success, _ = branch.create_branch("feature/new")
            assert.is_false(success)
            assert.is_true(notify_called)
        end)
    end)
    
    describe("switch_branch", function()
        it("should switch branch successfully", function()
            local notify_called = false
            mock.notify = function(msg, level)
                notify_called = true
                assert.equals(vim.log.levels.INFO, level)
            end
            
            utils.execute_command = function(cmd)
                assert.matches("git checkout main$", cmd)
                return true
            end
            
            local success = branch.switch_branch("main")
            assert.is_true(success)
            assert.is_true(notify_called)
        end)
        
        it("should handle invalid branch name", function()
            local success = branch.switch_branch("")
            assert.is_false(success)
        end)
        
        it("should handle switch failure", function()
            local notify_called = false
            mock.notify = function(msg, level)
                notify_called = true
                assert.equals(vim.log.levels.ERROR, level)
            end
            
            utils.execute_command = function(cmd)
                return nil
            end
            
            local success = branch.switch_branch("invalid-branch")
            assert.is_false(success)
            assert.is_true(notify_called)
        end)
    end)
    
    describe("merge_branch", function()
        it("should merge branch successfully", function()
            local notify_called = false
            mock.notify = function(msg, level)
                notify_called = true
                assert.equals(vim.log.levels.INFO, level)
            end
            
            utils.execute_command = function(cmd)
                assert.matches("git merge feature$", cmd)
                return true
            end
            
            local success = branch.merge_branch("feature")
            assert.is_true(success)
            assert.is_true(notify_called)
        end)
        
        it("should handle invalid branch name", function()
            local success = branch.merge_branch("")
            assert.is_false(success)
        end)
        
        it("should handle merge failure", function()
            local notify_called = false
            mock.notify = function(msg, level)
                notify_called = true
                assert.equals(vim.log.levels.ERROR, level)
            end
            
            utils.execute_command = function(cmd)
                return nil
            end
            
            local success = branch.merge_branch("invalid-branch")
            assert.is_false(success)
            assert.is_true(notify_called)
        end)
    end)
    
    describe("delete_branch", function()
        it("should delete branch successfully", function()
            local notify_called = false
            mock.notify = function(msg, level)
                notify_called = true
                assert.equals(vim.log.levels.INFO, level)
            end
            
            utils.execute_command = function(cmd)
                assert.matches("git branch %-d feature$", cmd)
                return true
            end
            
            local success = branch.delete_branch("feature")
            assert.is_true(success)
            assert.is_true(notify_called)
        end)
        
        it("should handle force delete", function()
            utils.execute_command = function(cmd)
                assert.matches("git branch %-D feature$", cmd)
                return true
            end
            
            local success = branch.delete_branch("feature", true)
            assert.is_true(success)
        end)
        
        it("should handle invalid branch name", function()
            local success = branch.delete_branch("")
            assert.is_false(success)
        end)
        
        it("should handle delete failure", function()
            local notify_called = false
            mock.notify = function(msg, level)
                notify_called = true
                assert.equals(vim.log.levels.ERROR, level)
            end
            
            utils.execute_command = function(cmd)
                return nil
            end
            
            local success = branch.delete_branch("invalid-branch")
            assert.is_false(success)
            assert.is_true(notify_called)
        end)
    end)
end)
