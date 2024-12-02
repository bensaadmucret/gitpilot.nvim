-- tests/features/ui_spec.lua

describe("UI Module", function()
    local ui
    local mock_api = {
        nvim_create_buf = function() return 1 end,
        nvim_buf_set_option = function() end,
        nvim_buf_set_lines = function() end,
        nvim_open_win = function() return 1 end,
        nvim_win_set_option = function() end,
        nvim_buf_set_keymap = function() end
    }
    
    before_each(function()
        -- Sauvegarde l'API originale
        _G._saved_vim = vim
        -- Mock vim global
        _G.vim = {
            api = mock_api,
            split = function(str, sep)
                local t = {}
                for s in string.gmatch(str, "[^"..sep.."]+") do
                    table.insert(t, s)
                end
                return t
            end,
            tbl_deep_extend = function(behavior, ...)
                local result = {}
                for i = 1, select("#", ...) do
                    local t = select(i, ...)
                    for k, v in pairs(t) do
                        result[k] = v
                    end
                end
                return result
            end,
            fn = {
                strdisplaywidth = function(str) return #str end
            },
            o = {
                lines = 24,
                columns = 80
            }
        }
        
        ui = require('gitpilot.ui')
    end)
    
    after_each(function()
        -- Restore l'API originale
        _G.vim = _G._saved_vim
        package.loaded['gitpilot.ui'] = nil
    end)
    
    describe("create_floating_window", function()
        it("should create a window with single line content", function()
            local content = "Test message"
            local buf, win = ui.create_floating_window(content)
            
            assert.is_not_nil(buf)
            assert.is_not_nil(win)
            assert.equals(1, buf)
            assert.equals(1, win)
        end)
        
        it("should create a window with multiline content", function()
            local content = "Line 1\nLine 2\nLine 3"
            local buf, win = ui.create_floating_window(content)
            
            assert.is_not_nil(buf)
            assert.is_not_nil(win)
        end)
        
        it("should create a window with custom options", function()
            local opts = {
                title = "Custom Title",
                border = "single"
            }
            local buf, win = ui.create_floating_window("Test", opts)
            
            assert.is_not_nil(buf)
            assert.is_not_nil(win)
        end)
    end)
    
    describe("show_error", function()
        it("should display error message", function()
            local title = "Error"
            local message = "Test error message"
            
            spy.on(mock_api, "nvim_buf_set_lines")
            
            ui.show_error(title, message)
            
            assert.spy(mock_api.nvim_buf_set_lines).was_called()
        end)
        
        it("should handle multiline error messages", function()
            local title = "Error"
            local message = "Line 1\nLine 2\nLine 3"
            
            spy.on(mock_api, "nvim_buf_set_lines")
            
            ui.show_error(title, message)
            
            assert.spy(mock_api.nvim_buf_set_lines).was_called()
        end)
    end)
    
    describe("show_info", function()
        it("should display info message", function()
            local title = "Info"
            local message = "Test info message"
            
            spy.on(mock_api, "nvim_buf_set_lines")
            
            ui.show_info(title, message)
            
            assert.spy(mock_api.nvim_buf_set_lines).was_called()
        end)
        
        it("should handle multiline info messages", function()
            local title = "Info"
            local message = "Line 1\nLine 2\nLine 3"
            
            spy.on(mock_api, "nvim_buf_set_lines")
            
            ui.show_info(title, message)
            
            assert.spy(mock_api.nvim_buf_set_lines).was_called()
        end)
    end)
end)
