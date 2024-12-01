local assert = require('luassert')
local conflict = require('gitpilot.features.conflict')

describe('conflict', function()
    before_each(function()
        -- Reset conflict configuration before each test
        conflict.setup({})
        -- Ensure we're in test mode
        vim.env.GITPILOT_TEST = "1"
    end)

    after_each(function()
        -- Clean up test environment variables
        vim.env.GITPILOT_TEST_NO_CONFLICTS = nil
        vim.env.GITPILOT_TEST_CONFLICTS = nil
    end)

    describe('find_conflicts', function()
        it('should handle no conflicts', function()
            vim.env.GITPILOT_TEST_NO_CONFLICTS = "1"
            local result = conflict.find_conflicts()
            assert.is_true(result.success)
            assert.same({}, result.files)
        end)

        it('should return list of conflicted files', function()
            local result = conflict.find_conflicts()
            assert.is_true(result.success)
            assert.is_table(result.files)
            assert.equals(2, #result.files)
            
            -- Vérifier le format des entrées
            for _, file in ipairs(result.files) do
                assert.is_string(file.path)
                assert.is_string(file.status)
                assert.matches("U", file.status)
            end
        end)
    end)

    describe('show_diff', function()
        it('should handle nil file path', function()
            local result = conflict.show_diff(nil)
            assert.is_false(result.success)
            assert.equals('conflict.messages.no_conflicts', result.error)
        end)

        it('should return success for valid file', function()
            local result = conflict.show_diff('test1.txt')
            assert.is_true(result.success)
        end)
    end)

    describe('resolve_conflict', function()
        it('should handle nil parameters', function()
            local result = conflict.resolve_conflict(nil, nil)
            assert.is_false(result.success)
            assert.equals('conflict.messages.resolve_error', result.error)
        end)

        it('should handle invalid strategy', function()
            local result = conflict.resolve_conflict('test1.txt', 'invalid')
            assert.is_false(result.success)
            assert.equals('conflict.messages.resolve_error', result.error)
        end)

        it('should resolve with ours strategy', function()
            local result = conflict.resolve_conflict('test1.txt', 'ours')
            assert.is_true(result.success)
        end)

        it('should resolve with theirs strategy', function()
            local result = conflict.resolve_conflict('test1.txt', 'theirs')
            assert.is_true(result.success)
        end)

        it('should handle both strategy', function()
            local result = conflict.resolve_conflict('test1.txt', 'both')
            assert.is_true(result.success)
        end)
    end)

    describe('show_history', function()
        it('should return empty history when no resolutions', function()
            local result = conflict.show_history()
            assert.is_true(result.success)
            assert.same({}, result.history)
        end)

        it('should return history after resolution', function()
            -- Faire une résolution
            conflict.resolve_conflict('test1.txt', 'ours')
            
            -- Vérifier l'historique
            local result = conflict.show_history()
            assert.is_true(result.success)
            assert.is_table(result.history)
            assert.equals(1, #result.history)
            
            -- Vérifier le format de l'entrée d'historique
            local entry = result.history[1]
            assert.is_string(entry.date)
            assert.equals('test1.txt', entry.file)
            assert.equals('ours', entry.strategy)
        end)
    end)
end)
