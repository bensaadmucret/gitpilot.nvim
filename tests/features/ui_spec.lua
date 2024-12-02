-- tests/features/ui_spec.lua

describe("UI Module", function()
    local ui
    local mock_i18n
    local mock_vim
    
    before_each(function()
        -- Mock i18n
        mock_i18n = {
            t = function(key, vars) 
                return vars and string.format("%s with vars", key) or key
            end
        }
        package.loaded['gitpilot.i18n'] = mock_i18n

        -- Mock vim global
        mock_vim = {
            notify = function() end,
            log = {
                levels = {
                    ERROR = 1,
                    WARN = 2,
                    INFO = 3
                }
            },
            ui = {
                select = function() end
            }
        }
        _G.vim = mock_vim
        
        -- Setup spies
        spy.on(mock_vim, "notify")
        spy.on(mock_vim.ui, "select")
        spy.on(mock_i18n, "t")
        
        -- Charger le module UI
        package.loaded['gitpilot.ui'] = nil
        ui = require('gitpilot.ui')
    end)
    
    after_each(function()
        -- Cleanup
        package.loaded['gitpilot.i18n'] = nil
        package.loaded['gitpilot.ui'] = nil
        _G.vim = nil
    end)

    describe("notifications", function()
        it("should show error message", function()
            ui.show_error("test.error", { var = "value" })
            assert.spy(mock_i18n.t).was.called_with("test.error", { var = "value" })
            assert.spy(mock_vim.notify).was.called_with(
                "test.error with vars",
                mock_vim.log.levels.ERROR
            )
        end)

        it("should show info message", function()
            ui.show_info("test.info", { var = "value" })
            assert.spy(mock_i18n.t).was.called_with("test.info", { var = "value" })
            assert.spy(mock_vim.notify).was.called_with(
                "test.info with vars",
                mock_vim.log.levels.INFO
            )
        end)

        it("should show warning message", function()
            ui.show_warning("test.warning", { var = "value" })
            assert.spy(mock_i18n.t).was.called_with("test.warning", { var = "value" })
            assert.spy(mock_vim.notify).was.called_with(
                "test.warning with vars",
                mock_vim.log.levels.WARN
            )
        end)

        it("should handle messages without variables", function()
            ui.show_info("test.simple")
            assert.spy(mock_i18n.t).was.called_with("test.simple")
            assert.spy(mock_vim.notify).was.called_with(
                "test.simple",
                mock_vim.log.levels.INFO
            )
        end)
    end)

    describe("select", function()
        it("should handle empty items list", function()
            ui.select({}, {}, function() end)
            assert.spy(mock_vim.notify).was.called_with(
                "ui.no_items",
                mock_vim.log.levels.ERROR
            )
        end)

        it("should handle nil items", function()
            ui.select(nil, {}, function() end)
            assert.spy(mock_vim.notify).was.called_with(
                "ui.no_items",
                mock_vim.log.levels.ERROR
            )
        end)

        it("should call vim.ui.select with valid items", function()
            local items = {"item1", "item2"}
            local opts = {prompt = "Select:"}
            local callback = function() end

            ui.select(items, opts, callback)
            assert.spy(mock_vim.ui.select).was.called_with(items, opts, match.is_function())
        end)

        it("should handle selection callback", function()
            local called_with = nil
            local callback = function(choice) called_with = choice end

            ui.select({"item1"}, {}, callback)
            
            -- Get the callback function that was passed to select
            local select_callback = mock_vim.ui.select.calls[1].refs[3]
            select_callback("item1")
            
            assert.equals("item1", called_with)
        end)

        it("should not call callback when nothing is selected", function()
            local was_called = false
            local callback = function() was_called = true end

            ui.select({"item1"}, {}, callback)
            
            -- Get the callback function that was passed to select
            local select_callback = mock_vim.ui.select.calls[1].refs[3]
            select_callback(nil)
            
            assert.is_false(was_called)
        end)
    end)
end)
