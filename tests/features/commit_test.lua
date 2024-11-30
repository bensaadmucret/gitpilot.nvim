local commit = require('gitpilot.features.commit')
local utils = require('gitpilot.utils')
local test_helpers = require('tests.test_helpers')

local test = {}

local function setup()
    test_helpers.setup_test_environment()
end

local function teardown()
    test_helpers.teardown_test_environment()
    if utils.original_git_command then
        utils.git_command = utils.original_git_command
        utils.original_git_command = nil
    end
end

-- Test la sélection des fichiers à commiter
function test.test_select_files()
    setup()
    
    -- Mock de git_command pour simuler des fichiers modifiés
    utils.original_git_command = utils.git_command
    utils.git_command = function()
        return [[
 M test1.txt
?? test2.txt
M  test3.txt]]
    end
    
    -- Mock de la fenêtre flottante
    test_helpers.mock_floating_window({
        on_create = function(_, lines)
            assert(#lines == 3, "Expected 3 files in the list")
            return 1, 1  -- buffer et window
        end,
        on_keymap = function(_, key)
            if key == '<CR>' then
                return {'test1.txt', 'test2.txt'}
            end
        end
    })
    
    local selected_files = commit.select_files()
    assert(type(selected_files) == "table", "Expected select_files to return a table")
    assert(#selected_files == 2, "Expected 2 files to be selected")
    
    teardown()
end

-- Test la sélection du type de commit
function test.test_select_commit_type()
    setup()
    
    -- Mock de la fenêtre flottante
    test_helpers.mock_floating_window({
        on_create = function(_, lines)
            assert(#lines == 7, "Expected 7 commit types")
            return 1, 1  -- buffer et window
        end,
        on_keymap = function(_, key)
            if key == '<CR>' then
                return {
                    type = "feat",
                    emoji = "✨",
                    desc = "Nouvelle fonctionnalité"
                }
            end
        end
    })
    
    local commit_type = commit.select_commit_type()
    assert(commit_type, "Expected commit_type to be returned")
    assert(commit_type.type == "feat", "Expected feat type to be selected")
    assert(commit_type.emoji == "✨", "Expected feat emoji")
    
    teardown()
end

-- Test le commit intelligent
function test.test_smart_commit()
    setup()
    
    -- Mock pour simuler la sélection de fichiers
    test_helpers.mock_floating_window({
        on_create = function(_, lines)
            return 1, 1  -- buffer et window
        end,
        on_keymap = function(_, key)
            if key == '<CR>' then
                if not test_helpers.mock_floating_window.files_selected then
                    test_helpers.mock_floating_window.files_selected = true
                    return {'test1.txt'}
                else
                    return {
                        type = "feat",
                        emoji = "✨",
                        desc = "Nouvelle fonctionnalité"
                    }
                end
            end
        end
    })
    
    -- Mock de git_command pour simuler un commit réussi
    utils.original_git_command = utils.git_command
    utils.git_command = function(cmd)
        if cmd:match("^add") then
            return ""
        elseif cmd:match("^commit") then
            return "Created commit abc123: test commit"
        end
        return ""
    end
    
    -- Mock pour simuler l'input utilisateur
    test_helpers.config.input_response = "✨ feat: test commit"
    
    commit.smart_commit()
    
    teardown()
end

-- Test la gestion des erreurs
function test.test_error_handling()
    setup()
    
    -- Mock pour simuler une erreur git
    utils.original_git_command = utils.git_command
    utils.git_command = function()
        error("Git error")
    end
    
    local success = pcall(function()
        commit.smart_commit()
    end)
    assert(not success, "Expected smart commit to fail with error")
    
    teardown()
end

return test
