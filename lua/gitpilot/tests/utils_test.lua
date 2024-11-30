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

-- Test de la commande git invalide
local function test_invalid_command()
    local result = utils.git_command("")
    assert_test(
        "Invalid command test",
        result.success == false and result.error_type == "INVALID_INPUT",
        "Should return error for empty command"
    )
end

-- Test de la commande git inexistante
local function test_nonexistent_command()
    local result = utils.git_command("nonexistent-command")
    assert_test(
        "Nonexistent command test",
        result.success == false and result.error_type == "GIT_ERROR",
        "Should return error for nonexistent command"
    )
end

-- Test de la validation de fichier
local function test_file_validation()
    local result = utils.get_file_status(nil)
    assert_test(
        "File validation test",
        result.success == false and result.error_type == "INVALID_INPUT",
        "Should return error for nil file path"
    )
end

-- Test de la vérification du repo git
local function test_git_repo_check()
    local result = utils.is_git_repo()
    assert_test(
        "Git repo check test",
        type(result) == "boolean",
        "Should return boolean for git repo check"
    )
end

-- Test du tracking de fichier
local function test_file_tracking()
    local result = utils.is_tracked("nonexistent-file.txt")
    assert_test(
        "File tracking test",
        result.success == false and result.error_type == "GIT_ERROR",
        "Should return error for nonexistent file"
    )
end

-- Test du statut de fichier
local function test_file_status()
    -- Créer un fichier temporaire pour le test
    local temp_file = os.tmpname()
    local file = io.open(temp_file, "w")
    file:write("test content")
    file:close()
    
    local result = utils.get_file_status(temp_file)
    
    -- Nettoyer le fichier temporaire
    os.remove(temp_file)
    
    assert_test(
        "File status test",
        result.success == false and result.error_type == "GIT_ERROR",
        "Should return error for file not in git"
    )
end

-- Exécution des tests
print("\n🧪 Starting utils.lua tests...\n")

test_invalid_command()
test_nonexistent_command()
test_file_validation()
test_git_repo_check()
test_file_tracking()
test_file_status()

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

return test_results
