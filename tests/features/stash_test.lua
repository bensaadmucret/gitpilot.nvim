local stash = require('gitpilot.features.stash')
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

-- Test list_stash function
function test.test_list_stash()
    setup()
    
    -- Test empty stash list
    local mock_git_command = function() error("Git error") end
    utils.original_git_command = utils.git_command
    utils.git_command = mock_git_command
    
    local stashes = stash.list_stash()
    assert(#stashes == 0, "Expected empty stash list")
    test_helpers.assert_notification("error", "stash.error.list")
    
    teardown()
    
    -- Test single stash
    mock_git_command = function() return "stash@{0}|abc123|Test stash" end
    utils.git_command = mock_git_command
    
    stashes = stash.list_stash()
    assert(#stashes == 1, "Expected one stash")
    assert(stashes[1].ref == "stash@{0}", "Expected stash ref to be 'stash@{0}'")
    assert(stashes[1].hash == "abc123", "Expected stash hash to be 'abc123'")
    assert(stashes[1].message == "Test stash", "Expected stash message to be 'Test stash'")
    
    teardown()
    
    -- Test multiple stashes
    mock_git_command = function() 
        return "stash@{0}|abc123|Test stash 1\nstash@{1}|def456|Test stash 2" 
    end
    utils.git_command = mock_git_command
    
    stashes = stash.list_stash()
    assert(#stashes == 2, "Expected two stashes")
    assert(stashes[1].ref == "stash@{0}", "Expected first stash ref")
    assert(stashes[2].ref == "stash@{1}", "Expected second stash ref")
    
    teardown()
end

-- Test create_stash function
function test.test_create_stash()
    setup()
    
    -- Test no changes to stash
    local mock_git_command = function() return "" end
    utils.original_git_command = utils.git_command
    utils.git_command = mock_git_command
    
    local result = stash.create_stash()
    assert(result == false, "Expected false when no changes")
    test_helpers.assert_notification("warn", "stash.no_changes")
    
    teardown()
    
    -- Test with changes
    mock_git_command = function() return " M file1.txt\n?? file2.txt" end
    utils.git_command = mock_git_command
    
    result = stash.create_stash()
    assert(result == true, "Expected true when stash created")
    test_helpers.assert_notification("info", "stash.created")
    
    teardown()
    
    -- Test stash creation error
    mock_git_command = function() error("Git error") end
    utils.git_command = mock_git_command
    
    result = stash.create_stash()
    assert(result == false, "Expected false when error")
    test_helpers.assert_notification("error", "stash.error.create")
    
    teardown()
end

-- Test apply_stash function
function test.test_apply_stash()
    setup()
    
    -- Test with no stashes
    local mock_git_command = function() return "" end
    utils.original_git_command = utils.git_command
    utils.git_command = mock_git_command
    
    local result = stash.apply_stash()
    assert(result == false, "Expected false when no stashes")
    test_helpers.assert_notification("warn", "stash.none")
    
    teardown()
    
    -- Test successful stash apply
    mock_git_command = function() return "stash@{0}|abc123|Test stash" end
    utils.git_command = mock_git_command
    
    result = stash.apply_stash()
    assert(result == true, "Expected true when stash applied")
    test_helpers.assert_notification("info", "stash.applied")
    
    teardown()
    
    -- Test stash apply error
    mock_git_command = function() error("Git error") end
    utils.git_command = mock_git_command
    
    result = stash.apply_stash()
    assert(result == false, "Expected false when error")
    test_helpers.assert_notification("error", "stash.error.apply")
    
    teardown()
end

-- Test delete_stash function
function test.test_delete_stash()
    setup()
    
    -- Test with no stashes
    local mock_git_command = function() return "" end
    utils.original_git_command = utils.git_command
    utils.git_command = mock_git_command
    
    local result = stash.delete_stash()
    assert(result == false, "Expected false when no stashes")
    test_helpers.assert_notification("warn", "stash.none")
    
    teardown()
    
    -- Test successful stash delete
    mock_git_command = function() return "stash@{0}|abc123|Test stash" end
    utils.git_command = mock_git_command
    
    result = stash.delete_stash()
    assert(result == true, "Expected true when stash deleted")
    test_helpers.assert_notification("info", "stash.deleted")
    
    teardown()
    
    -- Test stash delete error
    mock_git_command = function() error("Git error") end
    utils.git_command = mock_git_command
    
    result = stash.delete_stash()
    assert(result == false, "Expected false when error")
    test_helpers.assert_notification("error", "stash.error.delete")
    
    teardown()
end

-- Test malformed stash output
function test.test_malformed_stash_output()
    setup()
    
    -- Test malformed stash entry
    local mock_git_command = function() return "malformed_stash_entry" end
    utils.original_git_command = utils.git_command
    utils.git_command = mock_git_command
    
    local stashes = stash.list_stash()
    assert(#stashes == 0, "Expected empty list for malformed stash entry")
    
    teardown()
end

return test
