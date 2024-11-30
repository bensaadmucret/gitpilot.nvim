local stash = require('gitpilot.features.stash')
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
    file:write("initial content")
    file:close()
    os.execute("cd " .. temp_dir .. " && git add test.txt && git commit -m 'Initial commit'")
    
    return temp_dir
end

-- Nettoyage après les tests
local function cleanup_test_environment(temp_dir)
    os.execute("rm -rf " .. temp_dir)
end

-- Test de création de stash
local function test_create_stash()
    local temp_dir = setup_test_environment()
    
    -- Créer des modifications pour le stash
    local file = io.open(temp_dir .. "/test.txt", "w")
    file:write("modified content")
    file:close()
    
    -- Test de création de stash
    local result = stash.create_stash("Test stash")
    assert_test(
        "Create stash",
        result.success,
        "Should successfully create a stash"
    )
    
    -- Vérifier que le stash existe
    local stashes = utils.git_command("stash list")
    assert_test(
        "Stash exists",
        stashes.success and stashes.output:match("Test stash"),
        "New stash should exist in stash list"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de listage des stash
local function test_list_stash()
    local temp_dir = setup_test_environment()
    
    -- Créer quelques stash pour le test
    local file = io.open(temp_dir .. "/test.txt", "w")
    file:write("modified content 1")
    file:close()
    stash.create_stash("Test stash 1")
    
    file = io.open(temp_dir .. "/test.txt", "w")
    file:write("modified content 2")
    file:close()
    stash.create_stash("Test stash 2")
    
    -- Test de listage des stash
    local result = stash.list_stash()
    assert_test(
        "List stash",
        #result >= 2,
        "Should list all stashes"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test d'application de stash
local function test_apply_stash()
    local temp_dir = setup_test_environment()
    
    -- Créer un stash pour le test
    local file = io.open(temp_dir .. "/test.txt", "w")
    file:write("stashed content")
    file:close()
    stash.create_stash("Test stash")
    
    -- Modifier le fichier
    file = io.open(temp_dir .. "/test.txt", "w")
    file:write("current content")
    file:close()
    
    -- Test d'application du stash
    local result = stash.apply_stash("stash@{0}")
    assert_test(
        "Apply stash",
        result.success,
        "Should successfully apply stash"
    )
    
    -- Vérifier le contenu du fichier
    file = io.open(temp_dir .. "/test.txt", "r")
    local content = file:read("*all")
    file:close()
    
    assert_test(
        "Stash content applied",
        content == "stashed content",
        "File content should match stashed content"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de suppression de stash
local function test_delete_stash()
    local temp_dir = setup_test_environment()
    
    -- Créer un stash pour le test
    local file = io.open(temp_dir .. "/test.txt", "w")
    file:write("stashed content")
    file:close()
    stash.create_stash("Test stash")
    
    -- Test de suppression du stash
    local result = stash.delete_stash("stash@{0}")
    assert_test(
        "Delete stash",
        result.success,
        "Should successfully delete stash"
    )
    
    -- Vérifier que le stash n'existe plus
    local stashes = utils.git_command("stash list")
    assert_test(
        "Stash deleted",
        not stashes.output:match("Test stash"),
        "Stash should not exist after deletion"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de stash avec des fichiers non suivis
local function test_stash_untracked()
    local temp_dir = setup_test_environment()
    
    -- Créer un nouveau fichier non suivi
    local file = io.open(temp_dir .. "/untracked.txt", "w")
    file:write("untracked content")
    file:close()
    
    -- Test de création de stash avec l'option -u
    local result = stash.create_stash("Test stash with untracked", true)
    assert_test(
        "Create stash with untracked",
        result.success,
        "Should successfully create stash with untracked files"
    )
    
    -- Vérifier que le fichier non suivi a été stashé
    local exists = os.execute("test -f " .. temp_dir .. "/untracked.txt")
    assert_test(
        "Untracked file stashed",
        not exists,
        "Untracked file should be removed after stash"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Exécution des tests
print("\n🧪 Starting stash.lua tests...\n")

test_create_stash()
test_list_stash()
test_apply_stash()
test_delete_stash()
test_stash_untracked()

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
