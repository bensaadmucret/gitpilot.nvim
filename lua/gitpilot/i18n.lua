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
            info = {
                no_other_branches = 'Aucune autre branche disponible'
            },
            confirm_delete = 'Voulez-vous vraiment supprimer la branche %{branch} ?',
            confirm_push = 'Voulez-vous pousser la branche %{branch} ?',
            confirm_pull = 'Voulez-vous tirer la branche %{branch} ?',
            confirm_rebase = 'Voulez-vous rebaser sur la branche %{branch} ?',
            success = {
                created = 'Branche "%{branch}" créée avec succès',
                checked_out = 'Basculé sur la branche "%{branch}"',
                merged = 'Branche "%{branch}" fusionnée avec succès',
                deleted = 'Branche "%{branch}" supprimée avec succès',
                pushed = 'Branche "%{branch}" poussée avec succès',
                pulled = 'Branche "%{branch}" tirée avec succès',
                rebased = 'Rebase de la branche "%{branch}" effectué avec succès'
            },
            error = {
                not_git_repo = 'Ce n\'est pas un dépôt Git',
                invalid_name = 'Nom de branche invalide',
                already_exists = 'La branche "%{branch}" existe déjà',
                not_found = 'La branche "%{branch}" n\'existe pas',
                create_failed = 'Échec de la création de la branche "%{branch}"',
                checkout_failed = 'Échec du basculement vers la branche "%{branch}"',
                merge_failed = 'Échec de la fusion de la branche "%{branch}"',
                delete_failed = 'Échec de la suppression de la branche "%{branch}"',
                delete_current = 'Impossible de supprimer la branche courante',
                invalid_start_point = 'Le point de départ "%{branch}" n\'existe pas',
                no_branches = 'Aucune branche trouvée',
                list_failed = 'Échec de la récupération de la liste des branches',
                unmerged = 'La branche "%{branch}" n\'est pas entièrement fusionnée',
                uncommitted = 'Vous avez des modifications non commitées',
                no_upstream = 'La branche "%{branch}" n\'a pas de branche amont'
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
            success = {
                created = 'Commit créé avec succès',
                amended = 'Commit modifié avec succès',
                reverted = 'Commit annulé avec succès',
                cherry_picked = 'Cherry-pick effectué avec succès'
            },
            error = {
                not_git_repo = 'Ce n\'est pas un dépôt Git',
                no_changes = 'Aucun changement à commiter',
                create_failed = 'Échec de la création du commit',
                no_commits = 'Aucun commit dans l\'historique',
                amend_failed = 'Échec de la modification du dernier commit',
                revert_failed = 'Échec de l\'annulation du commit',
                cherry_pick_failed = 'Échec du cherry-pick',
                invalid_hash = 'Hash de commit invalide',
                not_found = 'Commit non trouvé',
                empty_message = 'Le message ne peut pas être vide'
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
            success = {
                added = 'Remote "%{name}" ajouté avec succès',
                removed = 'Remote "%{name}" supprimé avec succès',
                fetched = 'Mise à jour depuis "%{name}" effectuée avec succès',
                pulled = 'Tiré depuis le remote avec succès',
                pushed = 'Poussé vers le remote avec succès',
                pruned = 'Nettoyage des branches distantes effectué avec succès'
            },
            error = {
                not_git_repo = 'Ce n\'est pas un dépôt Git',
                list_failed = 'Échec de la récupération de la liste des remotes',
                no_remotes = 'Aucun remote trouvé',
                invalid_name = 'Nom de remote invalide',
                invalid_url = 'URL de remote invalide',
                already_exists = 'Le remote "%{name}" existe déjà',
                not_found = 'Le remote "%{name}" n\'existe pas',
                add_failed = 'Échec de l\'ajout du remote',
                remove_failed = 'Échec de la suppression du remote',
                fetch_failed = 'Échec de la mise à jour depuis le remote',
                pull_failed = 'Échec du tirage depuis le remote',
                push_failed = 'Échec de la poussée vers le remote',
                prune_failed = 'Échec du nettoyage des branches distantes'
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
            success = {
                created = 'Tag "%{name}" créé avec succès',
                deleted = 'Tag "%{name}" supprimé avec succès',
                pushed = 'Tag poussé avec succès'
            },
            error = {
                not_git_repo = 'Ce n\'est pas un dépôt Git',
                invalid_name = 'Nom de tag invalide',
                not_found = 'Tag non trouvé',
                already_exists = 'Le tag "%{name}" existe déjà',
                create_failed = 'Échec de la création du tag',
                delete_failed = 'Échec de la suppression du tag',
                push_failed = 'Échec de la poussée du tag'
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
            success = {
                saved = 'Modifications sauvegardées avec succès',
                applied = 'Stash appliqué avec succès',
                dropped = 'Stash supprimé avec succès'
            },
            error = {
                not_git_repo = 'Ce n\'est pas un dépôt Git',
                no_changes = 'Aucun changement à sauvegarder',
                not_found = 'Stash non trouvé',
                save_failed = 'Échec de la sauvegarde des modifications',
                apply_failed = 'Échec de l\'application du stash',
                drop_failed = 'Échec de la suppression du stash'
            }
        },
        search = {
            commits = 'Rechercher dans les commits',
            files = 'Rechercher dans les fichiers',
            content = 'Rechercher dans le contenu',
            enter_query = 'Recherche :',
            success = {
                found = 'Résultats trouvés avec succès'
            },
            error = {
                not_git_repo = 'Ce n\'est pas un dépôt Git',
                empty_query = 'La recherche ne peut pas être vide',
                no_results = 'Aucun résultat trouvé',
                search_failed = 'Échec de la recherche'
            }
        },
        rebase = {
            interactive = 'Rebase interactif',
            onto = 'Rebase sur une branche',
            continue = 'Continuer le rebase',
            abort = 'Annuler le rebase',
            success = {
                rebased = 'Rebase effectué avec succès'
            },
            error = {
                not_git_repo = 'Ce n\'est pas un dépôt Git',
                in_progress = 'Un rebase est déjà en cours',
                no_changes = 'Rien à rebaser',
                rebase_failed = 'Échec du rebase'
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
            success = {
                created = 'Sauvegarde "%{name}" créée avec succès',
                restored = 'Sauvegarde "%{name}" restaurée avec succès',
                deleted = 'Sauvegarde "%{name}" supprimée avec succès'
            },
            error = {
                not_git_repo = 'Ce n\'est pas un dépôt Git',
                invalid_name = 'Nom de sauvegarde invalide',
                not_found = 'Sauvegarde non trouvée',
                already_exists = 'La sauvegarde "%{name}" existe déjà',
                create_failed = 'Échec de la création de la sauvegarde',
                restore_failed = 'Échec de la restauration de la sauvegarde',
                delete_failed = 'Échec de la suppression de la sauvegarde'
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
function M.t(key, vars)
    local parts = vim.split(key, '.', { plain = true })
    local current = translations[current_lang]
    
    for _, part in ipairs(parts) do
        if current[part] then
            current = current[part]
        else
            return key
        end
    end
    
    if type(current) ~= 'string' then
        return key
    end
    
    -- Si des variables sont fournies, les substituer dans la traduction
    if vars then
        local result = current
        for name, value in pairs(vars) do
            result = result:gsub("%%{" .. name .. "}", value)
        end
        return result
    end
    
    return current
end

-- Set current language
function M.set_lang(lang)
    if translations[lang] then
        current_lang = lang
    end
end

return M
