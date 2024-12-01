-- lua/gitpilot/features/init.lua

local M = {}

-- Liste des fonctionnalités disponibles
M.features = {
    commit = require("gitpilot.features.commit"),
    branch = require("gitpilot.features.branch"),
    tag = require("gitpilot.features.tag"),
    remote = require("gitpilot.features.remote"),
    stash = require("gitpilot.features.stash"),
    search = require("gitpilot.features.search"),
    rebase = require("gitpilot.features.rebase")
}

-- Fonction d'initialisation des fonctionnalités
function M.setup(config)
    -- Stocker la configuration
    M.config = config

    -- Initialiser chaque fonctionnalité
    for name, feature in pairs(M.features) do
        if feature.setup then
            feature.setup(config)
        end
    end

    -- Créer les commandes Neovim pour chaque fonctionnalité
    M.create_commands()
end

-- Créer les commandes Neovim
function M.create_commands()
    -- Commande principale
    vim.api.nvim_create_user_command("GitPilot", function(opts)
        require("gitpilot.ui").show_menu()
    end, {})

    -- Commandes pour chaque fonctionnalité
    local commands = {
        GitPilotCommit = "commit",
        GitPilotBranch = "branch",
        GitPilotTag = "tag",
        GitPilotRemote = "remote",
        GitPilotStash = "stash",
        GitPilotSearch = "search",
        GitPilotRebase = "rebase"
    }

    for cmd_name, feature_name in pairs(commands) do
        vim.api.nvim_create_user_command(cmd_name, function(opts)
            local feature = M.features[feature_name]
            if feature and feature.show then
                feature.show(opts.args)
            end
        end, {
            nargs = "*",
            complete = function(_, line)
                local feature = M.features[feature_name]
                if feature and feature.complete then
                    return feature.complete(line)
                end
                return {}
            end
        })
    end
end

return M
