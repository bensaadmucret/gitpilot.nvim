local rebase = require('gitpilot.features.rebase')
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
    
    -- Créer une série de commits pour le rebase
    local file = io.open(temp_dir .. "/test.txt", "w")
    file:write("initial content")
    file:close()
    os.execute("cd " .. temp_dir .. " && git add test.txt && git commit -m 'Initial commit'")
    
    -- Créer une branche feature
    os.execute("cd " .. temp_dir .. " && git checkout -b feature")
    file = io.open(temp_dir .. "/test.txt", "w")
    file:write("feature content")
    file:close()
    os.execute("cd " .. temp_dir .. " && git add test.txt && git commit -m 'Feature commit'")
    
    -- Retourner sur main et faire un autre commit
    os.execute("cd " .. temp_dir .. " && git checkout main")
    file = io.open(temp_dir .. "/test.txt", "w")
    file:write("main content")
    file:close()
    os.execute("cd " .. temp_dir .. " && git add test.txt && git commit -m 'Main commit'")
    
    return temp_dir
end

-- Nettoyage après les tests
local function cleanup_test_environment(temp_dir)
    os.execute("rm -rf " .. temp_dir)
end

-- Test de rebase simple
local function test_simple_rebase()
    local temp_dir = setup_test_environment()
    
    -- Checkout de la branche feature
    os.execute("cd " .. temp_dir .. " && git checkout feature")
    
    -- Test de rebase sur main
    local result = rebase.rebase_branch("main")
    assert_test(
        "Simple rebase",
        result.success,
        "Should successfully rebase feature onto main"
    )
    
    -- Vérifier que le rebase a fonctionné
    local log = utils.git_command("log --oneline")
    assert_test(
        "Rebase result",
        log.success and log.output:match("Feature commit") and log.output:match("Main commit"),
        "Log should contain both feature and main commits"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de rebase interactif
local function test_interactive_rebase()
    local temp_dir = setup_test_environment()
    
    -- Créer plusieurs commits sur feature
    os.execute("cd " .. temp_dir .. " && git checkout feature")
    local file = io.open(temp_dir .. "/test2.txt", "w")
    file:write("feature content 2")
    file:close()
    os.execute("cd " .. temp_dir .. " && git add test2.txt && git commit -m 'Feature commit 2'")
    
    -- Test de rebase interactif
    local result = rebase.interactive_rebase("HEAD~2")
    assert_test(
        "Interactive rebase",
        result.success,
        "Should successfully start interactive rebase"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de rebase avec conflit
local function test_rebase_conflict()
    local temp_dir = setup_test_environment()
    
    -- Créer un conflit
    os.execute("cd " .. temp_dir .. " && git checkout feature")
    local file = io.open(temp_dir .. "/test.txt", "w")
    file:write("conflicting content")
    file:close()
    os.execute("cd " .. temp_dir .. " && git add test.txt && git commit -m 'Conflicting commit'")
    
    -- Test de rebase avec conflit
    local result = rebase.rebase_branch("main")
    assert_test(
        "Rebase conflict detection",
        not result.success and result.error_type == "CONFLICT",
        "Should detect rebase conflict"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test d'abandon de rebase
local function test_abort_rebase()
    local temp_dir = setup_test_environment()
    
    -- Créer un conflit et commencer le rebase
    os.execute("cd " .. temp_dir .. " && git checkout feature")
    local file = io.open(temp_dir .. "/test.txt", "w")
    file:write("conflicting content")
    file:close()
    os.execute("cd " .. temp_dir .. " && git add test.txt && git commit -m 'Conflicting commit'")
    os.execute("cd " .. temp_dir .. " && git rebase main")
    
    -- Test d'abandon de rebase
    local result = rebase.abort_rebase()
    assert_test(
        "Abort rebase",
        result.success,
        "Should successfully abort rebase"
    )
    
    -- Vérifier que nous sommes revenus à l'état initial
    local status = utils.git_command("status")
    assert_test(
        "Clean state after abort",
        status.success and not status.output:match("rebase"),
        "Should be in clean state after abort"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de continuation de rebase
local function test_continue_rebase()
    local temp_dir = setup_test_environment()
    
    -- Créer un conflit et commencer le rebase
    os.execute("cd " .. temp_dir .. " && git checkout feature")
    local file = io.open(temp_dir .. "/test.txt", "w")
    file:write("conflicting content")
    file:close()
    os.execute("cd " .. temp_dir .. " && git add test.txt && git commit -m 'Conflicting commit'")
    os.execute("cd " .. temp_dir .. " && git rebase main")
    
    -- Résoudre le conflit
    file = io.open(temp_dir .. "/test.txt", "w")
    file:write("resolved content")
    file:close()
    os.execute("cd " .. temp_dir .. " && git add test.txt")
    
    -- Test de continuation de rebase
    local result = rebase.continue_rebase()
    assert_test(
        "Continue rebase",
        result.success,
        "Should successfully continue rebase"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Exécution des tests
print("\n🧪 Starting rebase.lua tests...\n")

test_simple_rebase()
test_interactive_rebase()
test_rebase_conflict()
test_abort_rebase()
test_continue_rebase()

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
