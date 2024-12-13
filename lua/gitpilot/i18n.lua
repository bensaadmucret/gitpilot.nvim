-- lua/gitpilot/i18n.lua

local M = {}

-- Default language
local current_lang = 'fr'

-- Translations
local translations = {
    fr = {
        menu = {
            main_title = 'Menu Principal',
            branch_title = 'Gestion des branches',
            commit_title = 'Gestion des commits',
            remote_title = 'Gestion des remotes',
            tag_title = 'Gestion des tags',
            stash_title = 'Gestion des stash',
            search_title = 'Recherche',
            rebase_title = 'Rebase',
            backup_title = 'Sauvegarde',
            back = 'Retour',
            branches = 'Branches',
            commits = 'Commits',
            remotes = 'Remotes',
            tags = 'Tags',
            stash = 'Stash',
            search = 'Recherche',
            rebase = 'Rebase',
            backup = 'Sauvegarde'
        },
        actions = {
            branch = {
                create = 'Créer une branche',
                switch = 'Changer de branche',
                merge = 'Fusionner une branche',
                delete = 'Supprimer une branche'
            },
            commit = {
                create = 'Créer un commit',
                amend = 'Modifier le dernier commit',
                reset = 'Reset un commit'
            },
            remote = {
                add = 'Ajouter un remote',
                remove = 'Supprimer un remote',
                push = 'Push',
                pull = 'Pull'
            },
            stash = {
                save = 'Sauvegarder les modifications',
                pop = 'Appliquer et supprimer un stash',
                apply = 'Appliquer un stash',
                drop = 'Supprimer un stash'
            }
        },
        error = {
            invalid_menu = 'Menu invalide',
            command_failed = 'La commande a échoué'
        }
    }
}

-- Get translation for a key
function M.t(key)
    local parts = vim.split(key, '.', { plain = true })
    local current = translations[current_lang]
    
    for _, part in ipairs(parts) do
        if current[part] then
            current = current[part]
        else
            return key
        end
    end
    
    return type(current) == 'string' and current or key
end

-- Set current language
function M.set_lang(lang)
    if translations[lang] then
        current_lang = lang
    end
end

return M
