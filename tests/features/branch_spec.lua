-- lua/tests/branch_spec.lua

local test_helpers = require("test_helpers")
local branch = require('gitpilot.features.branch')
local ui = require('gitpilot.ui')

describe("GitPilot Branch Feature", function()
    local mock_execute_command
    local mock_ui
    
    before_each(function()
        -- Setup test environment
        test_helpers.setup_vim_mock()
        test_helpers.setup_git_mock()
        
        -- Mock dependencies
        mock_ui = {
            show_error = function() end,
            show_info = function() end,
            show_warning = function() end
        }
        spy.on(mock_ui, "show_error")
        spy.on(mock_ui, "show_info")
        spy.on(mock_ui, "show_warning")
        package.loaded['gitpilot.ui'] = mock_ui
    end)
    
    after_each(function()
        -- Cleanup
        package.loaded['gitpilot.ui'] = nil
        test_helpers.teardown()
    end)
    
    describe("list_branches()", function()
        it("should correctly parse branch list", function()
            local utils = require('gitpilot.utils')
            spy.on(utils, "execute_command")
            utils.execute_command.returns(true, [[
  develop
* main
  feature/test
  remotes/origin/main
  remotes/origin/develop
]])
            local branches, current = branch.list_branches()
            assert.are.same({
                "develop",
                "main",
                "feature/test",
                "remotes/origin/main",
                "remotes/origin/develop"
            }, branches)
            assert.are.same("main", current)
        end)

        it("should handle empty branch list", function()
            local utils = require('gitpilot.utils')
            spy.on(utils, "execute_command")
            utils.execute_command.returns(true, "")
            local branches, current = branch.list_branches()
            assert.are.same({}, branches)
            assert.are.same("", current)
        end)

        it("should show error on git command failure", function()
            local utils = require('gitpilot.utils')
            spy.on(utils, "execute_command")
            utils.execute_command.returns(false, "")
            local branches, current = branch.list_branches()
            assert.spy(mock_ui.show_error).was.called_with("branch.list_error")
            assert.are.same({}, branches)
            assert.are.same("", current)
        end)
    end)

    describe("create_branch()", function()
        it("should create branch successfully", function()
            local utils = require('gitpilot.utils')
            spy.on(utils, "execute_command")
            utils.execute_command.returns(true, "")
            branch.create_branch("test-branch")
            assert.spy(utils.execute_command).was.called_with("git branch test-branch")
            assert.spy(mock_ui.show_info).was.called_with("branch.create_success", { name = "test-branch" })
        end)

        it("should handle creation error", function()
            local utils = require('gitpilot.utils')
            spy.on(utils, "execute_command")
            utils.execute_command.returns(false, "")
            branch.create_branch("test-branch")
            assert.spy(mock_ui.show_error).was.called_with("branch.create_error", { name = "test-branch" })
        end)

        it("should validate branch name", function()
            branch.create_branch("")
            assert.spy(mock_ui.show_error).was.called_with("branch.error.invalid_name")
            local utils = require('gitpilot.utils')
            assert.spy(utils.execute_command).was_not_called()
        end)
    end)

    describe("checkout_branch()", function()
        it("should checkout branch successfully", function()
            local utils = require('gitpilot.utils')
            spy.on(utils, "execute_command")
            utils.execute_command.returns(true, "")
            branch.checkout_branch("test-branch")
            assert.spy(utils.execute_command).was.called_with("git checkout test-branch")
            assert.spy(mock_ui.show_info).was.called_with("branch.checkout_success", { name = "test-branch" })
        end)

        it("should handle checkout error", function()
            local utils = require('gitpilot.utils')
            spy.on(utils, "execute_command")
            utils.execute_command.returns(false, "")
            branch.checkout_branch("test-branch")
            assert.spy(mock_ui.show_error).was.called_with("branch.checkout_error", { name = "test-branch" })
        end)
    end)

    describe("merge_branch()", function()
        it("should merge branch successfully", function()
            local utils = require('gitpilot.utils')
            spy.on(utils, "execute_command")
            utils.execute_command.on_call_with("git merge test-branch").returns(true, "")
            utils.execute_command.on_call_with("git status").returns(true, "")
            branch.merge_branch("test-branch")
            assert.spy(mock_ui.show_info).was.called_with("branch.merge_success", { name = "test-branch" })
        end)

        it("should handle merge conflicts", function()
            local utils = require('gitpilot.utils')
            spy.on(utils, "execute_command")
            utils.execute_command.on_call_with("git merge test-branch").returns(true, "")
            utils.execute_command.on_call_with("git status").returns(true, "Unmerged paths")
            branch.merge_branch("test-branch")
            assert.spy(mock_ui.show_warning).was.called_with("branch.merge_conflict", { name = "test-branch" })
        end)

        it("should handle merge error", function()
            local utils = require('gitpilot.utils')
            spy.on(utils, "execute_command")
            utils.execute_command.returns(false, "")
            branch.merge_branch("test-branch")
            assert.spy(mock_ui.show_error).was.called_with("branch.merge_error", { name = "test-branch" })
        end)
    end)

    describe("delete_branch()", function()
        it("should delete branch successfully", function()
            local utils = require('gitpilot.utils')
            spy.on(utils, "execute_command")
            utils.execute_command.returns(true, "")
            branch.delete_branch("test-branch")
            assert.spy(utils.execute_command).was.called_with("git branch -d test-branch")
            assert.spy(mock_ui.show_info).was.called_with("branch.delete_success", { name = "test-branch" })
        end)

        it("should force delete branch when specified", function()
            local utils = require('gitpilot.utils')
            spy.on(utils, "execute_command")
            utils.execute_command.returns(true, "")
            branch.delete_branch("test-branch", true)
            assert.spy(utils.execute_command).was.called_with("git branch -D test-branch")
            assert.spy(mock_ui.show_info).was.called_with("branch.delete_success", { name = "test-branch" })
        end)

        it("should handle deletion error", function()
            local utils = require('gitpilot.utils')
            spy.on(utils, "execute_command")
            utils.execute_command.returns(false, "")
            branch.delete_branch("test-branch")
            assert.spy(mock_ui.show_error).was.called_with("branch.delete_error", { name = "test-branch" })
        end)
    end)
end)
