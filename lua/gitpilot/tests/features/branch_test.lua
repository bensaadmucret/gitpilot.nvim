local branch = require('gitpilot.features.branch')
local utils = require('gitpilot.utils')

-- Table pour stocker les résultats des tests
local test_results = {
    passed = 0,
    failed = 0,
    errors = {}
}

-- Fonction helper pour les tests
local function assert_test(name, condition, message)
    if condition then
        test_results.passed = test_results.passed + 1
        print("✅ Test passed: " .. name)
    else
        test_results.failed = test_results.failed + 1
        table.insert(test_results.errors, {name = name, message = message})
        print("❌ Test failed: " .. name .. " - " .. message)
    end
end

-- Configuration initiale pour les tests
local function setup_test_environment()
    -- Créer un dépôt git temporaire pour les tests
    local temp_dir = os.tmpname()
    os.remove(temp_dir)  -- tmpname crée le fichier, nous voulons un répertoire
    os.execute("mkdir -p " .. temp_dir)
    os.execute("cd " .. temp_dir .. " && git init")
    
    -- Créer un fichier initial et faire un commit
    local file = io.open(temp_dir .. "/test.txt", "w")
    file:write("test content")
    file:close()
    os.execute("cd " .. temp_dir .. " && git add test.txt && git commit -m 'Initial commit'")
    
    return temp_dir
end

-- Nettoyage après les tests
local function cleanup_test_environment(temp_dir)
    os.execute("rm -rf " .. temp_dir)
end

-- Test de création de branche
local function test_create_branch()
    local temp_dir = setup_test_environment()
    
    -- Test de création de branche
    local result = branch.create_branch("test-branch")
    assert_test(
        "Create branch",
        result.success,
        "Should successfully create a new branch"
    )
    
    -- Vérifier que la branche existe
    local branches = utils.git_command("branch --list test-branch")
    assert_test(
        "Branch exists",
        branches.success and branches.output:match("test%-branch"),
        "New branch should exist in branch list"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de changement de branche
local function test_switch_branch()
    local temp_dir = setup_test_environment()
    
    -- Créer une branche pour le test
    branch.create_branch("test-branch")
    
    -- Test de changement de branche
    local result = branch.switch_branch("test-branch")
    assert_test(
        "Switch branch",
        result.success,
        "Should successfully switch to new branch"
    )
    
    -- Vérifier la branche courante
    local current = utils.git_command("branch --show-current")
    assert_test(
        "Current branch",
        current.success and current.output:match("test%-branch"),
        "Current branch should be test-branch"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de suppression de branche
local function test_delete_branch()
    local temp_dir = setup_test_environment()
    
    -- Créer une branche pour le test
    branch.create_branch("test-branch")
    
    -- Test de suppression de branche
    local result = branch.delete_branch("test-branch")
    assert_test(
        "Delete branch",
        result.success,
        "Should successfully delete branch"
    )
    
    -- Vérifier que la branche n'existe plus
    local branches = utils.git_command("branch --list test-branch")
    assert_test(
        "Branch deleted",
        not branches.output:match("test%-branch"),
        "Branch should not exist after deletion"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de listage des branches
local function test_list_branches()
    local temp_dir = setup_test_environment()
    
    -- Créer quelques branches pour le test
    branch.create_branch("test-branch-1")
    branch.create_branch("test-branch-2")
    
    -- Test de listage des branches
    local result = branch.list_branches()
    assert_test(
        "List branches",
        result.success and #result.branches >= 3,  -- main + 2 nouvelles branches
        "Should list all branches"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de récupération de la branche courante
local function test_current_branch()
    local temp_dir = setup_test_environment()
    
    -- Test de récupération de la branche courante
    local result = branch.get_current_branch()
    assert_test(
        "Get current branch",
        result.success and result.branch == "main",
        "Should return current branch name"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Exécution des tests
print("\n🧪 Starting branch.lua tests...\n")

test_create_branch()
test_switch_branch()
test_delete_branch()
test_list_branches()
test_current_branch()

-- Affichage du résumé
print("\n📊 Test Summary:")
print(string.format("Total tests: %d", test_results.passed + test_results.failed))
print(string.format("Passed: %d", test_results.passed))
print(string.format("Failed: %d", test_results.failed))

if #test_results.errors > 0 then
    print("\n❌ Failed tests details:")
    for _, err in ipairs(test_results.errors) do
        print(string.format("- %s: %s", err.name, err.message))
    end
end
