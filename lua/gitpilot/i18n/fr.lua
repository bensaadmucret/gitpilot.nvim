return {
    -- Messages généraux
    welcome = "Bienvenue dans GitPilot !",
    select_action = "Sélectionnez une action :",
    confirm = {
        title = "Confirmation requise",
        yes = "Oui",
        no = "Non"
    },
    cancel = "Annuler",
    success = "Succès !",
    error = "Erreur",
    warning = "Attention",
    
    -- Menu principal
    menu = {
        main_title = "🚀 GitPilot - Menu Principal",
        main = "Menu Principal",
        commits = "Opérations de Commit",
        commits_title = "📝 Gestion des Commits",
        branches = "Opérations de Branche",
        branches_title = "🌿 Gestion des Branches",
        remotes = "Opérations de Remote",
        remotes_title = "🔄 Gestion des Remotes",
        tags = "Opérations de Tag",
        tags_title = "🏷️ Gestion des Tags",
        stash = "Opérations de Stash",
        stash_title = "📦 Gestion des Stash",
        search = "Opérations de Recherche",
        search_title = "🔍 Recherche",
        rebase = "Opérations de Rebase",
        rebase_title = "♻️ Rebase"
    },

    -- Gestion des commits
    commit = {
        title = "📝 Gestion des Commits",
        create = "Créer un commit",
        amend = "Modifier le dernier commit",
        files = {
            none = "Aucun fichier modifié",
            select = "Sélectionnez les fichiers à commiter :"
        },
        type = {
            select = "Sélectionnez le type de commit :",
            feat = "Nouvelle fonctionnalité",
            fix = "Correction de bug",
            docs = "Documentation",
            style = "Style et formatage",
            refactor = "Refactoring",
            test = "Tests",
            chore = "Maintenance"
        },
        message = {
            prompt = "Message du commit :",
            empty = "Le message de commit ne peut pas être vide"
        },
        action = {
            success = "Commit créé avec succès",
            error = "Erreur lors du commit : %s",
            amend_success = "Commit modifié avec succès",
            amend_error = "Erreur lors de la modification du commit : %s"
        }
    },

    -- Gestion des branches
    branch = "Branche",
    branch_actions = {
        create_success = "Branche %{name} créée",
        checkout_success = "Branche %{name} sélectionnée",
        delete_success = "Branche %{name} supprimée",
        merge_success = "Branche %{name} fusionnée",
        
        -- Interface utilisateur
        title = "🌿 Gestion des Branches",
        create_new = "Créer une nouvelle branche",
        enter_name = "Nom de la nouvelle branche :",
        checkout = "Changer de branche",
        delete = "Supprimer une branche",
        merge = "Fusionner une branche",
        refresh = "Rafraîchir la liste des branches",
        
        -- Messages de succès
        success = {
            created = "Branche '%{name}' créée avec succès",
            checked_out = "Basculé sur la branche '%{name}'",
            merged = "Branche '%{name}' fusionnée avec succès",
            deleted = "Branche '%{name}' supprimée"
        },
        
        -- Messages d'erreur
        error = {
            create_failed = "Erreur lors de la création de la branche '%{name}'",
            checkout_failed = "Erreur lors du basculement vers la branche '%{name}'",
            delete_failed = "Erreur lors de la suppression de la branche '%{name}'",
            merge_conflict = "Conflits détectés lors de la fusion de '%{name}'",
            list_failed = "Impossible de lister les branches"
        }
    },

    -- Gestion des remotes
    remote = {
        title = "🔄 Gestion des Remotes",
        add = "Ajouter un remote",
        remove = "Supprimer un remote",
        push = "Pousser les modifications",
        pull = "Récupérer les modifications",
        none = "Aucun remote trouvé",
        name = {
            prompt = "Nom du remote :"
        },
        url = {
            prompt = "URL du remote :"
        },
        added = "Remote ajouté avec succès",
        deleted = "Remote supprimé",
        fetched = "Remote mis à jour",
        url = "URL",
        tracking_info = "Informations de suivi",
        details_title = "Détails du remote",
        push = {
            normal = "Normal (par défaut)",
            force = "Force (--force)",
            force_lease = "Force avec bail (--force-with-lease)"
        },
        action = {
            success = "Opération sur le remote effectuée avec succès",
            error = "Erreur lors de l'opération sur le remote : %s"
        }
    },

    -- Gestion des tags
    tag = {
        title = "🏷️ Gestion des Tags",
        none = "Aucun tag trouvé",
        message = "Message",
        commit_info = "Informations du commit",
        details_title = "Détails du tag",
        create = {
            title = "Créer un Tag",
            name_prompt = "Nom du tag :",
            message_prompt = "Message (optionnel) :",
            success = "Tag '%s' créé avec succès",
            error = "Erreur lors de la création du tag : %s",
            exists = "Le tag '%s' existe déjà"
        },
        delete = {
            title = "Supprimer un Tag",
            prompt = "Sélectionnez le tag à supprimer :",
            confirm = "Supprimer le tag '%s' ? Cette action est irréversible !",
            success = "Tag '%s' supprimé avec succès",
            error = "Erreur lors de la suppression du tag : %s"
        },
        push = {
            title = "Pousser les Tags",
            prompt = "Sélectionnez les tags à pousser :",
            confirm = "Pousser les tags sélectionnés ?",
            success = "Tags poussés avec succès",
            error = "Erreur lors de la poussée des tags : %s"
        }
    },

    -- Gestion des stash
    stash = {
        title = "📦 Gestion des Stash",
        none = "Aucun stash trouvé",
        create = {
            title = "Créer un Stash",
            message_prompt = "Message du stash (optionnel) :",
            success = "Stash créé avec succès",
            error = "Erreur lors de la création du stash : %s",
            no_changes = "Aucune modification à stasher"
        },
        apply = {
            title = "Appliquer un Stash",
            prompt = "Sélectionnez le stash à appliquer :",
            success = "Stash appliqué avec succès",
            error = "Erreur lors de l'application du stash : %s"
        },
        delete = {
            title = "Supprimer un Stash",
            prompt = "Sélectionnez le stash à supprimer :",
            confirm = "Supprimer le stash sélectionné ? Cette action est irréversible !",
            success = "Stash supprimé avec succès",
            error = "Erreur lors de la suppression du stash : %s"
        }
    },

    -- Recherche
    search = {
        title = "🔍 Recherche",
        prompt = "Entrez votre recherche :",
        no_results = "Aucun résultat trouvé",
        commits = {
            title = "Rechercher dans les commits",
            prompt = "Entrez le terme de recherche :",
            empty = "Le terme de recherche ne peut pas être vide",
            none = "Aucun commit trouvé",
            no_results = "Aucun résultat trouvé pour cette recherche",
            details_error = "Erreur lors de la récupération des détails du commit",
            details_title = "Détails du commit %s",
            details = "Détails"
        },
        files = {
            prompt = "Entrez le motif de recherche :",
            none = "Aucun fichier trouvé",
            results = "Résultats de la recherche"
        },
        author = {
            prompt = "Entrez le nom de l'auteur :",
            none = "Aucun commit trouvé pour cet auteur",
            results = "Commits par %s"
        },
        branches = {
            prompt = "Entrez le motif de recherche :",
            none = "Aucune branche trouvée",
            results = "Branches trouvées",
            switched = "Changé pour la branche"
        }
    },
    git = {
        error = {
            not_repo = "Ce dossier n'est pas un dépôt Git",
            command_failed = "La commande Git a échoué"
        }
    },
    
    -- Tests
    test = {
        message_only_in_english = "Test Message"
    }
}
