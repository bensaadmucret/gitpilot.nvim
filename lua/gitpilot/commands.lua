local M = {}

-- Configuration locale
local config = {}

-- Modules requis
local function get_deps()
    return {
        ui = require('gitpilot.ui'),
        utils = require('gitpilot.utils')
    }
end

-- Setup function
M.setup = function(opts)
    config = opts or {}
    
    -- Création des commandes utilisateur
    local deps = get_deps()
    
    -- Commande GitPilot
    vim.api.nvim_create_user_command('GitPilot', function()
        deps.ui.show_main_menu()
    end, {})
    
    -- Commande GitCommit
    vim.api.nvim_create_user_command('GitCommit', function()
        local commit = require('gitpilot.features.commit')
        commit.create_commit()
    end, {})
    
    -- Commandes pour les branches
    vim.api.nvim_create_user_command('GitBranchCreate', function()
        local branch = require('gitpilot.features.branch')
        branch.create_branch()
    end, {})
    
    vim.api.nvim_create_user_command('GitBranchSwitch', function()
        local branch = require('gitpilot.features.branch')
        branch.switch_branch()
    end, {})
    
    vim.api.nvim_create_user_command('GitBranchMerge', function()
        local branch = require('gitpilot.features.branch')
        branch.merge_branch()
    end, {})
    
    vim.api.nvim_create_user_command('GitBranchDelete', function()
        local branch = require('gitpilot.features.branch')
        branch.delete_branch()
    end, {})
    
    -- Commandes pour les remotes
    vim.api.nvim_create_user_command('GitRemoteAdd', function()
        local remote = require('gitpilot.features.remote')
        remote.add_remote()
    end, {})
    
    vim.api.nvim_create_user_command('GitRemoteRemove', function()
        local remote = require('gitpilot.features.remote')
        remote.remove_remote()
    end, {})
    
    vim.api.nvim_create_user_command('GitRemoteFetch', function()
        local remote = require('gitpilot.features.remote')
        remote.fetch_remote()
    end, {})
    
    vim.api.nvim_create_user_command('GitRemotePush', function()
        local remote = require('gitpilot.features.remote')
        remote.push_remote()
    end, {})
    
    -- Commandes pour les tags
    vim.api.nvim_create_user_command('GitTagCreate', function()
        local tags = require('gitpilot.features.tags')
        tags.create_tag()
    end, {})
    
    vim.api.nvim_create_user_command('GitTagDelete', function()
        local tags = require('gitpilot.features.tags')
        tags.delete_tag()
    end, {})
    
    vim.api.nvim_create_user_command('GitTagPush', function()
        local tags = require('gitpilot.features.tags')
        tags.push_tag()
    end, {})
    
    -- Commandes pour le stash
    vim.api.nvim_create_user_command('GitStashCreate', function()
        local stash = require('gitpilot.features.stash')
        stash.create_stash()
    end, {})
    
    vim.api.nvim_create_user_command('GitStashApply', function()
        local stash = require('gitpilot.features.stash')
        stash.apply_stash()
    end, {})
    
    vim.api.nvim_create_user_command('GitStashDelete', function()
        local stash = require('gitpilot.features.stash')
        stash.delete_stash()
    end, {})
    
    -- Commande pour la recherche
    vim.api.nvim_create_user_command('GitSearch', function()
        local search = require('gitpilot.features.search')
        search.show_menu()
    end, {})
    
    -- Commande pour le rebase
    vim.api.nvim_create_user_command('GitRebase', function()
        local rebase = require('gitpilot.features.rebase')
        rebase.start_rebase()
    end, {})
end

return M
