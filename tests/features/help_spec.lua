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
                return vim.split(str, sep, opts)
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
            assert.stub(ui_mock.show_text_window).was_called(1)
            local call_args = ui_mock.show_text_window.calls[1]
            local content = call_args.refs[1]
            
            -- Vérifier le titre
            assert.equals("Git Commit", content[1])
            -- Vérifier la présence de la description
            assert.truthy(table.concat(content, "\n"):match("Create a new commit"))
            -- Vérifier la présence de l'usage
            assert.truthy(table.concat(content, "\n"):match("git commit %-m"))
        end)

        it("should show help for branch command with all sections", function()
            help.show_help("branch")
            assert.stub(ui_mock.show_text_window).was_called(1)
            local call_args = ui_mock.show_text_window.calls[1]
            local content = call_args.refs[1]
            local content_str = table.concat(content, "\n")
            
            -- Vérifier toutes les sections
            assert.truthy(content_str:match("Git Branch"))
            assert.truthy(content_str:match("Description:"))
            assert.truthy(content_str:match("Usage:"))
            assert.truthy(content_str:match("Common Flags:"))
            assert.truthy(content_str:match("Tips:"))
        end)

        it("should include all common flags in help content", function()
            help.show_help("commit")
            assert.stub(ui_mock.show_text_window).was_called(1)
            local call_args = ui_mock.show_text_window.calls[1]
            local content = call_args.refs[1]
            local content_str = table.concat(content, "\n")
            
            -- Vérifier la présence de tous les flags communs
            assert.truthy(content_str:match("%-m"))
            assert.truthy(content_str:match("%-a"))
            assert.truthy(content_str:match("%-%-amend"))
            
            -- Vérifier que les descriptions des flags sont présentes
            assert.truthy(content_str:match("Add commit message"))
            assert.truthy(content_str:match("Commit all modified"))
            assert.truthy(content_str:match("Modify the last commit"))
        end)

        it("should include multiple tips in help content", function()
            help.show_help("commit")
            assert.stub(ui_mock.show_text_window).was_called(1)
            local call_args = ui_mock.show_text_window.calls[1]
            local content = call_args.refs[1]
            local content_str = table.concat(content, "\n")
            
            -- Vérifier la présence de plusieurs conseils
            local tips_count = select(2, content_str:gsub("•", ""))
            assert.is_true(tips_count >= 3)
        end)

        it("should show help for stash command with correct formatting", function()
            help.show_help("stash")
            assert.stub(ui_mock.show_text_window).was_called(1)
            local call_args = ui_mock.show_text_window.calls[1]
            local content = call_args.refs[1]
            local content_str = table.concat(content, "\n")
            
            -- Vérifier le formatage
            assert.truthy(content_str:match("^Git Stash\n=+\n"))
            assert.truthy(content_str:match("\nUsage:\n"))
            assert.truthy(content_str:match("\nCommon Flags:\n"))
            assert.truthy(content_str:match("\nTips:\n"))
        end)

        it("should show help for rebase command with complete information", function()
            help.show_help("rebase")
            assert.stub(ui_mock.show_text_window).was_called(1)
            local call_args = ui_mock.show_text_window.calls[1]
            local content = call_args.refs[1]
            local content_str = table.concat(content, "\n")
            
            -- Vérifier les informations spécifiques au rebase
            assert.truthy(content_str:match("Interactive rebase"))
            assert.truthy(content_str:match("%-%-onto"))
            assert.truthy(content_str:match("%-%-continue"))
            assert.truthy(content_str:match("Don't rebase published"))
        end)

        it("should show help for tag command with all details", function()
            help.show_help("tag")
            assert.stub(ui_mock.show_text_window).was_called(1)
            local call_args = ui_mock.show_text_window.calls[1]
            local content = call_args.refs[1]
            local content_str = table.concat(content, "\n")
            
            -- Vérifier les détails spécifiques aux tags
            assert.truthy(content_str:match("Create annotated tag"))
            assert.truthy(content_str:match("semantic versioning"))
            assert.truthy(content_str:match("git push %-%-tags"))
        end)

        it("should handle window options correctly", function()
            help.show_help("commit")
            assert.stub(ui_mock.show_text_window).was_called(1)
            local call_args = ui_mock.show_text_window.calls[1]
            local opts = call_args.refs[2]
            
            -- Vérifier les options de la fenêtre
            assert.truthy(opts.title:match("Git Help"))
            assert.equals(60, opts.width)
            assert.equals(20, opts.height)
        end)
    end)
end)
