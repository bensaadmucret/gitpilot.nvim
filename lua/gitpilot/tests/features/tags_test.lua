local tags = require('gitpilot.features.tags')
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

-- Test de création de tag léger
local function test_create_lightweight_tag()
    local temp_dir = setup_test_environment()
    
    -- Test de création de tag léger
    local result = tags.create_tag("v1.0.0", "")
    assert_test(
        "Create lightweight tag",
        result.success,
        "Should successfully create a lightweight tag"
    )
    
    -- Vérifier que le tag existe
    local tag_exists = utils.git_command("tag -l v1.0.0")
    assert_test(
        "Lightweight tag exists",
        tag_exists.success and tag_exists.output:match("v1.0.0"),
        "New lightweight tag should exist in tag list"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de création de tag annoté
local function test_create_annotated_tag()
    local temp_dir = setup_test_environment()
    
    -- Test de création de tag annoté
    local result = tags.create_tag("v1.0.0", "Release version 1.0.0")
    assert_test(
        "Create annotated tag",
        result.success,
        "Should successfully create an annotated tag"
    )
    
    -- Vérifier que le tag existe et a le bon message
    local tag_show = utils.git_command("tag -n1 v1.0.0")
    assert_test(
        "Annotated tag message",
        tag_show.success and tag_show.output:match("Release version 1.0.0"),
        "Annotated tag should have the correct message"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de listage des tags
local function test_list_tags()
    local temp_dir = setup_test_environment()
    
    -- Créer quelques tags pour le test
    tags.create_tag("v1.0.0", "First release")
    tags.create_tag("v1.1.0", "Second release")
    tags.create_tag("v2.0.0", "Major release")
    
    -- Test de listage des tags
    local result = tags.list_tags()
    assert_test(
        "List tags count",
        #result == 3,
        "Should list all tags"
    )
    
    -- Vérifier le format des tags
    local has_correct_format = true
    for _, tag in ipairs(result) do
        if not (tag.name and tag.hash and tag.message) then
            has_correct_format = false
            break
        end
    end
    
    assert_test(
        "Tag format",
        has_correct_format,
        "Each tag should have name, hash and message"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de tag avec un commit spécifique
local function test_tag_specific_commit()
    local temp_dir = setup_test_environment()
    
    -- Faire un second commit
    local file = io.open(temp_dir .. "/test.txt", "w")
    file:write("modified content")
    file:close()
    os.execute("cd " .. temp_dir .. " && git add test.txt && git commit -m 'Second commit'")
    
    -- Obtenir le hash du premier commit
    local first_commit = utils.git_command("git rev-parse HEAD^")
    
    -- Test de création de tag sur un commit spécifique
    local result = tags.create_tag("v1.0.0", "First version", first_commit.output)
    assert_test(
        "Create tag on specific commit",
        result.success,
        "Should successfully create tag on specific commit"
    )
    
    -- Vérifier que le tag pointe vers le bon commit
    local tag_commit = utils.git_command("git rev-parse v1.0.0")
    assert_test(
        "Tag points to correct commit",
        tag_commit.output == first_commit.output,
        "Tag should point to the specified commit"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Test de push de tag
local function test_push_tag()
    local temp_dir = setup_test_environment()
    
    -- Configurer un dépôt distant simulé
    local remote_dir = temp_dir .. "_remote"
    os.execute("mkdir -p " .. remote_dir .. " && cd " .. remote_dir .. " && git init --bare")
    os.execute("cd " .. temp_dir .. " && git remote add origin " .. remote_dir)
    
    -- Créer et pousser un tag
    tags.create_tag("v1.0.0", "First release")
    local result = tags.push_tag("v1.0.0")
    
    assert_test(
        "Push tag",
        result.success,
        "Should successfully push tag to remote"
    )
    
    -- Vérifier que le tag existe sur le dépôt distant
    local remote_tag = utils.git_command("git ls-remote --tags origin v1.0.0")
    assert_test(
        "Tag exists on remote",
        remote_tag.success and remote_tag.output:match("v1.0.0"),
        "Tag should exist on remote repository"
    )
    
    cleanup_test_environment(temp_dir)
    os.execute("rm -rf " .. remote_dir)
end

-- Test de suppression de tag
local function test_delete_tag()
    local temp_dir = setup_test_environment()
    
    -- Créer un tag
    tags.create_tag("v1.0.0", "Test tag")
    
    -- Test de suppression du tag
    local result = tags.delete_tag("v1.0.0")
    assert_test(
        "Delete tag",
        result.success,
        "Should successfully delete tag"
    )
    
    -- Vérifier que le tag n'existe plus
    local tag_exists = utils.git_command("tag -l v1.0.0")
    assert_test(
        "Tag deleted",
        tag_exists.output == "",
        "Tag should not exist after deletion"
    )
    
    cleanup_test_environment(temp_dir)
end

-- Exécution des tests
print("\n🧪 Starting tags.lua tests...\n")

test_create_lightweight_tag()
test_create_annotated_tag()
test_list_tags()
test_tag_specific_commit()
test_push_tag()
test_delete_tag()

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
