-- lua/gitpilot/i18n.lua

local M = {}

-- Default language
local current_lang = 'fr'

-- Configuration
local config = {
    language = 'fr'
}

-- Setup function
function M.setup(opts)
    if opts then
        config = vim.tbl_deep_extend('force', config, opts)
    end
    if config.language then
        M.set_lang(config.language)
    end
end

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
        ui = {
            select_prompt = 'Sélectionnez une option',
            input_prompt = 'Entrez une valeur',
            no_items = 'Aucun élément à afficher'
        },
        confirm = {
            prompt = 'Êtes-vous sûr ?',
            yes_text = 'Oui',
            no_text = 'Non'
        },
        branch = {
            create_new = 'Créer une nouvelle branche',
            checkout = 'Changer de branche',
            merge = 'Fusionner une branche',
            delete = 'Supprimer une branche',
            push = 'Pousser la branche',
            pull = 'Tirer la branche',
            rebase = 'Rebaser la branche',
            refresh = 'Rafraîchir',
            enter_name = 'Nom de la branche :',
            select_checkout = 'Sélectionnez la branche à utiliser',
            select_merge = 'Sélectionnez la branche à fusionner',
            select_delete = 'Sélectionnez la branche à supprimer',
            select_rebase = 'Sélectionnez la branche pour le rebase',
            confirm_delete = 'Voulez-vous vraiment supprimer la branche %{branch} ?',
            confirm_push = 'Voulez-vous pousser la branche %{branch} ?',
            confirm_pull = 'Voulez-vous tirer la branche %{branch} ?',
            confirm_rebase = 'Voulez-vous rebaser sur la branche %{branch} ?',
            error = {
                invalid_name = 'Nom de branche invalide',
                not_found = 'Branche non trouvée',
                already_exists = 'La branche existe déjà',
                delete_current = 'Impossible de supprimer la branche courante'
            }
        },
        commit = {
            create = 'Créer un commit',
            amend = 'Modifier le dernier commit',
            reset = 'Annuler un commit',
            push = 'Pousser les commits',
            pull = 'Tirer les commits',
            enter_message = 'Message du commit :',
            confirm_amend = 'Voulez-vous modifier le dernier commit ?',
            confirm_fixup = 'Voulez-vous faire un fixup du commit %{hash} ?',
            confirm_revert = 'Voulez-vous annuler le commit %{hash} ?',
            error = {
                empty_message = 'Le message ne peut pas être vide',
                no_changes = 'Aucun changement à commiter'
            }
        },
        remote = {
            add = 'Ajouter un remote',
            remove = 'Supprimer un remote',
            push = 'Pousser vers un remote',
            pull = 'Tirer depuis un remote',
            fetch = 'Mettre à jour les remotes',
            prune = 'Nettoyer les branches distantes',
            enter_name = 'Nom du remote :',
            enter_url = 'URL du remote :',
            select_remote = 'Sélectionnez un remote',
            confirm_remove = 'Voulez-vous supprimer le remote %{remote} ?',
            error = {
                invalid_name = 'Nom de remote invalide',
                invalid_url = 'URL de remote invalide',
                not_found = 'Remote non trouvé',
                already_exists = 'Le remote existe déjà'
            }
        },
        tag = {
            create = 'Créer un tag',
            delete = 'Supprimer un tag',
            push = 'Pousser un tag',
            list = 'Lister les tags',
            enter_name = 'Nom du tag :',
            enter_message = 'Message du tag :',
            select_tag = 'Sélectionnez un tag',
            confirm_delete = 'Voulez-vous supprimer le tag %{tag} ?',
            error = {
                invalid_name = 'Nom de tag invalide',
                not_found = 'Tag non trouvé',
                already_exists = 'Le tag existe déjà'
            }
        },
        stash = {
            save = 'Sauvegarder les modifications',
            pop = 'Appliquer et supprimer un stash',
            apply = 'Appliquer un stash',
            drop = 'Supprimer un stash',
            list = 'Lister les stash',
            enter_message = 'Message du stash :',
            select_stash = 'Sélectionnez un stash',
            confirm_drop = 'Voulez-vous supprimer ce stash ?',
            error = {
                no_changes = 'Aucun changement à sauvegarder',
                not_found = 'Stash non trouvé'
            }
        },
        search = {
            commits = 'Rechercher dans les commits',
            files = 'Rechercher dans les fichiers',
            content = 'Rechercher dans le contenu',
            enter_query = 'Recherche :',
            error = {
                empty_query = 'La recherche ne peut pas être vide',
                no_results = 'Aucun résultat trouvé'
            }
        },
        rebase = {
            interactive = 'Rebase interactif',
            onto = 'Rebase sur une branche',
            continue = 'Continuer le rebase',
            abort = 'Annuler le rebase',
            error = {
                in_progress = 'Un rebase est déjà en cours',
                no_changes = 'Rien à rebaser'
            }
        },
        backup = {
            create = 'Créer une sauvegarde',
            restore = 'Restaurer une sauvegarde',
            list = 'Lister les sauvegardes',
            delete = 'Supprimer une sauvegarde',
            enter_name = 'Nom de la sauvegarde :',
            select_backup = 'Sélectionnez une sauvegarde',
            confirm_delete = 'Voulez-vous supprimer la sauvegarde %{backup} ?',
            error = {
                invalid_name = 'Nom de sauvegarde invalide',
                not_found = 'Sauvegarde non trouvée',
                already_exists = 'La sauvegarde existe déjà'
            }
        },
        error = {
            invalid_menu = 'Menu invalide',
            command_failed = 'La commande a échoué',
            not_git_repo = 'Ce n\'est pas un dépôt Git',
            unknown = 'Une erreur inconnue est survenue'
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
