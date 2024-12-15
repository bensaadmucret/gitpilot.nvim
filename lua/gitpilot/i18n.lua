-- lua/gitpilot/i18n.lua

local M = {}

-- Default language
local current_lang = 'en'

-- Configuration
local config = {
    language = 'en'
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
    en = {
        menu = {
            main_title = 'Main Menu',
            branch_title = 'Branch Management',
            commit_title = 'Commit Management',
            remote_title = 'Remote Management',
            tag_title = 'Tag Management',
            stash_title = 'Stash Management',
            search_title = 'Search',
            rebase_title = 'Rebase',
            backup_title = 'Backup',
            back = 'Back',
            branches = 'Branch Operations',
            commits = 'Commit Operations',
            remotes = 'Remote Operations',
            tags = 'Tag Operations',
            stash = 'Stash Operations',
            search = 'Search',
            rebase = 'Rebase',
            backup = 'Backup',
            help = 'Git Help'
        },
        ui = {
            select_prompt = 'Select an option',
            input_prompt = 'Enter a value',
            no_items = 'No items to display'
        },
        confirm = {
            prompt = 'Are you sure?',
            yes = 'Yes',
            no = 'No'
        },
        branch = {
            create_new = 'Create a new branch',
            checkout = 'Switch to a branch',
            merge = 'Merge a branch',
            delete = 'Delete a branch',
            push = 'Push the branch',
            pull = 'Pull the branch',
            rebase = 'Rebase the branch',
            refresh = 'Refresh',
            enter_name = 'Branch name:',
            select_checkout = 'Select a branch to switch to',
            select_merge = 'Select a branch to merge',
            select_delete = 'Select a branch to delete',
            select_rebase = 'Select a branch to rebase',
            info = {
                no_other_branches = 'No other branches available'
            },
            confirm_delete = 'Are you sure you want to delete the branch %{branch}?',
            confirm_push = 'Are you sure you want to push the branch %{branch}?',
            confirm_pull = 'Are you sure you want to pull the branch %{branch}?',
            confirm_rebase = 'Are you sure you want to rebase onto the branch %{branch}?',
            success = {
                created = 'Branch "%{branch}" created successfully',
                checked_out = 'Switched to branch "%{branch}"',
                merged = 'Branch "%{branch}" merged successfully',
                deleted = 'Branch "%{branch}" deleted successfully',
                pushed = 'Branch "%{branch}" pushed successfully',
                pulled = 'Branch "%{branch}" pulled successfully',
                rebased = 'Rebase onto branch "%{branch}" successful'
            },
            error = {
                not_git_repo = 'This is not a Git repository',
                invalid_name = 'Invalid branch name',
                already_exists = 'Branch "%{branch}" already exists',
                not_found = 'Branch "%{branch}" not found',
                create_failed = 'Failed to create branch "%{branch}"',
                checkout_failed = 'Failed to switch to branch "%{branch}"',
                merge_failed = 'Failed to merge branch "%{branch}"',
                delete_failed = 'Failed to delete branch "%{branch}"',
                delete_current = 'Cannot delete the current branch',
                invalid_start_point = 'Start point "%{branch}" does not exist',
                no_branches = 'No branches found',
                list_failed = 'Failed to retrieve branch list',
                unmerged = 'Branch "%{branch}" is not fully merged',
                uncommitted = 'You have uncommitted changes',
                no_upstream = 'Branch "%{branch}" has no upstream branch'
            }
        },
        commit = {
            create = 'Create a commit',
            amend = 'Amend the last commit',
            reset = 'Reset a commit',
            push = 'Push commits',
            pull = 'Pull commits',
            status = {
                title = 'Status of changes',
                window_title = 'GitPilot - Git Status',
                modified = 'Modified files',
                added = 'Added files',
                deleted = 'Deleted files',
                renamed = 'Renamed files',
                untracked = 'Untracked files'
            },
            enter_message = 'Commit message:',
            confirm_amend = 'Are you sure you want to amend the last commit?',
            confirm_fixup = 'Are you sure you want to fixup commit %{hash}?',
            confirm_revert = 'Are you sure you want to revert commit %{hash}?',
            success = {
                created = 'Commit created successfully',
                amended = 'Commit amended successfully',
                reverted = 'Commit reverted successfully',
                cherry_picked = 'Cherry-pick successful'
            },
            error = {
                not_git_repo = 'This is not a Git repository',
                no_changes = 'No changes to commit',
                create_failed = 'Failed to create commit',
                no_commits = 'No commits in history',
                amend_failed = 'Failed to amend the last commit',
                revert_failed = 'Failed to revert commit',
                cherry_pick_failed = 'Failed to cherry-pick',
                invalid_hash = 'Invalid commit hash',
                not_found = 'Commit not found',
                empty_message = 'Commit message cannot be empty'
            }
        },
        remote = {
            add = 'Add a remote',
            remove = 'Remove a remote',
            push = 'Push to a remote',
            pull = 'Pull from a remote',
            fetch = 'Fetch from a remote',
            prune = 'Prune remote branches',
            enter_name = 'Remote name:',
            enter_url = 'Remote URL:',
            select_remote = 'Select a remote',
            confirm_remove = 'Are you sure you want to remove remote %{remote}?',
            success = {
                added = 'Remote "%{name}" added successfully',
                removed = 'Remote "%{name}" removed successfully',
                fetched = 'Fetched from "%{name}" successfully',
                pulled = 'Pulled from remote successfully',
                pushed = 'Pushed to remote successfully',
                pruned = 'Pruned remote branches successfully'
            },
            error = {
                not_git_repo = 'This is not a Git repository',
                list_failed = 'Failed to retrieve remote list',
                no_remotes = 'No remotes found',
                invalid_name = 'Invalid remote name',
                invalid_url = 'Invalid remote URL',
                already_exists = 'Remote "%{name}" already exists',
                not_found = 'Remote "%{name}" not found',
                add_failed = 'Failed to add remote',
                remove_failed = 'Failed to remove remote',
                fetch_failed = 'Failed to fetch from remote',
                pull_failed = 'Failed to pull from remote',
                push_failed = 'Failed to push to remote',
                prune_failed = 'Failed to prune remote branches'
            }
        },
        tag = {
            create = 'Create a tag',
            delete = 'Delete a tag',
            push = 'Push a tag',
            list = 'List tags',
            enter_name = 'Tag name:',
            enter_message = 'Tag message:',
            select_tag = 'Select a tag',
            confirm_delete = 'Are you sure you want to delete tag %{tag}?',
            success = {
                created = 'Tag "%{name}" created successfully',
                deleted = 'Tag "%{name}" deleted successfully',
                pushed = 'Tag pushed successfully'
            },
            error = {
                not_git_repo = 'This is not a Git repository',
                invalid_name = 'Invalid tag name',
                not_found = 'Tag not found',
                already_exists = 'Tag "%{name}" already exists',
                create_failed = 'Failed to create tag',
                delete_failed = 'Failed to delete tag',
                push_failed = 'Failed to push tag'
            }
        },
        stash = {
            save = 'Save changes',
            pop = 'Apply and delete a stash',
            apply = 'Apply a stash',
            drop = 'Delete a stash',
            list = 'List stashes',
            enter_message = 'Stash message:',
            select_stash = 'Select a stash',
            confirm_drop = 'Are you sure you want to delete this stash?',
            success = {
                saved = 'Changes saved successfully',
                applied = 'Stash applied successfully',
                dropped = 'Stash deleted successfully'
            },
            error = {
                not_git_repo = 'This is not a Git repository',
                no_changes = 'No changes to save',
                not_found = 'Stash not found',
                save_failed = 'Failed to save changes',
                apply_failed = 'Failed to apply stash',
                drop_failed = 'Failed to delete stash'
            }
        },
        search = {
            commits = 'Search commits',
            files = 'Search files',
            content = 'Search content',
            enter_query = 'Search:',
            success = {
                found = 'Results found successfully'
            },
            error = {
                not_git_repo = 'This is not a Git repository',
                empty_query = 'Search query cannot be empty',
                no_results = 'No results found',
                search_failed = 'Failed to search'
            }
        },
        rebase = {
            interactive = 'Interactive rebase',
            onto = 'Rebase onto a branch',
            continue = 'Continue rebase',
            abort = 'Abort rebase',
            success = {
                rebased = 'Rebase successful'
            },
            error = {
                not_git_repo = 'This is not a Git repository',
                in_progress = 'A rebase is already in progress',
                no_changes = 'Nothing to rebase',
                rebase_failed = 'Failed to rebase'
            }
        },
        backup = {
            create = 'Create a backup',
            restore = 'Restore a backup',
            list = 'List backups',
            delete = 'Delete a backup',
            enter_name = 'Backup name:',
            select_backup = 'Select a backup',
            confirm_delete = 'Are you sure you want to delete backup %{backup}?',
            success = {
                created = 'Backup "%{name}" created successfully',
                restored = 'Backup "%{name}" restored successfully',
                deleted = 'Backup "%{name}" deleted successfully'
            },
            error = {
                not_git_repo = 'This is not a Git repository',
                invalid_name = 'Invalid backup name',
                not_found = 'Backup not found',
                already_exists = 'Backup "%{name}" already exists',
                create_failed = 'Failed to create backup',
                restore_failed = 'Failed to restore backup',
                delete_failed = 'Failed to delete backup'
            }
        },
        help = {
            title = 'Git Help - %{command}',
            menu_title = 'Git Help',
            command_not_found = 'Command not found. Please check the command name.',
            commit = 'Help on commits',
            branch = 'Help on branches',
            stash = 'Help on stashes',
            rebase = 'Help on rebase',
            tag = 'Help on tags'
        },
        error = {
            invalid_menu = 'Invalid menu',
            command_failed = 'Command failed',
            not_git_repo = 'This is not a Git repository',
            unknown = 'An unknown error occurred'
        }
    },
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
            backup = 'Sauvegarde',
            help = 'Aide Git'
        },
        ui = {
            select_prompt = 'Sélectionnez une option',
            input_prompt = 'Entrez une valeur',
            no_items = 'Aucun élément à afficher'
        },
        confirm = {
            prompt = 'Êtes-vous sûr ?',
            yes = 'Oui',
            no = 'Non'
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
            status = {
                title = 'Statut des modifications',
                window_title = 'GitPilot - Statut Git',
                modified = 'Fichiers modifiés',
                added = 'Fichiers ajoutés',
                deleted = 'Fichiers supprimés',
                renamed = 'Fichiers renommés',
                untracked = 'Fichiers non suivis'
            },
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
        help = {
            title = 'Aide Git - %{command}',
            menu_title = 'Aide Git',
            command_not_found = 'Commande non trouvée. Veuillez vérifier le nom de la commande.',
            commit = 'Aide sur les commits',
            branch = 'Aide sur les branches',
            stash = 'Aide sur les stashs',
            rebase = 'Aide sur le rebase',
            tag = 'Aide sur les tags'
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
    if not key then return "" end
    
    local parts = type(vim) == "table" and vim.split and vim.split(key, '.', { plain = true }) or {}
    local current = translations[current_lang]
    
    for _, part in ipairs(parts) do
        if type(current) ~= "table" then
            return key
        end
        current = current[part]
        if current == nil then
            return key
        end
    end
    
    if type(current) ~= "string" then
        return key
    end
    
    if vars then
        for k, v in pairs(vars) do
            current = current:gsub("%%{" .. k .. "}", tostring(v))
        end
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
