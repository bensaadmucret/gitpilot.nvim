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
local commit = require('gitpilot.features.commit')
local remote = require('gitpilot.features.remote')
local tags = require('gitpilot.features.tags')
local stash = require('gitpilot.features.stash')
local search = require('gitpilot.features.search')
local rebase = require('gitpilot.features.rebase')

-- Initialisation du plugin
M.setup = function(opts)
    -- Fusion des options utilisateur avec les valeurs par défaut
    M.config = vim.tbl_deep_extend("force", default_config, opts or {})
    
    -- Initialisation des composants
    i18n.setup(M.config)
    commands.setup(M.config)
    ui.setup(M.config)
    branch.setup(M.config)
    commit.setup(M.config)
    remote.setup(M.config)
    tags.setup(M.config)
    stash.setup(M.config)
    search.setup(M.config)
    rebase.setup(M.config)
    
    -- Création des commandes utilisateur
    vim.api.nvim_create_user_command('GitPilot', function()
        ui.show_main_menu({
            {
                label = "Commits",
                action = function()
                    ui.show_commits_menu()
                end
            },
            {
                label = "Branches",
                action = function()
                    ui.show_branches_menu()
                end
            },
            {
                label = "Remotes",
                action = function()
                    ui.show_remotes_menu()
                end
            },
            {
                label = "Tags",
                action = function()
                    ui.show_tags_menu()
                end
            },
            {
                label = "Stash",
                action = function()
                    ui.show_stash_menu()
                end
            },
            {
                label = "Recherche",
                action = function()
                    search.show_menu()
                end
            },
            {
                label = "Rebase",
                action = function()
                    rebase.start_rebase()
                end
            }
        })
    end, {})
    
    -- Gestion des commits
    vim.api.nvim_create_user_command('GitCommit', function()
        commit.create_commit()
    end, {})
    
    -- Gestion des branches
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
    
    -- Gestion des remotes
    vim.api.nvim_create_user_command('GitRemoteAdd', function()
        remote.add_remote()
    end, {})
    
    vim.api.nvim_create_user_command('GitRemoteRemove', function()
        remote.remove_remote()
    end, {})
    
    vim.api.nvim_create_user_command('GitRemoteFetch', function()
        remote.fetch_remote()
    end, {})
    
    vim.api.nvim_create_user_command('GitRemotePush', function()
        remote.push_remote()
    end, {})
    
    -- Gestion des tags
    vim.api.nvim_create_user_command('GitTagCreate', function()
        tags.create_tag()
    end, {})
    
    vim.api.nvim_create_user_command('GitTagDelete', function()
        tags.delete_tag()
    end, {})
    
    vim.api.nvim_create_user_command('GitTagPush', function()
        tags.push_tag()
    end, {})
    
    -- Gestion du stash
    vim.api.nvim_create_user_command('GitStashCreate', function()
        stash.create_stash()
    end, {})
    
    vim.api.nvim_create_user_command('GitStashApply', function()
        stash.apply_stash()
    end, {})
    
    vim.api.nvim_create_user_command('GitStashDelete', function()
        stash.delete_stash()
    end, {})
    
    -- Recherche et navigation
    vim.api.nvim_create_user_command('GitSearch', function()
        search.show_menu()
    end, {})
    
    -- Rebase interactif
    vim.api.nvim_create_user_command('GitRebase', function()
        rebase.start_rebase()
    end, {})
end

return M
