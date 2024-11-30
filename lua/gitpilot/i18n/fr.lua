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
        branches = "🌿 Gérer les branches",
        branches_title = "🌿 Gestion des branches",
        remotes = "🔄 Gérer les dépôts distants",
        tags = "🏷️ Gérer les tags",
        stash = "📦 Gérer les stash",
        search = "🔍 Rechercher",
        rebase = "🔄 Assistant de rebase",
        
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
    
    -- Commit assistant
    commit = {
        type = {
            title = "Type de modification :",
            feat = "✨ Nouvelle fonctionnalité",
            fix = "🐛 Correction de bug",
            docs = "📚 Documentation",
            style = "💎 Style du code",
            refactor = "♻️ Refactoring",
            test = "🧪 Tests",
            chore = "🔧 Maintenance"
        },
        files = {
            select = "Sélectionnez les fichiers à inclure :",
            selected = "Fichiers sélectionnés :",
            none = "Aucun fichier sélectionné",
            all = "Tout sélectionner",
            none_action = "Tout désélectionner"
        },
        message = {
            prompt = "Message du commit :",
            hint = "Décrivez brièvement vos changements",
            warning = "⚠️ Le message est trop court",
            template = "{type}: {description}"
        }
    },

    -- Gestion des branches
    branch = {
        current = "Branche actuelle :",
        create = "➕ Créer une nouvelle branche",
        switch = "🔄 Changer de branche",
        merge = "🔀 Fusionner une branche",
        delete = "❌ Supprimer une branche",
        
        create_title = "Créer une Nouvelle Branche",
        create_success = "Branche '%{name}' créée avec succès",
        create_error = "Erreur lors de la création : %{error}",
        
        switch_title = "Changer de Branche",
        switch_success = "Basculé sur la branche '%{name}'",
        switch_error = "Erreur de changement : %{error}",
        
        merge_title = "Fusionner une Branche",
        merge_confirm = "Fusionner '%{source}' dans '%{target}' ?",
        merge_success = "Fusion de '%{name}' réussie",
        merge_error = "Erreur de fusion : %{error}",
        
        delete_title = "Supprimer une Branche",
        delete_confirm = "Supprimer la branche '%{name}' ?",
        delete_success = "Branche '%{name}' supprimée",
        delete_error = "Erreur de suppression : %{error}",
        
        exists = "Cette branche existe déjà",
        none = "Aucune branche trouvée",
        already_on = "Vous êtes déjà sur cette branche",
        no_merge_candidates = "Aucune branche disponible pour la fusion",
        no_delete_candidates = "Aucune branche disponible pour la suppression",
        cannot_delete_current = "Impossible de supprimer la branche courante",
        
        warning = {
            delete = "⚠️ Cette action est irréversible",
            unmerged = "⚠️ Cette branche n'est pas fusionnée"
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
            prompt = "Nom du tag :"
        },
        message = {
            prompt = "Message (optionnel, Entrée pour un tag léger) :"
        },
        exists = "Ce tag existe déjà",
        none = "Aucun tag trouvé",
        created_light = "Tag léger créé avec succès",
        created_annotated = "Tag annoté créé avec succès",
        deleted = "Tag '%s' supprimé avec succès",
        pushed = "Tags poussés avec succès",
        confirm_delete = "Voulez-vous supprimer le tag '%s' ? (y/N)",
        delete_title = "🏷️ Supprimer un tag",
        error = {
            create = "Erreur lors de la création du tag",
            delete = "Erreur lors de la suppression du tag",
            push = "Erreur lors du push des tags"
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
        create = "➕ Créer un stash",
        apply = "📥 Appliquer un stash",
        drop = "❌ Supprimer un stash",
        message = {
            prompt = "Message du stash (optionnel) :"
        },
        no_changes = "Aucun changement à stasher",
        none = "Aucun stash trouvé",
        created = "Stash créé avec succès",
        applied = "Stash appliqué avec succès",
        dropped = "Stash supprimé avec succès",
        error = {
            create = "Erreur lors de la création du stash",
            apply = "Erreur lors de l'application du stash",
            drop = "Erreur lors de la suppression du stash"
        }
    },

    -- Menu de recherche
    search = {
        commits = "🔍 Rechercher dans les commits",
        files = "📁 Rechercher des fichiers",
        author = "👤 Rechercher par auteur",
        branches = "🌿 Rechercher des branches",
        
        commits_prompt = "Entrez le terme de recherche :",
        files_prompt = "Entrez le motif de fichier :",
        author_prompt = "Entrez le nom de l'auteur :",
        branches_prompt = "Entrez le motif de branche :",
        
        commits_none = "Aucun commit trouvé",
        files_none = "Aucun fichier trouvé",
        author_none = "Aucun commit trouvé pour cet auteur",
        branches_none = "Aucune branche trouvée",
        
        commits_results = "Résultats - Commits",
        files_results = "Résultats - Fichiers",
        author_results = "Résultats - Auteur",
        branches_results = "Résultats - Branches"
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
