-- tests/features/patch_spec.lua

local mock = require('luassert.mock')
local stub = require('luassert.stub')
local vim = require('tests.mocks.vim')
local utils = require('tests.mocks.utils')
_G.vim = vim

describe('patch', function()
    local patch
    local i18n
    
    before_each(function()
        -- Mock dependencies
        i18n = mock(require('gitpilot.i18n'), true)
        
        -- Reset module
        package.loaded['gitpilot.patch'] = nil
        package.loaded['gitpilot.utils'] = nil
        
        -- Setup translations
        i18n.t.on_call_with('patch.error.create_directory').returns('Failed to create directory')
        i18n.t.on_call_with('patch.error.no_patch_file').returns('No patch file specified')
        
        -- Load module
        patch = require('gitpilot.features.patch')
        
        -- Override utils with mock
        package.loaded['gitpilot.utils'] = utils
        patch.utils = utils
    end)
    
    after_each(function()
        mock.revert(i18n)
    end)
    
    describe('setup', function()
        it('should create template directory', function()
            patch.setup()
            assert.equals('/tmp/gitpilot/templates/patches', patch.get_template_directory())
        end)
        
        it('should use custom template directory', function()
            patch.setup({
                template_directory = '/custom/path'
            })
            assert.equals('/custom/path', patch.get_template_directory())
        end)
    end)
    
    describe('create_patch', function()
        it('should create patch for last commit by default', function()
            local success, result = patch.create_patch()
            assert.is_true(success)
            assert.equals('Created patch file', result)
        end)
        
        it('should create patch between two commits', function()
            local success, result = patch.create_patch('abc123', 'def456')
            assert.is_true(success)
            assert.equals('Created patch file', result)
        end)
        
        it('should create patch from specific commit', function()
            local success, result = patch.create_patch('abc123')
            assert.is_true(success)
            assert.equals('Created patch file', result)
        end)
        
        it('should use custom output directory', function()
            local success, result = patch.create_patch(nil, nil, '/custom/output')
            assert.is_true(success)
            assert.equals('Created patch file', result)
        end)
        
        it('should handle patch creation failure', function()
            -- Override git_sync to return failure
            local old_git_sync = utils.git_sync
            utils.git_sync = function() return false, 'Failed to create patch' end
            
            local success, result = patch.create_patch()
            assert.is_false(success)
            assert.equals('Failed to create patch', result)
            
            utils.git_sync = old_git_sync
        end)
    end)
end)
