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
function M.setup(opts)
    -- Fusion des options utilisateur avec les valeurs par défaut
    M.config = vim.tbl_deep_extend("force", default_config, opts or {})
    
    -- Initialisation des modules de base
    local ok, err = pcall(function()
        -- Chargement des modules de base
        local utils = require('gitpilot.utils')
        local i18n = require('gitpilot.i18n')
        local ui = require('gitpilot.ui')
        local commands = require('gitpilot.commands')
        
        -- Configuration des modules de base
        utils.setup(M.config)
        i18n.setup(M.config)
        ui.setup(M.config)
        commands.setup(M.config)
        
        -- Création des commandes utilisateur
        vim.api.nvim_create_user_command('GitPilot', function()
            ui.show_main_menu()
        end, {})
    end)
    
    if not ok then
        vim.notify('GitPilot: Error during initialization - ' .. tostring(err), vim.log.levels.ERROR)
        return
    end
end

return M
