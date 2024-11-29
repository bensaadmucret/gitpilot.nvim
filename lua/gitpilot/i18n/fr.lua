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
        commit = "📝 Créer un commit",
        branch = "🌿 Gérer les branches",
        rebase = "🔄 Assistant de rebase",
        conflict = "🚧 Résoudre les conflits",
        stash = "📦 Gérer les stash",
        history = "📜 Voir l'historique"
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
        merge = "🔗 Fusionner une branche",
        delete = "❌ Supprimer une branche",
        select = "Sélectionnez une branche :",
        select_merge = "Sélectionnez la branche à fusionner :",
        select_delete = "Sélectionnez la branche à supprimer :",
        confirm_merge = "Voulez-vous fusionner la branche",
        confirm_delete = "Voulez-vous supprimer la branche",
        created = "Branche créée",
        switched = "Changement vers la branche",
        merged = "Branche fusionnée",
        deleted = "Branche supprimée",
        cannot_delete_current = "Impossible de supprimer la branche courante",
        warning = {
            delete = "⚠️ Cette action est irréversible",
            unmerged = "⚠️ Cette branche n'est pas fusionnée"
        }
    },

    -- Rebase assistant
    rebase = {
        intro = "Assistant de rebase interactif",
        warning = "⚠️ Cette opération va modifier l'historique",
        backup = "Une sauvegarde sera créée automatiquement",
        options = {
            pick = "✅ Garder le commit",
            reword = "📝 Modifier le message",
            edit = "🔧 Modifier le commit",
            squash = "🔗 Fusionner avec le précédent",
            drop = "❌ Supprimer le commit"
        },
        help = {
            pick = "Utilise le commit tel quel",
            reword = "Utilise le commit mais modifie son message",
            edit = "Marque le commit pour modification",
            squash = "Fusionne avec le commit précédent",
            drop = "Supprime le commit"
        },
        title = "📝 Rebase Interactif - Organisez vos commits",
        help_title = "❓ Guide d'utilisation",
        action = {
            pick = "Conserver le commit",
            reword = "Modifier le message du commit",
            edit = "Modifier le contenu du commit",
            squash = "Fusionner avec le commit précédent (garde les deux messages)",
            fixup = "Fusionner avec le commit précédent (garde uniquement le message précédent)",
            drop = "Supprimer ce commit"
        },
        help_move = "↑/↓ (j/k) : Naviguer | J/K : Déplacer le commit",
        help_start = "ENTRÉE : Démarrer le rebase | P : Prévisualiser les changements",
        help_cancel = "q/ESC : Annuler",
        no_commits = "⚠️ Aucun commit à réorganiser",
        started = "✨ Rebase interactif démarré",
        preview = "🔍 Prévisualisation des changements",
        conflicts = {
            title = "⚠️ Conflits détectés - Résolution nécessaire",
            actions = "Actions disponibles :",
            no_conflicts = "✅ Aucun conflit à résoudre",
            ours = "Garder NOS modifications",
            theirs = "Garder LEURS modifications",
            add = "Marquer comme résolu",
            continue = "Continuer le rebase",
            skip = "Ignorer ce commit",
            abort = "Abandonner le rebase"
        },
        conflicts_resolved = "✅ Conflit résolu pour %s",
        conflicts_done = "🎉 Tous les conflits sont résolus !"
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
        create = "Créer un stash",
        apply = "Appliquer un stash",
        pop = "Récupérer et supprimer un stash",
        drop = "Supprimer un stash",
        list = "Liste des stash",
        empty = "Aucun stash disponible"
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
