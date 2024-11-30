local commit = require('gitpilot.features.commit')
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
    
    -- Créer un fichier initial
    local file = io.open(temp_dir .. "/test.txt", "w")
    file:write("initial content")
    file:close()
    
    return temp_dir
end

-- Nettoyage après les tests
local function cleanup_test_environment(temp_dir)
    os.execute("rm -rf " .. temp_dir)
end

-- Test de sélection des fichiers
local function test_select_files()
    local temp_dir = setup_test_environment()
    
    -- Créer des fichiers modifiés
    local file1 = io.open(temp_dir .. "/test1.txt", "w")
    file1:write("test content 1")
    file1:close()
    
    local file2 = io.open(temp_dir .. "/test2.txt", "w")
    file2:write("test content 2")
    file2:close()
    
    os.execute("cd " .. temp_dir .. " && git add .")
    
    -- Modifier un fichier tracké
    file1 = io.open(temp_dir .. "/test1.txt", "w")
    file1:write("modified content")
    file1:close()
    
    -- Test de sélection des fichiers
    local files = commit.select_files()
    assert_test(
        "Select files",
        #files > 0,
        "Should list modified files"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de sélection du type de commit
local function test_select_commit_type()
    local temp_dir = setup_test_environment()
    
    -- Test de sélection du type de commit
    local result = commit.select_commit_type()
    assert_test(
        "Select commit type",
        result and result.type and result.emoji,
        "Should return valid commit type and emoji"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de commit simple
local function test_simple_commit()
    local temp_dir = setup_test_environment()
    
    -- Créer et ajouter un fichier
    local file = io.open(temp_dir .. "/test.txt", "w")
    file:write("test content")
    file:close()
    os.execute("cd " .. temp_dir .. " && git add test.txt")
    
    -- Test de commit simple
    local result = commit.simple_commit("Test commit message")
    assert_test(
        "Simple commit",
        result.success,
        "Should successfully create a commit"
    )
    
    -- Vérifier que le commit existe
    local log = utils.git_command("log --oneline")
    assert_test(
        "Commit exists",
        log.success and log.output:match("Test commit message"),
        "Commit should exist in git log"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de smart commit
local function test_smart_commit()
    local temp_dir = setup_test_environment()
    
    -- Créer et ajouter des fichiers
    local file1 = io.open(temp_dir .. "/test1.txt", "w")
    file1:write("test content 1")
    file1:close()
    
    local file2 = io.open(temp_dir .. "/test2.txt", "w")
    file2:write("test content 2")
    file2:close()
    
    os.execute("cd " .. temp_dir .. " && git add .")
    
    -- Test de smart commit
    local result = commit.smart_commit()
    assert_test(
        "Smart commit",
        result.success,
        "Should successfully create a smart commit"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de commit avec emoji
local function test_commit_with_emoji()
    local temp_dir = setup_test_environment()
    
    -- Créer et ajouter un fichier
    local file = io.open(temp_dir .. "/test.txt", "w")
    file:write("test content")
    file:close()
    os.execute("cd " .. temp_dir .. " && git add test.txt")
    
    -- Test de commit avec emoji
    local result = commit.commit_with_emoji("✨", "feat", "Add new feature")
    assert_test(
        "Commit with emoji",
        result.success,
        "Should successfully create a commit with emoji"
    )
    
    -- Vérifier que le commit existe avec l'emoji
    local log = utils.git_command("log --oneline")
    assert_test(
        "Commit with emoji exists",
        log.success and log.output:match("✨"),
        "Commit should exist with emoji in git log"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Exécution des tests
print("\n🧪 Starting commit.lua tests...\n")

test_select_files()
test_select_commit_type()
test_simple_commit()
test_smart_commit()
test_commit_with_emoji()

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
