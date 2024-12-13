local mock = require('luassert.mock')
local stub = require('luassert.stub')
local vim = require('tests.mocks.vim')
_G.vim = vim

describe('menu', function()
    local menu
    local ui
    local i18n
    local utils
    
    before_each(function()
        -- Mock dependencies
        ui = mock(require('gitpilot.ui'), true)
        i18n = mock(require('gitpilot.i18n'), true)
        utils = mock(require('gitpilot.utils'), true)
        
        -- Reset module
        package.loaded['gitpilot.menu'] = nil
        menu = require('gitpilot.menu')
        
        -- Setup default configuration
        menu.setup({
            use_icons = true,
            confirm_actions = true,
            auto_refresh = true
        })

        -- Setup default translations
        i18n.t.on_call_with('menu.main_title').returns('GitPilot - Main Menu')
        i18n.t.on_call_with('menu.branches').returns('Branch Operations')
        i18n.t.on_call_with('menu.commits').returns('Commit Operations')
        i18n.t.on_call_with('menu.remotes').returns('Remote Operations')
        i18n.t.on_call_with('menu.tags').returns('Tag Operations')
        i18n.t.on_call_with('menu.stash').returns('Stash Operations')
        i18n.t.on_call_with('menu.search').returns('Search')
        i18n.t.on_call_with('menu.rebase').returns('Rebase')
        i18n.t.on_call_with('menu.backup').returns('Backup')
        i18n.t.on_call_with('menu.back').returns('Back')
        i18n.t.on_call_with('branch.create_new').returns('Create New Branch')
        i18n.t.on_call_with('branch.checkout').returns('Checkout Branch')
        i18n.t.on_call_with('branch.merge').returns('Merge Branch')
        i18n.t.on_call_with('branch.delete').returns('Delete Branch')
        i18n.t.on_call_with('branch.push').returns('Push Branch')
        i18n.t.on_call_with('branch.pull').returns('Pull Branch')
        i18n.t.on_call_with('branch.rebase').returns('Rebase Branch')
        i18n.t.on_call_with('branch.refresh').returns('Refresh Branches')
        i18n.t.on_call_with('error.invalid_menu').returns('Invalid menu selected')
        i18n.t.on_call_with('menu.branches_title').returns('GitPilot - Branches')
        i18n.t.on_call_with('commit.create').returns('Create Commit')

        -- Setup default utils
        utils.execute_command = function(cmd)
            if cmd == 'git branch --show-current' then
                return false, 'Not a git repository'
            end
            return false, 'Not a git repository'
        end
    end)
    
    after_each(function()
        mock.revert(ui)
        mock.revert(i18n)
        mock.revert(utils)
    end)
    
    describe('show_main_menu', function()
        it('should show the main menu with translated items', function()
            -- Call the function
            menu.show_main_menu()
            
            -- Verify that ui.float_window was called with correct parameters
            assert.stub(ui.float_window).was_called(1)
            local call = ui.float_window.calls[1]
            local items = call.refs[1]
            local opts = call.refs[2]
            
            -- Verify menu items
            assert.equals('🌿 Branch Operations', items[1])
            assert.equals('📝 Commit Operations', items[2])
            assert.equals('🔄 Remote Operations', items[3])
            assert.equals('🏷️ Tag Operations', items[4])
            assert.equals('📦 Stash Operations', items[5])
            assert.equals('🔍 Search', items[6])
            assert.equals('♻️ Rebase', items[7])
            assert.equals('💾 Backup', items[8])
            
            -- Verify title
            assert.equals('GitPilot - Main Menu', opts.title)
        end)
        
        it('should show menu without icons when use_icons is false', function()
            -- Setup configuration without icons
            menu.setup({
                use_icons = false
            })
            
            -- Call the function
            menu.show_main_menu()
            
            -- Verify menu items don't have icons
            local items = ui.float_window.calls[1].refs[1]
            assert.equals('Branch Operations', items[1])
            assert.equals('Commit Operations', items[2])
        end)
        
        it('should show current branch in title when in a git repository', function()
            -- Override utils.execute_command to return a branch
            utils.execute_command = function(cmd)
                if cmd == 'git branch --show-current' then
                    return true, 'main'
                end
                return false, 'Not a git repository'
            end
            
            -- Call the function
            menu.show_main_menu()
            
            -- Verify title includes branch name
            local opts = ui.float_window.calls[1].refs[2]
            assert.equals('GitPilot - Main Menu (main)', opts.title)
        end)
    end)
    
    describe('show_menu', function()
        it('should handle back navigation correctly', function()
            -- Mock ui.select to simulate selecting "Back"
            stub(ui, 'select', function(items, opts, callback)
                -- Find the back item
                local back_item
                for _, item in ipairs(items) do
                    if item:match('Back') then
                        back_item = item
                        break
                    end
                end
                callback(back_item)
            end)
            
            -- Show branch menu then go back
            menu.show_menu('branch')
            
            -- Verify we're back at main menu
            assert.equals('main', menu.get_current_menu())
            
            ui.select:revert()
        end)
        
        it('should handle invalid menu gracefully', function()
            -- Show invalid menu
            menu.show_menu('invalid_menu')
            
            -- Verify error was shown
            assert.stub(ui.show_error).was_called_with('Invalid menu selected')
        end)
        
        it('should pass context to action handler', function()
            -- Setup mocks
            local actions = mock(require('gitpilot.actions'), true)
            
            -- Setup ui.float_window to simulate selecting a menu item
            stub(ui, 'float_window', function(items, opts)
                -- Simulate selecting "Create Commit"
                opts.callback('📝 ' .. i18n.t('commit.create'))
            end)
            
            -- Show commit menu with context
            local context = { file = 'test.txt' }
            menu.show_menu('commit', context)
            
            -- Verify context was passed to action handler
            assert.stub(actions.handle_action).was_called_with('commit', 'create', context)
            
            ui.float_window:revert()
            mock.revert(actions)
        end)
    end)
end)
