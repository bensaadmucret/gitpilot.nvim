local search = require('gitpilot.features.search')
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
    
    -- Créer plusieurs fichiers avec du contenu différent
    local file1 = io.open(temp_dir .. "/test1.txt", "w")
    file1:write("This is a test file with some content\nIt contains the word 'test' multiple times\nTest test test")
    file1:close()
    
    local file2 = io.open(temp_dir .. "/test2.txt", "w")
    file2:write("Another file with different content\nNo test word here\nBut it has 'search' term")
    file2:close()
    
    -- Créer un sous-répertoire avec des fichiers
    os.execute("mkdir -p " .. temp_dir .. "/subdir")
    local file3 = io.open(temp_dir .. "/subdir/test3.txt", "w")
    file3:write("A file in subdirectory\nWith test and search terms")
    file3:close()
    
    -- Ajouter tous les fichiers à git
    os.execute("cd " .. temp_dir .. " && git add . && git commit -m 'Initial commit'")
    
    return temp_dir
end

-- Nettoyage après les tests
local function cleanup_test_environment(temp_dir)
    os.execute("rm -rf " .. temp_dir)
end

-- Test de recherche simple
local function test_simple_search()
    local temp_dir = setup_test_environment()
    
    -- Test de recherche du mot "test"
    local result = search.search_files("test")
    assert_test(
        "Simple search",
        result.success and #result.matches > 0,
        "Should find matches for 'test'"
    )
    
    -- Vérifier que les résultats contiennent les bons fichiers
    local has_test1 = false
    local has_test3 = false
    for _, match in ipairs(result.matches) do
        if match.file:match("test1.txt") then has_test1 = true end
        if match.file:match("test3.txt") then has_test3 = true end
    end
    
    assert_test(
        "Search results",
        has_test1 and has_test3,
        "Should find matches in correct files"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de recherche avec expression régulière
local function test_regex_search()
    local temp_dir = setup_test_environment()
    
    -- Test de recherche avec regex
    local result = search.search_files("test.*search")
    assert_test(
        "Regex search",
        result.success and #result.matches > 0,
        "Should find matches with regex pattern"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de recherche sensible à la casse
local function test_case_sensitive_search()
    local temp_dir = setup_test_environment()
    
    -- Test de recherche sensible à la casse
    local result = search.search_files("Test", true)
    assert_test(
        "Case sensitive search",
        result.success and #result.matches == 1,  -- Seulement la ligne avec 'Test'
        "Should only find exact case matches"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de recherche dans un sous-répertoire
local function test_directory_search()
    local temp_dir = setup_test_environment()
    
    -- Test de recherche dans le sous-répertoire
    local result = search.search_files("test", false, "subdir")
    assert_test(
        "Directory search",
        result.success and #result.matches == 1,  -- Seulement le fichier dans subdir
        "Should only find matches in specified directory"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de recherche avec des fichiers exclus
local function test_excluded_search()
    local temp_dir = setup_test_environment()
    
    -- Test de recherche avec exclusion
    local result = search.search_files("test", false, nil, {"test1.txt"})
    assert_test(
        "Excluded search",
        result.success and not result.matches[1].file:match("test1.txt"),
        "Should not find matches in excluded files"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de recherche dans l'historique git
local function test_git_history_search()
    local temp_dir = setup_test_environment()
    
    -- Créer plusieurs commits avec différents contenus
    local file = io.open(temp_dir .. "/test1.txt", "w")
    file:write("Modified content with searchterm")
    file:close()
    os.execute("cd " .. temp_dir .. " && git add test1.txt && git commit -m 'Add searchterm'")
    
    file = io.open(temp_dir .. "/test1.txt", "w")
    file:write("Final content without term")
    file:close()
    os.execute("cd " .. temp_dir .. " && git add test1.txt && git commit -m 'Remove searchterm'")
    
    -- Test de recherche dans l'historique
    local result = search.search_history("searchterm")
    assert_test(
        "Git history search",
        result.success and #result.matches > 0,
        "Should find matches in git history"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de recherche de commit par message
local function test_commit_message_search()
    local temp_dir = setup_test_environment()
    
    -- Créer des commits avec différents messages
    os.execute("cd " .. temp_dir .. " && echo 'new' > new.txt && git add new.txt")
    os.execute("cd " .. temp_dir .. " && git commit -m 'feat: add new feature'")
    os.execute("cd " .. temp_dir .. " && echo 'fix' > fix.txt && git add fix.txt")
    os.execute("cd " .. temp_dir .. " && git commit -m 'fix: bug fix'")
    
    -- Test de recherche de commits
    local result = search.search_commits("feat:")
    assert_test(
        "Commit message search",
        result.success and #result.matches == 1,
        "Should find specific commit messages"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Exécution des tests
print("\n🧪 Starting search.lua tests...\n")

test_simple_search()
test_regex_search()
test_case_sensitive_search()
test_directory_search()
test_excluded_search()
test_git_history_search()
test_commit_message_search()

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
