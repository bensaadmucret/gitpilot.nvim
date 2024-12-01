describe("Branch Module", function()
    local branch = require("gitpilot.features.branch")
    local utils = require("gitpilot.utils")
    
    -- Mock de la fonction execute_command
    local original_execute_command
    before_each(function()
        original_execute_command = utils.execute_command
        utils.execute_command = function(cmd)
            return "mock output"
        end
    end)
    
    after_each(function()
        utils.execute_command = original_execute_command
    end)
    
    describe("list_branches", function()
        it("should return a list of branches", function()
            utils.execute_command = function(cmd)
                return "* main\n  develop\n  feature/test"
            end
            local branches = branch.list_branches()
            assert.are.same({"main", "develop", "feature/test"}, branches)
        end)
        
        it("should return empty table when no branches", function()
            utils.execute_command = function(cmd)
                return nil
            end
            local branches = branch.list_branches()
            assert.are.same({}, branches)
        end)
    end)
    
    describe("create_branch", function()
        it("should create a new branch successfully", function()
            utils.execute_command = function(cmd)
                return true
            end
            local success, _ = branch.create_branch("feature/new")
            assert.is_true(success)
        end)
        
        it("should fail with empty branch name", function()
            local success, message = branch.create_branch("")
            assert.is_false(success)
        end)
    end)
    
    describe("switch_branch", function()
        it("should switch branch successfully", function()
            utils.execute_command = function(cmd)
                return true
            end
            local success, _ = branch.switch_branch("develop")
            assert.is_true(success)
        end)
        
        it("should fail with empty branch name", function()
            local success, message = branch.switch_branch("")
            assert.is_false(success)
        end)
    end)
    
    describe("merge_branch", function()
        it("should merge branch successfully", function()
            utils.execute_command = function(cmd)
                return true
            end
            local success, _ = branch.merge_branch("feature/test")
            assert.is_true(success)
        end)
        
        it("should fail with empty branch name", function()
            local success, message = branch.merge_branch("")
            assert.is_false(success)
        end)
    end)
    
    describe("delete_branch", function()
        it("should delete branch successfully", function()
            utils.execute_command = function(cmd)
                return true
            end
            local success, _ = branch.delete_branch("feature/old")
            assert.is_true(success)
        end)
        
        it("should force delete branch successfully", function()
            utils.execute_command = function(cmd)
                return true
            end
            local success, _ = branch.delete_branch("feature/old", true)
            assert.is_true(success)
        end)
        
        it("should fail with empty branch name", function()
            local success, message = branch.delete_branch("")
            assert.is_false(success)
        end)
    end)
    
    describe("get_current_branch", function()
        it("should return current branch name", function()
            utils.execute_command = function(cmd)
                return "main\n"
            end
            local current = branch.get_current_branch()
            assert.are.equal("main", current)
        end)
        
        it("should return nil when command fails", function()
            utils.execute_command = function(cmd)
                return nil
            end
            local current = branch.get_current_branch()
            assert.is_nil(current)
        end)
    end)
end)
