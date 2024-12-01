-- lua/gitpilot/init.lua

local M = {}

-- Configuration par défaut
M.defaults = {
    language = "fr",  -- langue par défaut
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

-- Fonction d'initialisation
function M.setup(opts)
    -- Fusionner les options utilisateur avec les valeurs par défaut
    M.config = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
    
    -- Charger le module de traduction
    local i18n = require("gitpilot.i18n")
    i18n.setup(M.config.language)
    
    -- Initialiser les fonctionnalités de base
    require("gitpilot.features").setup(M.config)
end

-- Fonction pour obtenir la configuration actuelle
function M.get_config()
    return M.config
end

return M
