local tags = require('gitpilot.features.tags')
local utils = require('gitpilot.utils')
local test_helpers = require('tests.test_helpers')

local test = {}

-- Setup function to run before each test
local function setup()
    -- Reset test state
    test_helpers.reset()
end

-- Teardown function to run after each test
local function teardown()
    -- Restore original functions
    utils.git_command = utils.original_git_command
end

-- Test list_tags function
function test.test_list_tags()
    setup()
    
    -- Test empty tags list
    local mock_git_command = function() error("Git error") end
    utils.original_git_command = utils.git_command
    utils.git_command = mock_git_command
    
    local tags_list = tags.list_tags()
    assert(#tags_list == 0, "Expected empty tags list")
    test_helpers.assert_notification("error", "tags.error.list")
    
    teardown()
    
    -- Test single tag
    mock_git_command = function() return "v1.0|abc123|First release" end
    utils.git_command = mock_git_command
    
    tags_list = tags.list_tags()
    assert(#tags_list == 1, "Expected one tag")
    assert(tags_list[1].name == "v1.0", "Expected tag name to be 'v1.0'")
    assert(tags_list[1].hash == "abc123", "Expected tag hash to be 'abc123'")
    assert(tags_list[1].message == "First release", "Expected tag message")
    
    teardown()
    
    -- Test multiple tags
    mock_git_command = function() 
        return "v1.0|abc123|First release\nv2.0|def456|Second release" 
    end
    utils.git_command = mock_git_command
    
    tags_list = tags.list_tags()
    assert(#tags_list == 2, "Expected two tags")
    assert(tags_list[1].name == "v1.0", "Expected first tag name")
    assert(tags_list[2].name == "v2.0", "Expected second tag name")
    
    teardown()
end

-- Test create_tag function
function test.test_create_tag()
    setup()
    
    -- Test invalid tag name
    local result = tags.create_tag("", "Test message")
    assert(result == false, "Expected false for empty tag name")
    test_helpers.assert_notification("warn", "tags.create.invalid_name")
    
    -- Test successful lightweight tag creation
    local mock_git_command = function() return "" end
    utils.original_git_command = utils.git_command
    utils.git_command = mock_git_command
    
    result = tags.create_tag("v1.0", "")
    assert(result == true, "Expected true for lightweight tag creation")
    test_helpers.assert_notification("info", "tags.created")
    
    teardown()
    
    -- Test successful annotated tag creation
    mock_git_command = function() return "tag v1.0 created" end
    utils.git_command = mock_git_command
    
    result = tags.create_tag("v1.0", "Test message")
    assert(result == true, "Expected true for annotated tag creation")
    test_helpers.assert_notification("info", "tags.created")
    
    teardown()
    
    -- Test tag creation error
    mock_git_command = function() error("Git error") end
    utils.git_command = mock_git_command
    
    result = tags.create_tag("v1.0", "Test message")
    assert(result == false, "Expected false when error")
    test_helpers.assert_notification("error", "tags.error.create")
    
    teardown()
end

-- Test push_tag function
function test.test_push_tag()
    setup()
    
    -- Test invalid tag name
    local result = tags.push_tag("")
    assert(result == false, "Expected false for empty tag name")
    test_helpers.assert_notification("warn", "tags.push.invalid_name")
    
    -- Test successful tag push
    local mock_git_command = function() return "" end
    utils.original_git_command = utils.git_command
    utils.git_command = mock_git_command
    
    result = tags.push_tag("v1.0")
    assert(result == true, "Expected true when tag pushed")
    test_helpers.assert_notification("info", "tags.pushed")
    
    teardown()
    
    -- Test tag push error
    mock_git_command = function() error("Git error") end
    utils.git_command = mock_git_command
    
    result = tags.push_tag("v1.0")
    assert(result == false, "Expected false when error")
    test_helpers.assert_notification("error", "tags.error.push")
    
    teardown()
end

-- Test delete_tag function
function test.test_delete_tag()
    setup()
    
    -- Test invalid tag name
    local result = tags.delete_tag("")
    assert(result == false, "Expected false for empty tag name")
    test_helpers.assert_notification("warn", "tags.delete.invalid_name")
    
    -- Test successful tag deletion
    local mock_git_command = function() return "" end
    utils.original_git_command = utils.git_command
    utils.git_command = mock_git_command
    
    result = tags.delete_tag("v1.0")
    assert(result == true, "Expected true when tag deleted")
    test_helpers.assert_notification("info", "tags.deleted")
    
    teardown()
    
    -- Test tag deletion error
    mock_git_command = function() error("Git error") end
    utils.git_command = mock_git_command
    
    result = tags.delete_tag("v1.0")
    assert(result == false, "Expected false when error")
    test_helpers.assert_notification("error", "tags.error.delete")
    
    teardown()
end

-- Test delete_remote_tag function
function test.test_delete_remote_tag()
    setup()
    
    -- Test invalid tag name
    local result = tags.delete_remote_tag("")
    assert(result == false, "Expected false for empty tag name")
    test_helpers.assert_notification("warn", "tags.delete_remote.invalid_name")
    
    -- Test successful remote tag deletion
    local mock_git_command = function() return "" end
    utils.original_git_command = utils.git_command
    utils.git_command = mock_git_command
    
    result = tags.delete_remote_tag("v1.0")
    assert(result == true, "Expected true when remote tag deleted")
    test_helpers.assert_notification("info", "tags.deleted_remote")
    
    teardown()
    
    -- Test remote tag deletion error
    mock_git_command = function() error("Git error") end
    utils.git_command = mock_git_command
    
    result = tags.delete_remote_tag("v1.0")
    assert(result == false, "Expected false when error")
    test_helpers.assert_notification("error", "tags.error.delete_remote")
    
    teardown()
end

-- Test malformed tag output
function test.test_malformed_tag_output()
    setup()
    
    -- Test malformed tag entry
    local mock_git_command = function() return "malformed_tag_entry" end
    utils.original_git_command = utils.git_command
    utils.git_command = mock_git_command
    
    local tags_list = tags.list_tags()
    assert(#tags_list == 0, "Expected empty list for malformed tag entry")
    
    teardown()
end

return test
