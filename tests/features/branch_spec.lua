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
    ui = {
        input = function(opts, callback) callback("test-branch") end,
        select = function(items, opts, callback) 
            if callback and items[1] then
                callback(items[1])
            end
        end
    },
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
    local branch
    local utils
    local i18n
    
    -- Sauvegarde des fonctions originales
    local original = {
        vim = mock,
        execute_command = nil
    }
    
    before_each(function()
        -- Reset les modules pour chaque test
        package.loaded["gitpilot.features.branch"] = nil
        package.loaded["gitpilot.utils"] = nil
        package.loaded["gitpilot.i18n"] = nil

        _G.vim = mock
        branch = require("gitpilot.features.branch")
        utils = require("gitpilot.utils")
        i18n = require("gitpilot.i18n")
        
        original.execute_command = utils.execute_command
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
                assert.equals("git branch --all", cmd)
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

        it("should handle malformed branch output", function()
            utils.execute_command = function(cmd)
                return "* \n  \n invalid"
            end
            local branches, current = branch.list_branches()
            assert.are.same({"invalid"}, branches)
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

        it("should fail with nil branch name", function()
            local success, message = branch.create_branch(nil)
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

        it("should handle nil branch name", function()
            local success = branch.switch_branch(nil)
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

        it("should handle nil branch name", function()
            local success = branch.merge_branch(nil)
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
            
            local success = branch.merge_branch("feature")
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

        it("should force delete branch", function()
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

        it("should handle nil branch name", function()
            local success = branch.delete_branch(nil)
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
            
            local success = branch.delete_branch("feature")
            assert.is_false(success)
            assert.is_true(notify_called)
        end)
    end)

    describe("show", function()
        it("should show branch menu", function()
            local ui_select_called = false
            mock.ui.select = function(items, opts, callback)
                ui_select_called = true
                assert.is_table(items)
                assert.is_function(items[1].action)
                if callback then
                    callback(items[1])
                end
            end

            utils.execute_command = function(cmd)
                if cmd == "git branch --all" then
                    return "* main\n  develop"
                end
                return true
            end

            branch.show()
            assert.is_true(ui_select_called)
        end)

        it("should handle branch action selection", function()
            local branch_menu_shown = false
            mock.ui.select = function(items, opts, callback)
                if not branch_menu_shown then
                    branch_menu_shown = true
                    -- Simuler la sélection d'une branche
                    for _, item in ipairs(items) do
                        if type(item.text) == "string" and item.text:match("main") then
                            callback(item)
                            break
                        end
                    end
                else
                    -- Simuler la sélection d'une action
                    callback(items[1])
                end
            end

            utils.execute_command = function(cmd)
                if cmd == "git branch --all" then
                    return "* main\n  develop"
                end
                return true
            end

            branch.show()
            assert.is_true(branch_menu_shown)
        end)
    end)

    describe("setup", function()
        it("should handle nil options", function()
            branch.setup(nil)
            -- Pas d'erreur signifie succès
            assert.is_true(true)
        end)

        it("should handle empty options", function()
            branch.setup({})
            -- Pas d'erreur signifie succès
            assert.is_true(true)
        end)
    end)
end)
