-- lua/gitpilot/init.lua

local M = {}

-- Version du plugin
M.version = "1.0.0"

-- Configuration par défaut
local default_config = {
    use_icons = true,
    confirm_actions = true,
    auto_refresh = true,
    language = "en",
    window = {
        width = 60,
        height = 20,
        border = "rounded",
        title = true,
        footer = true
    },
    git = {
        timeout = 5000,
        command = "git"
    }
}

-- État global du plugin
local state = {
    initialized = false,
    config = vim.deepcopy(default_config)
}

-- Initialise les modules
local function init_modules(config)
    -- Initialise l'internationalisation
    require('gitpilot.i18n').setup({
        language = config.language
    })
    
    -- Initialise l'interface utilisateur
    require('gitpilot.ui').setup({
        use_icons = config.use_icons,
        window = config.window
    })
    
    -- Initialise les utilitaires
    require('gitpilot.utils').setup({
        git = config.git
    })
    
    -- Initialise les menus
    require('gitpilot.menu').setup({
        confirm_actions = config.confirm_actions,
        auto_refresh = config.auto_refresh
    })
    
    -- Initialise les actions
    require('gitpilot.actions').setup({
        confirm_actions = config.confirm_actions,
        auto_refresh = config.auto_refresh
    })
    
    -- Initialise le planificateur de sauvegarde
    require('gitpilot.features.backup_scheduler').setup()
    
    -- Initialise la gestion des mirrors
    require('gitpilot.features.mirror').setup()
    
    -- Initialise le module de patch
    require("gitpilot.features.patch_ui").setup()
    
    -- Initialise l'historique interactif
    require("gitpilot.features.history_ui").setup()
    
    -- Initialise la gestion des issues
    require("gitpilot.features.issues_ui").setup()
end

-- Configure le plugin
function M.setup(opts)
    -- Fusionne les configurations
    state.config = vim.tbl_deep_extend("force", default_config, opts or {})
    
    -- Initialise les modules
    init_modules(state.config)
    
    -- Crée la commande GitPilot
    vim.api.nvim_create_user_command('GitPilot', function(args)
        M.show_menu()
    end, {
        desc = 'Open GitPilot menu'
    })
    
    -- Marque comme initialisé
    state.initialized = true
end

-- Affiche le menu principal
function M.show_menu()
    local ui = require('gitpilot.ui')
    local i18n = require('gitpilot.i18n')
    
    -- Vérifie que le plugin est initialisé
    if not state.initialized then
        M.setup()
    end
    
    -- Affiche le menu principal
    ui.show_menu(i18n.t("main.menu.title"), {})
end

-- Réinitialise l'état
function M.reset()
    state.initialized = false
    state.config = vim.deepcopy(default_config)
    require('gitpilot.menu').reset()
end

return M
