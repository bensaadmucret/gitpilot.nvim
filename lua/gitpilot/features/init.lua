-- lua/gitpilot/features/init.lua

local M = {}

-- Table pour stocker les modules de fonctionnalités
local features = {
    branch = require("gitpilot.features.branch")
}

-- Configuration globale
local config = {}

-- Fonction d'initialisation
function M.setup(opts)
    config = opts or {}
    
    -- Initialiser chaque module de fonctionnalité
    for name, feature in pairs(features) do
        if type(feature.setup) == "function" then
            feature.setup(config)
        end
    end
end

-- Fonction pour obtenir un module de fonctionnalité
function M.get(name)
    return features[name]
end

return M
