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
        rebase_title = "♻️ Rebase"
    },

    -- Gestion des branches
    branch = {
        title = "🌿 Gestion des Branches",
        current = "Branche actuelle : %s",
        none = "Aucune branche trouvée",
        create = {
            title = "Créer une branche",
            prompt = "Nom de la nouvelle branche :",
            success = "Branche '%s' créée avec succès",
            error = "Erreur lors de la création de la branche : %s",
            exists = "La branche '%s' existe déjà"
        },
        delete = {
            title = "Supprimer une branche",
            prompt = "Sélectionnez la branche à supprimer :",
            confirm = "Supprimer la branche '%s' ? Cette action est irréversible !",
            success = "Branche '%s' supprimée avec succès",
            error = "Erreur lors de la suppression de la branche : %s",
            current = "Impossible de supprimer la branche courante"
        },
        checkout = {
            title = "Changer de branche",
            prompt = "Sélectionnez la branche :",
            success = "Changement vers la branche '%s' effectué",
            error = "Erreur lors du changement de branche : %s"
        }
    },

    -- Gestion des tags
    tag = {
        title = "🏷️ Gestion des Tags",
        none = "Aucun tag trouvé",
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
            prompt = "Entrez le terme de recherche :"
        }
    }
}
