local assert = require('luassert')
local ui = require('gitpilot.ui')

describe('ui', function()
  before_each(function()
    -- Reset UI state before each test
    ui.setup({})
    -- Clear any previous notifications
    ui.last_notification = nil
  end)

  describe('setup', function()
    it('should use default values when no options provided', function()
      ui.setup({})
      local window = ui.create_floating_window('Test', {'Line 1'})
      assert.equals(60, window.width)
      assert.equals(20, window.height)
      assert.equals('rounded', window.border)
    end)

    it('should override default values with provided options', function()
      ui.setup({
        ui = {
          window = {
            width = 80,
            height = 30,
            border = 'single'
          }
        }
      })
      local window = ui.create_floating_window('Test', {'Line 1'})
      assert.equals(80, window.width)
      assert.equals(30, window.height)
      assert.equals('single', window.border)
    end)
  end)

  describe('notify', function()
    it('should store notification with default level', function()
      ui.notify('Test message')
      assert.is_not_nil(ui.last_notification)
      assert.equals('Test message', ui.last_notification.message)
      assert.equals('info', ui.last_notification.level)
    end)

    it('should store notification with specified level', function()
      ui.notify('Error message', 'error')
      assert.is_not_nil(ui.last_notification)
      assert.equals('Error message', ui.last_notification.message)
      assert.equals('error', ui.last_notification.level)
    end)

    it('should handle numeric levels', function()
      ui.notify('Warning', vim.log.levels.WARN)
      assert.is_not_nil(ui.last_notification)
      assert.equals('Warning', ui.last_notification.message)
      assert.equals('info', ui.last_notification.level)  -- Numeric levels are stored as 'info'
    end)
  end)

  describe('create_floating_window', function()
    it('should create window with title and content', function()
      local window = ui.create_floating_window('Test Window', {'Line 1', 'Line 2'})
      assert.is_not_nil(window)
      assert.equals('Test Window', window.title)
      assert.same({'Line 1', 'Line 2'}, window.lines)
    end)

    it('should handle empty content', function()
      local window = ui.create_floating_window('Empty Window', {})
      assert.is_not_nil(window)
      assert.equals('Empty Window', window.title)
      assert.same({}, window.lines)
    end)

    it('should handle options', function()
      local window = ui.create_floating_window('Test', {'Line'}, { width = 100 })
      assert.equals(100, window.width)
    end)
  end)

  describe('show_menu', function()
    it('should create menu with items', function()
      local items = {
        { text = 'Item 1', handler = function() end },
        { text = 'Item 2', handler = function() end }
      }
      local menu = ui.show_menu('Test Menu', items)
      assert.is_not_nil(menu)
      assert.equals('Test Menu', menu.title)
      assert.equals(2, #menu.items)
    end)

    it('should handle empty menu', function()
      local menu = ui.show_menu('Empty Menu', {})
      assert.is_not_nil(menu)
      assert.equals('Empty Menu', menu.title)
      assert.equals(0, #menu.items)
    end)
  end)
end)
