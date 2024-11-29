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

-- Initialisation du plugin
M.setup = function(opts)
    -- Fusion des options utilisateur avec les valeurs par défaut
    M.config = vim.tbl_deep_extend("force", default_config, opts or {})
    
    -- Initialisation des composants
    require('gitpilot.i18n').setup(M.config)
    require('gitpilot.commands').setup(M.config)
    require('gitpilot.ui').setup(M.config)
    
    -- Création des commandes utilisateur
    vim.api.nvim_create_user_command('GitPilot', function()
        require('gitpilot.ui').show_main_menu()
    end, {})
    
    vim.api.nvim_create_user_command('GitCommit', function()
        require('gitpilot.commands').smart_commit()
    end, {})
    
    vim.api.nvim_create_user_command('GitBranch', function()
        require('gitpilot.commands').safe_branch_manager()
    end, {})
    
    vim.api.nvim_create_user_command('GitRebase', function()
        require('gitpilot.commands').interactive_rebase()
    end, {})
    
    vim.api.nvim_create_user_command('GitConflict', function()
        require('gitpilot.commands').conflict_resolver()
    end, {})
    
    vim.api.nvim_create_user_command('GitStash', function()
        require('gitpilot.commands').advanced_stash()
    end, {})
    
    vim.api.nvim_create_user_command('GitHistory', function()
        require('gitpilot.commands').visual_history()
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
