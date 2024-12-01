local M = {}

-- Mock modules
local mock = {
    notifications = {},
    ui_inputs = {},
    ui_selects = {},
    git_responses = {},
    windows = {}
}

-- Setup test environment
M.setup = function()
    -- Set test mode
    vim.env.GITPILOT_TEST = "1"
    
    -- Configure UI module for testing
    local ui = require('gitpilot.ui')
    ui.setup({ ui = { test_mode = true } })

    -- Configure i18n module for testing
    local i18n = require('gitpilot.i18n')
    i18n.setup({ test_mode = true })

    -- Reset mocks
    mock.notifications = {}
    mock.ui_inputs = {}
    mock.ui_selects = {}
    mock.git_responses = {}
    mock.windows = {}
end

-- Reset test environment
M.teardown = function()
    vim.env.GITPILOT_TEST = nil
    vim.env.UI_INPUT_RESPONSE = nil
    vim.env.UI_SELECT_INDEX = nil
    vim.env.GIT_RESPONSE = nil
end

-- Mock UI input response
M.mock_input = function(response)
    vim.env.UI_INPUT_RESPONSE = response
end

-- Mock UI select response
M.mock_select = function(index)
    vim.env.UI_SELECT_INDEX = tostring(index)
end

-- Mock git command response
M.mock_git = function(response)
    vim.env.GIT_RESPONSE = response
end

-- Get last notification
M.get_last_notification = function()
    local ui = require('gitpilot.ui')
    return ui.last_notification
end

-- Get last window
M.get_last_window = function()
    local ui = require('gitpilot.ui')
    return ui.last_window
end

-- Assert notification was sent
M.assert_notification = function(expected_msg, expected_level)
    local notification = M.get_last_notification()
    assert(notification, "No notification was sent")
    assert(notification.message == expected_msg, 
        string.format("Expected notification message '%s', got '%s'", 
            expected_msg, notification.message))
    if expected_level then
        assert(notification.level == expected_level,
            string.format("Expected notification level '%s', got '%s'",
                expected_level, notification.level))
    end
end

-- Assert window was created
M.assert_window = function(expected_title, expected_content)
    local window = M.get_last_window()
    assert(window, "No window was created")
    if expected_title then
        assert(window.title == expected_title,
            string.format("Expected window title '%s', got '%s'",
                expected_title, window.title))
    end
    if expected_content then
        if type(expected_content) == "string" then
            expected_content = vim.split(expected_content, "\n")
        end
        assert(vim.deep_equal(window.content, expected_content),
            string.format("Expected window content '%s', got '%s'",
                vim.inspect(expected_content), vim.inspect(window.content)))
    end
end

-- Create temporary directory
M.create_temp_dir = function()
    local handle = io.popen("mktemp -d")
    local temp_dir = handle:read("*a"):gsub("\n", "")
    handle:close()
    return temp_dir
end

-- Remove temporary directory
M.remove_temp_dir = function(dir)
    os.execute("rm -rf " .. dir)
end

-- Initialize git repository
M.init_git_repo = function(dir)
    os.execute(string.format("cd %s && git init", dir))
end

return M
