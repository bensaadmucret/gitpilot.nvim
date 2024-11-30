return {
    -- Messages généraux
    welcome = "Bienvenue dans GitPilot !",
    select_action = "Sélectionnez une action :",
    confirm = "Confirmer",
    cancel = "Annuler",
    success = "Succès !",
    error = "Erreur",
    warning = "Attention",
    
    -- Menu principal
    menu = {
        main = "Menu Principal",
        commits = "📝 Gérer les commits",
        commits_title = "📝 Gestion des commits",
        branches = "🌿 Gérer les branches",
        branches_title = "🌿 Gestion des branches",
        remotes = "🔄 Gérer les dépôts distants",
        remotes_title = "🔄 Gestion des dépôts distants",
        tags = "🏷️ Gérer les tags",
        tags_title = "🏷️ Gestion des tags",
        stash = "📦 Gestion du stash",
        stash_title = "📦 Gestion du stash",
        search = "🔍 Rechercher",
        search_title = "🔍 Recherche",
        rebase = "🔄 Assistant de rebase",
        rebase_title = "🔄 Assistant de rebase",
        
        -- Sous-menu des commits
        create_commit = "📝 Créer un nouveau commit",
        amend_commit = "✏️ Modifier le dernier commit",
        history = "📜 Voir l'historique des commits",

        -- Sous-menu des remotes
        add_remote = "➕ Ajouter un dépôt distant",
        remove_remote = "❌ Supprimer un dépôt distant",
        fetch = "⬇️ Récupérer les modifications",
        push = "⬆️ Pousser les modifications",

        -- Sous-menu des tags
        create_tag = "➕ Créer un tag",
        delete_tag = "❌ Supprimer un tag",
        list_tags = "📋 Lister les tags",
        push_tags = "⬆️ Pousser les tags",

        -- Sous-menu des branches
        create_branch = "➕ Créer une nouvelle branche",
        switch_branch = "🔄 Changer de branche",
        merge_branch = "🔀 Fusionner une branche",
        delete_branch = "❌ Supprimer une branche",
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

    -- Messages pour les branches
    branch_messages = {
        current = "branche actuelle",
        create = "➕ Créer une nouvelle branche",
        switch = "🔄 Changer de branche",
        merge = "🔀 Fusionner une branche",
        delete = "❌ Supprimer une branche",
        create_title = "Créer une nouvelle branche",
        switch_title = "Changer de branche",
        merge_title = "Fusionner une branche",
        delete_title = "Supprimer une branche",
        switch_success = "Basculé sur la branche '%{name}'",
        create_success = "Branche '%{name}' créée avec succès",
        merge_success = "Fusion de la branche '%{name}' réussie",
        delete_success = "Branche '%{name}' supprimée avec succès",
        error_exists = "La branche '%{name}' existe déjà",
        error_not_exists = "La branche '%{name}' n'existe pas",
        error_current = "Impossible de supprimer la branche courante",
        confirm_delete = "Êtes-vous sûr de vouloir supprimer la branche '%{name}' ?",
    },

    -- Gestion des tags
    tag = {
        name = {
            prompt = "Entrez le nom du tag :",
            invalid = "Nom de tag invalide"
        },
        message = {
            prompt = "Entrez le message du tag (optionnel pour tag léger) :",
        },
        exists = "Ce tag existe déjà",
        created_light = "Tag léger créé avec succès",
        created_annotated = "Tag annoté créé avec succès",
        none = "Aucun tag trouvé",
        confirm_delete = "Êtes-vous sûr de vouloir supprimer le tag '%s' ? (o/N)",
        deleted = "Tag '%s' supprimé avec succès",
        delete_title = "Supprimer un Tag",
        push_success = "Tags poussés avec succès",
        push_error = "Erreur lors du push des tags : %s"
    },

    -- Gestion des dépôts distants
    remote = {
        title = "🔄 Gestion des Dépôts Distants",
        none = "Aucun dépôt distant trouvé",
        name = {
            prompt = "Entrez le nom du dépôt distant :",
            invalid = "Nom de dépôt distant invalide",
            exists = "Un dépôt distant avec ce nom existe déjà"
        },
        url = {
            prompt = "Entrez l'URL du dépôt distant :",
            invalid = "URL de dépôt distant invalide"
        },
        add = {
            title = "Ajouter un Dépôt Distant",
            success = "Dépôt distant '%s' ajouté avec succès",
            error = "Erreur lors de l'ajout du dépôt distant : %s"
        },
        remove = {
            title = "Supprimer un Dépôt Distant",
            select = "Sélectionnez le dépôt distant à supprimer :",
            confirm = "Êtes-vous sûr de vouloir supprimer le dépôt distant '%s' ?",
            success = "Dépôt distant '%s' supprimé avec succès",
            error = "Erreur lors de la suppression du dépôt distant : %s"
        },
        fetch = {
            title = "Récupérer les Modifications",
            all = "Récupérer depuis tous les dépôts distants",
            specific = "Récupérer depuis '%s'",
            success = "Modifications récupérées avec succès",
            error = "Erreur lors de la récupération des modifications : %s"
        },
        push = {
            title = "Pousser les Modifications",
            select_remote = "Sélectionnez le dépôt distant de destination :",
            select_branch = "Sélectionnez la branche à pousser :",
            confirm = "Pousser vers %s/%s ?",
            force = "Pousser en force (--force-with-lease)",
            success = "Modifications poussées avec succès",
            error = "Erreur lors du push des modifications : %s"
        },
        pull = {
            title = "Tirer les Modifications",
            select_remote = "Sélectionnez le dépôt distant source :",
            select_branch = "Sélectionnez la branche à tirer :",
            confirm = "Tirer depuis %s/%s ?",
            success = "Modifications tirées avec succès",
            error = "Erreur lors du pull des modifications : %s"
        }
    },

    -- Rebase assistant
    rebase = {
        intro = "Assistant de Rebase Interactif",
        warning = "⚠️ Cette opération va modifier l'historique",
        backup = "Une sauvegarde sera créée automatiquement",
        title = "📝 Rebase Interactif - Organisez vos commits",
        help_title = "❓ Guide d'utilisation",
        action = {
            pick = "✅ Garder le commit tel quel",
            reword = "📝 Modifier le message",
            edit = "🔧 Modifier le contenu",
            squash = "🔗 Fusionner avec le précédent (garder les deux messages)",
            fixup = "🔗 Fusionner avec le précédent (garder uniquement le message précédent)",
            drop = "❌ Supprimer ce commit"
        },
        help_move = "↑/↓ (j/k) : Navigation | J/K : Déplacer le commit",
        help_start = "ENTRÉE : Démarrer le rebase | P : Prévisualiser les changements",
        help_cancel = "q/ÉCHAP : Annuler",
        no_commits = "⚠️ Aucun commit à réorganiser",
        started = "✨ Rebase interactif démarré",
        preview = "🔍 Prévisualisation des changements",
        conflicts = {
            title = "⚠️ Conflits Détectés - Résolution Requise",
            actions = "Actions disponibles :",
            no_conflicts = "✅ Aucun conflit à résoudre",
            ours = "Garder NOS modifications",
            theirs = "Garder LEURS modifications",
            add = "Marquer comme résolu",
            continue = "Continuer le rebase",
            skip = "Passer ce commit",
            abort = "Annuler le rebase",
            resolved = "✅ Conflit résolu pour %s",
            done = "🎉 Tous les conflits sont résolus !"
        }
    },

    -- Résolution de conflits
    conflict = {
        found = "Conflits détectés dans les fichiers :",
        none = "Aucun conflit détecté",
        options = {
            ours = "Garder nos modifications",
            theirs = "Garder leurs modifications",
            both = "Garder les deux",
            manual = "Éditer manuellement"
        },
        help = "Utilisez les flèches pour naviguer et Entrée pour sélectionner"
    },

    -- Gestionnaire de stash
    stash = {
        title = "📦 Gestion du Stash",
        select_files = "Sélectionnez les fichiers à remiser",
        no_changes = "Aucune modification à remiser",
        none = "Aucun stash trouvé",
        create = {
            prompt = "Entrez un message pour le stash (optionnel) :",
            success = "Modifications remisées avec succès",
            error = "Erreur lors de la remise des modifications"
        },
        apply = {
            title = "Appliquer le Stash",
            confirm = "Appliquer le stash '%s' ?",
            success = "Stash appliqué avec succès",
            error = "Erreur lors de l'application du stash"
        },
        delete = {
            title = "Supprimer le Stash",
            confirm = "Supprimer le stash '%s' ? (o/N)",
            success = "Stash supprimé avec succès",
            error = "Erreur lors de la suppression du stash"
        },
        navigation = {
            select_all = "Tout sélectionner",
            deselect_all = "Tout désélectionner",
            toggle = "Basculer la sélection",
            confirm = "Confirmer",
            cancel = "Annuler"
        }
    },

    -- Menu de recherche
    search = {
        title = "🔍 Recherche",
        no_results = "Aucun résultat trouvé",
        commits = {
            title = "Rechercher dans les Commits",
            prompt = "Entrez un terme de recherche pour les commits :",
            results = "Résultats de Recherche - Commits",
            none = "Aucun commit correspondant trouvé",
            details = "Détails du Commit",
            copy_hash = "Hash copié dans le presse-papiers",
            by_message = "Rechercher par message de commit",
            by_files = "Rechercher par fichiers modifiés"
        },
        files = {
            title = "Rechercher des Fichiers",
            prompt = "Entrez un motif de recherche pour les fichiers :",
            results = "Résultats de Recherche - Fichiers",
            none = "Aucun fichier correspondant trouvé",
            in_content = "Rechercher dans le contenu des fichiers",
            by_name = "Rechercher par nom de fichier",
            by_extension = "Rechercher par extension"
        },
        author = {
            title = "Rechercher par Auteur",
            prompt = "Entrez le nom de l'auteur :",
            results = "Résultats de Recherche - Commits par Auteur",
            none = "Aucun commit trouvé pour cet auteur",
            email = "Rechercher par email",
            name = "Rechercher par nom"
        },
        branches = {
            title = "Rechercher des Branches",
            prompt = "Entrez un motif de recherche pour les branches :",
            results = "Résultats de Recherche - Branches",
            none = "Aucune branche correspondante trouvée",
            local = "Branches locales",
            remote = "Branches distantes",
            all = "Toutes les branches"
        },
        navigation = {
            next = "Résultat suivant",
            previous = "Résultat précédent",
            details = "Afficher les détails",
            close = "Fermer",
            help = "Appuyez sur '?' pour l'aide"
        }
    },

    -- Messages d'aide contextuelle
    help = {
        rebase = "Le rebase permet de réorganiser vos commits. Suivez le guide !",
        conflict = "Un conflit survient quand deux modifications se chevauchent.",
        stash = "Le stash permet de mettre de côté vos modifications temporairement.",
        general = "Appuyez sur ? pour l'aide, Échap pour annuler",
        keys = {
            navigation = "↑/↓: Navigation",
            select = "Entrée: Sélectionner",
            cancel = "Échap: Annuler",
            help = "?: Aide"
        }
    }
}
