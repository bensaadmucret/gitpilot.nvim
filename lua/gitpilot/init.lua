local M = {}

-- Configuration par défaut
local default_config = {
    language = "en",
    ui = {
        icons = true,
        help = true,
        confirm_actions = true,
        window = {
            width = 60,
            height = 20,
            border = "rounded"
        }
    },
    git = {
        cmd = "git",
        timeout = 5000
    }
}

-- Configuration active
M.config = {}

-- Import des modules
local i18n = require('gitpilot.i18n')
local commands = require('gitpilot.commands')
local ui = require('gitpilot.ui')
local branch = require('gitpilot.features.branch')

-- Initialisation du plugin
M.setup = function(opts)
    -- Fusion des options utilisateur avec les valeurs par défaut
    M.config = vim.tbl_deep_extend("force", default_config, opts or {})
    
    -- Initialisation des composants
    i18n.setup(M.config)
    commands.setup(M.config)
    ui.setup(M.config)
    branch.setup(M.config)
    
    -- Création des commandes utilisateur
    vim.api.nvim_create_user_command('GitPilot', function()
        ui.show_main_menu()
    end, {})
    
    vim.api.nvim_create_user_command('GitCommit', function()
        commands.smart_commit()
    end, {})
    
    vim.api.nvim_create_user_command('GitBranch', function()
        commands.safe_branch_manager()
    end, {})
    
    vim.api.nvim_create_user_command('GitRebase', function()
        commands.interactive_rebase()
    end, {})
    
    vim.api.nvim_create_user_command('GitConflict', function()
        commands.conflict_resolver()
    end, {})
    
    vim.api.nvim_create_user_command('GitStash', function()
        commands.advanced_stash()
    end, {})
    
    vim.api.nvim_create_user_command('GitHistory', function()
        commands.visual_history()
    end, {})
    
    vim.api.nvim_create_user_command('GitBranchCreate', function()
        branch.create_branch()
    end, {})

    vim.api.nvim_create_user_command('GitBranchSwitch', function()
        branch.switch_branch()
    end, {})

    vim.api.nvim_create_user_command('GitBranchMerge', function()
        branch.merge_branch()
    end, {})

    vim.api.nvim_create_user_command('GitBranchDelete', function()
        branch.delete_branch()
    end, {})
    
    -- Définition des highlights
    vim.cmd([[
        highlight default GitPilotNormal guibg=#1a1b26 guifg=#a9b1d6
        highlight default GitPilotBorder guifg=#7aa2f7
        highlight default GitPilotHeader guifg=#7aa2f7 gui=bold
        highlight default GitPilotWarning guifg=#f7768e
        highlight default GitPilotSuccess guifg=#9ece6a
    ]])
end

return M
