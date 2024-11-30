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
        rebase_title = "♻️ Rebase",
        history = "📜 Voir l'historique",
        
        -- Sous-menu des commits
        create_commit = "📝 Créer un nouveau commit",
        amend_commit = "✏️ Modifier le dernier commit",
        show_history = "📜 Voir l'historique",
        discard = "🗑️ Abandonner les modifications",
        
        -- Sous-menu des remotes
        add_remote = "➕ Ajouter un dépôt distant",
        remove_remote = "❌ Supprimer un dépôt distant",
        fetch = "⬇️ Récupérer les modifications",
        push = "⬆️ Pousser les modifications",

        -- Sous-menu des tags
        create_tag = "➕ Créer un tag",
        delete_tag = "❌ Supprimer un tag",
        list_tags = "📋 Lister les tags",
        push_tags = "⬆️ Pousser les tags"
    },
    
    -- Gestion des commits
    commit = {
        title = "📝 Gestion des Commits",
        files = {
            select = "Sélectionnez les fichiers à commiter",
            selected = "Fichiers sélectionnés",
            none = "Aucun fichier à commiter",
            all = "Sélectionner tous les fichiers",
            none_action = "Désélectionner tous les fichiers",
            staged = "Fichiers indexés",
            unstaged = "Fichiers non indexés"
        },
        type = {
            title = "Sélectionnez le type de commit",
            feat = "✨ Nouvelle fonctionnalité",
            fix = "🐛 Correction de bug",
            docs = "📚 Documentation",
            style = "💎 Style du code",
            refactor = "♻️ Refactorisation du code",
            perf = "⚡ Amélioration des performances",
            test = "🧪 Tests",
            build = "🔧 Système de build",
            ci = "👷 CI/CD",
            chore = "🔨 Maintenance",
            revert = "⏪ Annulation des changements"
        },
        message = {
            title = "Message du Commit",
            prompt = "Entrez le message du commit :",
            hint = "Description brève des changements",
            scope = "Entrez la portée (optionnel) :",
            body = "Entrez une description détaillée (optionnel) :",
            breaking = "Changements majeurs (optionnel) :",
            footer = "Notes de bas de page (optionnel) :",
            preview = "Aperçu du message de commit :",
            empty = "Le message de commit ne peut pas être vide",
            too_short = "Le message de commit est trop court"
        },
        action = {
            create = "Créer le commit",
            amend = "Modifier le dernier commit",
            success = "Changements commités avec succès",
            amend_success = "Commit modifié avec succès",
            error = "Erreur lors de la création du commit : %s",
            amend_error = "Erreur lors de la modification du commit : %s",
            cancel = "Commit annulé"
        },
        status = {
            staged = "Changements indexés",
            unstaged = "Changements non indexés",
            untracked = "Fichiers non suivis",
            no_changes = "Aucun changement à commiter"
        }
    },
    
    -- Gestion des branches
    branch = {
        title = "🌿 Gestion des Branches",
        current = "Branche actuelle : %s",
        none = "Aucune branche trouvée",
        create = {
            title = "Créer une Nouvelle Branche",
            prompt = "Entrez le nom de la branche :",
            from = "Créer à partir de : %s",
            success = "Branche '%s' créée avec succès",
            error = "Erreur lors de la création de la branche : %s",
            exists = "La branche '%s' existe déjà",
            invalid = "Nom de branche invalide"
        },
        switch = {
            title = "Changer de Branche",
            prompt = "Sélectionnez la branche de destination :",
            confirm = "Basculer vers la branche '%s' ?",
            success = "Basculé vers la branche '%s'",
            error = "Erreur lors du changement de branche : %s",
            unsaved = "Vous avez des modifications non sauvegardées. Remisez-les ou commitez-les d'abord"
        },
        merge = {
            title = "Fusionner une Branche",
            prompt = "Sélectionnez la branche à fusionner dans la branche actuelle :",
            confirm = "Fusionner '%s' dans '%s' ?",
            success = "Branche '%s' fusionnée avec succès",
            error = "Erreur lors de la fusion : %s",
            conflict = "Conflits de fusion détectés",
            abort = "Fusion annulée",
            no_ff = "Fusion avec commit (no fast-forward)",
            squash = "Fusion avec écrasement (squash)"
        },
        delete = {
            title = "Supprimer une Branche",
            prompt = "Sélectionnez la branche à supprimer :",
            confirm = "Supprimer la branche '%s' ? Cette action est irréversible ! (o/N)",
            success = "Branche '%s' supprimée avec succès",
            error = "Erreur lors de la suppression de la branche : %s",
            unmerged = "La branche '%s' n'est pas entièrement fusionnée",
            force = "Forcer la suppression de la branche non fusionnée ?"
        },
        status = {
            ahead = "%d commits en avance sur '%s'",
            behind = "%d commits en retard sur '%s'",
            diverged = "Divergé de '%s' de %d commits",
            up_to_date = "À jour avec '%s'",
            local_only = "Branche locale uniquement",
            tracking = "Suit '%s'"
        },
        type = {
            local = "Branche locale",
            remote = "Branche distante",
            tracking = "Branche de suivi"
        }
    },
    
    -- Gestion des tags
    tag = {
        title = "🏷️ Gestion des Tags",
        none = "Aucun tag trouvé",
        name = {
            prompt = "Entrez le nom du tag :",
            invalid = "Nom de tag invalide"
        },
        message = {
            prompt = "Entrez le message du tag (optionnel) :",
            preview = "Aperçu du message du tag :"
        },
        create = {
            title = "Créer un Tag",
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
            prompt = "Entrez un message pour le stash (optionnel) :",
            success = "Modifications remisées avec succès",
            error = "Erreur lors de la remise des modifications : %s",
            no_changes = "Aucune modification à remiser"
        },
        apply = {
            title = "Appliquer un Stash",
            prompt = "Sélectionnez le stash à appliquer :",
            confirm = "Appliquer le stash '%s' ?",
            success = "Stash appliqué avec succès",
            error = "Erreur lors de l'application du stash : %s",
            conflict = "Conflits détectés lors de l'application du stash"
        },
        drop = {
            title = "Supprimer un Stash",
            prompt = "Sélectionnez le stash à supprimer :",
            confirm = "Supprimer le stash '%s' ? Cette action est irréversible !",
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
            title = "Rechercher dans les Commits",
            prompt = "Rechercher des commits :",
            author = "Auteur",
            date = "Date",
            message = "Message"
        },
        files = {
            title = "Rechercher dans les Fichiers",
            prompt = "Rechercher des fichiers :",
            path = "Chemin",
            content = "Contenu"
        }
    }
}
