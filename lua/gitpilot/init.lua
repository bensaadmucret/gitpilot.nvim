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
        timeout = 5000,
        test_mode = false
    }
}

-- Configuration active
M.config = {}

-- Fonction d'initialisation du plugin
M.setup = function(opts)
    -- Fusion des options utilisateur avec les valeurs par défaut
    M.config = vim.tbl_deep_extend("force", default_config, opts or {})
    
    -- Initialisation des modules de base
    require('gitpilot.utils').setup(M.config)
    require('gitpilot.i18n').setup(M.config)
    require('gitpilot.ui').setup(M.config)
    
    -- Initialisation des commandes
    require('gitpilot.commands').setup(M.config)
    
    -- Initialisation des fonctionnalités
    local features = {
        'branch',
        'commit',
        'remote',
        'tags',
        'stash',
        'search',
        'rebase'
    }
    
    for _, feature in ipairs(features) do
        local ok, module = pcall(require, 'gitpilot.features.' .. feature)
        if ok and module then
            module.setup(M.config)
        end
    end
end

return M
