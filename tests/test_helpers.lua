-- test_helpers.lua
local M = {}

-- Configure l'environnement de test
M.setup_test_env = function()
    -- Ajouter le répertoire lua au chemin de recherche
    local root_dir = "/Users/ben/CascadeProjects/gitpilot.nvim"
    package.path = root_dir .. "/lua/?.lua;" .. root_dir .. "/lua/?/init.lua;" .. package.path

    -- Mock de base pour vim
    _G.vim = {
        fn = {
            system = function(cmd) return "" end,
            getcwd = function() return "/mock/path" end
        },
        v = { shell_error = 0 },
        api = {
            nvim_err_writeln = function(msg) end,
            nvim_command = function(cmd) end,
            nvim_echo = function(chunks, history, opts) end
        },
        notify = function(msg, level, opts) end,
        log = {
            levels = {
                ERROR = 1,
                WARN = 2,
                INFO = 3,
                DEBUG = 4
            }
        }
    }
end

-- Nettoie l'environnement de test
M.cleanup_test_env = function()
    -- Réinitialiser les modules chargés
    package.loaded["gitpilot.i18n"] = nil
    package.loaded["gitpilot.ui"] = nil
    package.loaded["gitpilot.utils"] = nil
    package.loaded["gitpilot.features.branch"] = nil
end

return M
