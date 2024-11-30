local remote = require('gitpilot.features.remote')
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
    
    -- Créer un dépôt distant simulé
    local remote_dir = temp_dir .. "_remote"
    os.execute("mkdir -p " .. remote_dir .. " && cd " .. remote_dir .. " && git init --bare")
    
    -- Créer un fichier initial et faire un commit
    local file = io.open(temp_dir .. "/test.txt", "w")
    file:write("initial content")
    file:close()
    os.execute("cd " .. temp_dir .. " && git add test.txt && git commit -m 'Initial commit'")
    
    return temp_dir, remote_dir
end

-- Nettoyage après les tests
local function cleanup_test_environment(temp_dir, remote_dir)
    os.execute("rm -rf " .. temp_dir)
    os.execute("rm -rf " .. remote_dir)
end

-- Test d'ajout de remote
local function test_add_remote()
    local temp_dir, remote_dir = setup_test_environment()
    
    -- Test d'ajout de remote
    local result = remote.add_remote("origin", remote_dir)
    assert_test(
        "Add remote",
        result.success,
        "Should successfully add remote"
    )
    
    -- Vérifier que le remote existe
    local remotes = utils.git_command("remote -v")
    assert_test(
        "Remote exists",
        remotes.success and remotes.output:match("origin") and remotes.output:match(remote_dir),
        "Remote should exist in remote list"
    )
    
    cleanup_test_environment(temp_dir, remote_dir)
end

-- Test de listage des remotes
local function test_list_remotes()
    local temp_dir, remote_dir = setup_test_environment()
    
    -- Ajouter quelques remotes
    os.execute("cd " .. temp_dir .. " && git remote add origin " .. remote_dir)
    os.execute("cd " .. temp_dir .. " && git remote add upstream " .. remote_dir .. "2")
    
    -- Test de listage des remotes
    local result = remote.list_remotes()
    assert_test(
        "List remotes",
        result.success and #result.remotes >= 2,
        "Should list all remotes"
    )
    
    cleanup_test_environment(temp_dir, remote_dir)
end

-- Test de push vers un remote
local function test_push_remote()
    local temp_dir, remote_dir = setup_test_environment()
    
    -- Configurer le remote
    os.execute("cd " .. temp_dir .. " && git remote add origin " .. remote_dir)
    
    -- Test de push
    local result = remote.push_remote("origin", "main")
    assert_test(
        "Push to remote",
        result.success,
        "Should successfully push to remote"
    )
    
    -- Vérifier que le push a fonctionné
    local remote_refs = utils.git_command("ls-remote origin")
    assert_test(
        "Push result",
        remote_refs.success and remote_refs.output:match("main"),
        "Remote should have main branch"
    )
    
    cleanup_test_environment(temp_dir, remote_dir)
end

-- Test de pull depuis un remote
local function test_pull_remote()
    local temp_dir, remote_dir = setup_test_environment()
    
    -- Configurer le remote et faire un push initial
    os.execute("cd " .. temp_dir .. " && git remote add origin " .. remote_dir)
    os.execute("cd " .. temp_dir .. " && git push origin main")
    
    -- Créer un nouveau commit sur le remote
    local clone_dir = temp_dir .. "_clone"
    os.execute("git clone " .. remote_dir .. " " .. clone_dir)
    local file = io.open(clone_dir .. "/test2.txt", "w")
    file:write("remote content")
    file:close()
    os.execute("cd " .. clone_dir .. " && git add test2.txt && git commit -m 'Remote commit'")
    os.execute("cd " .. clone_dir .. " && git push origin main")
    
    -- Test de pull
    local result = remote.pull_remote("origin", "main")
    assert_test(
        "Pull from remote",
        result.success,
        "Should successfully pull from remote"
    )
    
    -- Vérifier que le pull a fonctionné
    local file_exists = os.execute("test -f " .. temp_dir .. "/test2.txt")
    assert_test(
        "Pull result",
        file_exists,
        "Should have new file from remote"
    )
    
    cleanup_test_environment(temp_dir, remote_dir)
    os.execute("rm -rf " .. clone_dir)
end

-- Test de fetch depuis un remote
local function test_fetch_remote()
    local temp_dir, remote_dir = setup_test_environment()
    
    -- Configurer le remote et faire un push initial
    os.execute("cd " .. temp_dir .. " && git remote add origin " .. remote_dir)
    os.execute("cd " .. temp_dir .. " && git push origin main")
    
    -- Créer un nouveau commit sur le remote
    local clone_dir = temp_dir .. "_clone"
    os.execute("git clone " .. remote_dir .. " " .. clone_dir)
    local file = io.open(clone_dir .. "/test2.txt", "w")
    file:write("remote content")
    file:close()
    os.execute("cd " .. clone_dir .. " && git add test2.txt && git commit -m 'Remote commit'")
    os.execute("cd " .. clone_dir .. " && git push origin main")
    
    -- Test de fetch
    local result = remote.fetch_remote("origin")
    assert_test(
        "Fetch from remote",
        result.success,
        "Should successfully fetch from remote"
    )
    
    -- Vérifier que le fetch a fonctionné
    local remote_refs = utils.git_command("branch -r")
    assert_test(
        "Fetch result",
        remote_refs.success and remote_refs.output:match("origin/main"),
        "Should have remote refs after fetch"
    )
    
    cleanup_test_environment(temp_dir, remote_dir)
    os.execute("rm -rf " .. clone_dir)
end

-- Test de suppression de remote
local function test_remove_remote()
    local temp_dir, remote_dir = setup_test_environment()
    
    -- Ajouter un remote
    os.execute("cd " .. temp_dir .. " && git remote add origin " .. remote_dir)
    
    -- Test de suppression de remote
    local result = remote.remove_remote("origin")
    assert_test(
        "Remove remote",
        result.success,
        "Should successfully remove remote"
    )
    
    -- Vérifier que le remote n'existe plus
    local remotes = utils.git_command("remote -v")
    assert_test(
        "Remote removed",
        not remotes.output:match("origin"),
        "Remote should not exist after removal"
    )
    
    cleanup_test_environment(temp_dir, remote_dir)
end

-- Exécution des tests
print("\n🧪 Starting remote.lua tests...\n")

test_add_remote()
test_list_remotes()
test_push_remote()
test_pull_remote()
test_fetch_remote()
test_remove_remote()

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
