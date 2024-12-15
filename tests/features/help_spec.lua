-- tests/features/help_spec.lua

local help = require('gitpilot.features.help')
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')
local mock = require('luassert.mock')

describe("help", function()
    local ui_mock
    local vim_mock

    before_each(function()
        ui_mock = mock(ui, true)
        -- Mock vim global
        vim_mock = {
            split = function(str, sep, opts)
                if not str then return {} end
                local result = {}
                local pattern = string.format("[^%s]+", sep)
                for match in str:gmatch(pattern) do
                    table.insert(result, match)
                end
                return result
            end,
            tbl_deep_extend = function(behavior, ...)
                return vim.tbl_deep_extend(behavior, ...)
            end
        }
        _G.vim = vim_mock
    end)

    after_each(function()
        mock.revert(ui_mock)
        _G.vim = nil
    end)

    describe("show_help", function()
        it("should show error when command does not exist", function()
            help.show_help("invalid_command")
            assert.stub(ui_mock.show_error).was_called(1)
            assert.stub(ui_mock.show_error).was_called_with(i18n.t("help.command_not_found"))
        end)

        it("should show help for commit command", function()
            help.show_help("commit")
            assert.stub(ui_mock.float_window).was_called(1)
            local call_args = ui_mock.float_window.calls[1]
            local content = call_args.refs[1]
            
            assert.truthy(content:match("# Git Commit"))
            assert.truthy(content:match("Create a new commit"))
            assert.truthy(content:match("## Usage"))
            assert.truthy(content:match("git commit %-m"))
        end)

        it("should show help for branch command with all sections", function()
            help.show_help("branch")
            assert.stub(ui_mock.float_window).was_called(1)
            local call_args = ui_mock.float_window.calls[1]
            local content = call_args.refs[1]
            
            assert.truthy(content:match("# Git Branch"))
            assert.truthy(content:match("Manage branches"))
            assert.truthy(content:match("## Usage"))
            assert.truthy(content:match("## Common Flags"))
            assert.truthy(content:match("## Tips"))
        end)

        it("should include all common flags in help content", function()
            help.show_help("commit")
            assert.stub(ui_mock.float_window).was_called(1)
            local call_args = ui_mock.float_window.calls[1]
            local content = call_args.refs[1]
            
            assert.truthy(content:match("* %-m:"))
            assert.truthy(content:match("* %-a:"))
            assert.truthy(content:match("* %-%-amend:"))
            assert.truthy(content:match("Add commit message"))
            assert.truthy(content:match("Commit all modified"))
            assert.truthy(content:match("Modify the last commit"))
        end)

        it("should include multiple tips in help content", function()
            help.show_help("commit")
            assert.stub(ui_mock.float_window).was_called(1)
            local call_args = ui_mock.float_window.calls[1]
            local content = call_args.refs[1]
            
            local tips_count = select(2, content:gsub("* Write", ""))
            assert.is_true(tips_count >= 1)
        end)

        it("should show help for stash command with correct formatting", function()
            help.show_help("stash")
            assert.stub(ui_mock.float_window).was_called(1)
            local call_args = ui_mock.float_window.calls[1]
            local content = call_args.refs[1]
            
            assert.truthy(content:match("# Git Stash"))
            assert.truthy(content:match("## Usage"))
            assert.truthy(content:match("## Common Flags"))
            assert.truthy(content:match("## Tips"))
        end)

        it("should show help for rebase command with complete information", function()
            help.show_help("rebase")
            assert.stub(ui_mock.float_window).was_called(1)
            local call_args = ui_mock.float_window.calls[1]
            local content = call_args.refs[1]
            
            assert.truthy(content:match("Interactive rebase"))
            assert.truthy(content:match("* %-%-onto:"))
            assert.truthy(content:match("* %-%-continue:"))
            assert.truthy(content:match("Don't rebase published"))
        end)

        it("should show help for tag command with all details", function()
            help.show_help("tag")
            assert.stub(ui_mock.float_window).was_called(1)
            local call_args = ui_mock.float_window.calls[1]
            local content = call_args.refs[1]
            
            assert.truthy(content:match("Create annotated tag"))
            assert.truthy(content:match("semantic versioning"))
            assert.truthy(content:match("git push %-%-tags"))
        end)
    end)
end)
