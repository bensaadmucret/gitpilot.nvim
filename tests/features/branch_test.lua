local branch = require('gitpilot.features.branch')
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

-- Test list_branches function
function test.test_list_branches()
    setup()
    
    -- Test empty branch list
    local mock_git_command = function() error("Git error") end
    utils.original_git_command = utils.git_command
    utils.git_command = mock_git_command
    
    local branches = branch.list_branches()
    assert(#branches == 0, "Expected empty branch list")
    test_helpers.assert_notification("error", "branch.error.list")
    
    teardown()
    
    -- Test single branch
    mock_git_command = function() return "* main" end
    utils.git_command = mock_git_command
    
    branches = branch.list_branches()
    assert(#branches == 1, "Expected one branch")
    assert(branches[1] == "main", "Expected branch name to be 'main'")
    
    teardown()
    
    -- Test multiple branches
    mock_git_command = function() return "* main\n  develop\n  feature/test" end
    utils.git_command = mock_git_command
    
    branches = branch.list_branches()
    assert(#branches == 3, "Expected three branches")
    assert(branches[1] == "main", "Expected first branch to be 'main'")
    assert(branches[2] == "develop", "Expected second branch to be 'develop'")
    assert(branches[3] == "feature/test", "Expected third branch to be 'feature/test'")
    
    teardown()
end

-- Test get_current_branch function
function test.test_get_current_branch()
    setup()
    
    -- Test error case
    local mock_git_command = function() error("Git error") end
    utils.original_git_command = utils.git_command
    utils.git_command = mock_git_command
    
    local current = branch.get_current_branch()
    assert(current == nil, "Expected nil when git command fails")
    test_helpers.assert_notification("error", "branch.error.current")
    
    teardown()
    
    -- Test successful case
    mock_git_command = function() return "main" end
    utils.git_command = mock_git_command
    
    current = branch.get_current_branch()
    assert(current == "main", "Expected current branch to be 'main'")
    
    teardown()
end

-- Test create_branch function
function test.test_create_branch()
    setup()
    
    -- Test invalid branch name
    branch.create_branch("")
    test_helpers.assert_notification("warn", "branch.create.invalid")
    
    teardown()
    
    -- Test error case
    local mock_git_command = function() error("Git error") end
    utils.original_git_command = utils.git_command
    utils.git_command = mock_git_command
    
    branch.create_branch("feature/test")
    test_helpers.assert_notification("error", "branch.create.error")
    
    teardown()
    
    -- Test successful case
    mock_git_command = function() return "" end
    utils.git_command = mock_git_command
    
    branch.create_branch("feature/test")
    test_helpers.assert_notification("info", "branch.create.success")
    
    teardown()
end

-- Test switch_branch function
function test.test_switch_branch()
    setup()
    
    -- Test error case
    local mock_git_command = function() error("Git error") end
    utils.original_git_command = utils.git_command
    utils.git_command = mock_git_command
    
    branch.switch_branch("develop")
    test_helpers.assert_notification("error", "branch.switch.error")
    
    teardown()
    
    -- Test successful case
    mock_git_command = function() return "" end
    utils.git_command = mock_git_command
    
    branch.switch_branch("develop")
    test_helpers.assert_notification("info", "branch.switch.success")
    
    teardown()
end

-- Test merge_branch function
function test.test_merge_branch()
    setup()
    
    -- Test error case
    local mock_git_command = function() error("Git error") end
    utils.original_git_command = utils.git_command
    utils.git_command = mock_git_command
    
    branch.merge_branch("feature/test")
    test_helpers.assert_notification("error", "branch.merge.error")
    
    teardown()
    
    -- Test successful case
    mock_git_command = function() return "" end
    utils.git_command = mock_git_command
    
    branch.merge_branch("feature/test")
    test_helpers.assert_notification("info", "branch.merge.success")
    
    teardown()
end

-- Test delete_branch function
function test.test_delete_branch()
    setup()
    
    -- Test error case
    local mock_git_command = function() error("Git error") end
    utils.original_git_command = utils.git_command
    utils.git_command = mock_git_command
    
    branch.delete_branch("old-feature")
    test_helpers.assert_notification("error", "branch.delete.error")
    
    teardown()
    
    -- Test successful case
    mock_git_command = function() return "" end
    utils.git_command = mock_git_command
    
    branch.delete_branch("old-feature")
    test_helpers.assert_notification("info", "branch.delete.success")
    
    teardown()
end

return test
