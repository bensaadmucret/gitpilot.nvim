return {
    -- Messages généraux
    ["error.invalid_menu"] = "Menu invalide",
    ["error.invalid_menu_handler"] = "Gestionnaire de menu invalide pour '%{menu}'",
    ["error.invalid_action_handler"] = "Gestionnaire d'action invalide pour '%{action}'",
    ["error.no_git_repo"] = "Aucun dépôt git trouvé",
    ["error.no_changes"] = "Aucune modification à commiter",
    ["error.command_failed"] = "La commande a échoué : %{error}",
    ["error.branch_not_found"] = "Branche '%{name}' non trouvée",
    ["error.branch_exists"] = "La branche '%{name}' existe déjà",
    ["error.cannot_delete_current"] = "Impossible de supprimer la branche courante",
    ["error.merge_conflict"] = "Conflit de fusion détecté",
    ["error.stash_failed"] = "Échec de la mise en cache des modifications",
    ["error.no_stash"] = "Aucune modification en cache",
    ["error.tag_exists"] = "Le tag '%{name}' existe déjà",
    ["error.remote_exists"] = "Le dépôt distant '%{name}' existe déjà",
    ["welcome"] = "Bienvenue dans GitPilot !",
    ["select_action"] = "Sélectionnez une action :",
    ["error"] = "Erreur",
    ["success"] = "Succès",
    ["warning"] = "Avertissement",
    ["cancel"] = "Annuler",

    -- Messages d'information
    ["info.branch_created"] = "La branche '%{name}' a été créée",

    -- Messages de succès
    ["success.branch_created"] = "Branche créée avec succès",
    ["success.branch_deleted"] = "Branche supprimée avec succès",
    ["success.branch_checkout"] = "Basculé sur la branche '%{name}'",
    ["success.branch_merged"] = "Branche fusionnée avec succès",
    ["success.changes_pushed"] = "Modifications poussées avec succès",
    ["success.changes_pulled"] = "Modifications tirées avec succès",
    ["success.changes_stashed"] = "Modifications mises en cache",
    ["success.commit_created"] = "Commit créé avec succès",
    ["success.commit_amended"] = "Commit modifié avec succès",
    ["success.stash_applied"] = "Cache appliqué avec succès",
    ["success.stash_dropped"] = "Cache supprimé avec succès",
    ["success.tag_created"] = "Tag créé avec succès",
    ["success.tag_deleted"] = "Tag supprimé avec succès",
    ["success.remote_added"] = "Dépôt distant ajouté avec succès",
    ["success.remote_removed"] = "Dépôt distant supprimé avec succès",

    -- Interface utilisateur
    ["ui.loading"] = "Chargement...",
    ["ui.press_enter"] = "Appuyez sur Entrée pour continuer",
    ["ui.press_q"] = "Appuyez sur 'q' pour quitter",
    ["ui.select_prompt"] = "Sélectionnez une option :",
    ["ui.input_prompt"] = "Entrez une valeur :",
    ["ui.no_items"] = "Aucun élément trouvé",
    ["ui.select_not_available"] = "Sélection non disponible",

    -- Menu principal
    ["menu.main_title"] = "GitPilot - Menu Principal",
    ["menu.branches_title"] = "GitPilot - Gestion des Branches",
    ["menu.commits_title"] = "GitPilot - Gestion des Commits",
    ["menu.remotes_title"] = "GitPilot - Gestion des Dépôts Distants",
    ["menu.tags_title"] = "GitPilot - Gestion des Tags",
    ["menu.stash_title"] = "GitPilot - Gestion du Cache",
    ["menu.search_title"] = "GitPilot - Recherche",
    ["menu.rebase_title"] = "GitPilot - Rebase",
    ["menu.back"] = "Retour",
    ["menu.quit"] = "Quitter",
    ["menu.main"] = "Menu Principal",
    ["menu.branches"] = "Gestion des branches",
    ["menu.commits"] = "Gestion des commits",
    ["menu.remotes"] = "Gestion des dépôts distants",
    ["menu.tags"] = "Gestion des tags",
    ["menu.stash"] = "Gestion du cache",
    ["menu.search"] = "Rechercher",
    ["menu.rebase"] = "Rebase",

    -- Confirmations
    ["confirm.prompt"] = "Êtes-vous sûr ?",
    ["confirm.cancel"] = "Annuler",
    ["confirm.title"] = "Confirmation requise",
    ["confirm.yes"] = "Oui",
    ["confirm.no"] = "Non",

    -- Actions de branche
    ["branch.create_new"] = "Créer une nouvelle branche",
    ["branch.delete"] = "Supprimer une branche",
    ["branch.checkout"] = "Changer de branche",
    ["branch.merge"] = "Fusionner une branche",
    ["branch.push"] = "Pousser la branche",
    ["branch.pull"] = "Tirer la branche",
    ["branch.rebase"] = "Rebase de la branche",
    ["branch.refresh"] = "Rafraîchir",
    ["branch.enter_name"] = "Nom de la branche :",
    ["branch.select_branch"] = "Sélectionnez une branche :",
    ["branch.select_action"] = "Sélectionnez une action :",
    ["branch.select_checkout"] = "Sélectionnez une branche à extraire :",
    ["branch.select_merge"] = "Sélectionnez une branche à fusionner :",
    ["branch.select_delete"] = "Sélectionnez une branche à supprimer :",
    ["branch.select_rebase"] = "Sélectionnez une branche pour le rebase :",
    ["branch.confirm_delete"] = "Voulez-vous supprimer la branche '%{name}' ?",
    ["branch.confirm_force_delete"] = "La branche '%{name}' n'est pas entièrement fusionnée. Forcer la suppression ?",
    ["branch.confirm_merge"] = "Voulez-vous fusionner la branche '%{name}' ?",
    ["branch.confirm_rebase"] = "Voulez-vous faire un rebase sur la branche '%{name}' ?",
    ["branch.confirm_push"] = "Voulez-vous pousser la branche '%{name}' ?",

    -- Actions de commit
    ["commit.message.prompt"] = "Message du commit :",
    ["commit.enter_message"] = "Entrez le message du commit :",
    ["commit.amend_message"] = "Modifiez le message du commit :",
    ["commit.select_revert"] = "Sélectionnez le commit à annuler :",
    ["commit.select_cherry_pick"] = "Sélectionnez le commit à cherry-pick :",
    ["commit.select_fixup"] = "Sélectionnez le commit à corriger :",
    ["commit.confirm_revert"] = "Voulez-vous annuler ce commit ?",
    ["commit.confirm_amend"] = "Voulez-vous modifier ce commit ?",
    ["commit.confirm_cherry_pick"] = "Voulez-vous cherry-pick ce commit ?",
    ["commit.show"] = "Afficher le commit",
    ["commit.revert"] = "Annuler le commit",
    ["commit.cherry_pick"] = "Cherry-pick le commit",
    ["commit.fixup"] = "Corriger le commit",
    ["commit.create"] = "Créer un commit",
    ["commit.amend"] = "Modifier le dernier commit",

    -- Actions de tag
    ["tag.create"] = "Créer un tag",
    ["tag.delete"] = "Supprimer un tag",
    ["tag.show"] = "Afficher un tag",
    ["tag.push"] = "Pousser un tag",
    ["tag.enter_name"] = "Nom du tag :",
    ["tag.enter_message"] = "Message du tag :",
    ["tag.select_show"] = "Sélectionnez un tag à afficher :",
    ["tag.select_delete"] = "Sélectionnez un tag à supprimer :",
    ["tag.confirm_delete"] = "Voulez-vous supprimer le tag '%{name}' ?",
    ["tag.confirm_push"] = "Voulez-vous pousser le tag '%{name}' ?",

    -- Actions de cache (stash)
    ["stash.save"] = "Sauvegarder les modifications",
    ["stash.pop"] = "Récupérer et supprimer le cache",
    ["stash.apply"] = "Appliquer le cache",
    ["stash.drop"] = "Supprimer le cache",
    ["stash.show"] = "Afficher le cache",
    ["stash.clear"] = "Vider tout le cache",
    ["stash.enter_message"] = "Message pour le cache :",
    ["stash.select_show"] = "Sélectionnez un cache à afficher :",
    ["stash.select_apply"] = "Sélectionnez un cache à appliquer :",
    ["stash.select_drop"] = "Sélectionnez un cache à supprimer :",
    ["stash.confirm_drop"] = "Voulez-vous supprimer ce cache ?",
    ["stash.confirm_pop"] = "Voulez-vous récupérer et supprimer ce cache ?",
    ["stash.confirm_clear"] = "Voulez-vous vider tout le cache ?",

    -- Actions de rebase
    ["rebase.start"] = "Démarrer le rebase",
    ["rebase.continue"] = "Continuer le rebase",
    ["rebase.skip"] = "Ignorer le commit",
    ["rebase.abort"] = "Annuler le rebase",
    ["rebase.interactive"] = "Rebase interactif",
    ["rebase.select_branch"] = "Sélectionnez la branche de base :",
    ["rebase.select_commit"] = "Sélectionnez le commit de départ :",
    ["rebase.confirm_start"] = "Voulez-vous démarrer le rebase ?",
    ["rebase.confirm_skip"] = "Voulez-vous ignorer ce commit ?",
    ["rebase.confirm_abort"] = "Voulez-vous annuler le rebase ?",

    -- Actions de dépôt distant
    ["remote.fetch"] = "Récupérer les modifications",
    ["remote.prune"] = "Nettoyer les références",
    ["remote.enter_name"] = "Nom du dépôt distant :",
    ["remote.enter_url"] = "URL du dépôt distant :",
    ["remote.select_fetch"] = "Sélectionnez un dépôt distant pour récupérer :",
    ["remote.select_push"] = "Sélectionnez un dépôt distant pour pousser :",
    ["remote.select_pull"] = "Sélectionnez un dépôt distant pour tirer :",
    ["remote.select_remove"] = "Sélectionnez un dépôt distant à supprimer :",
    ["remote.confirm_remove"] = "Voulez-vous supprimer ce dépôt distant ?",
    ["remote.confirm_prune"] = "Voulez-vous nettoyer les références ?",

    -- Recherche
    ["search.commits"] = "Rechercher dans les commits",
    ["search.files"] = "Rechercher des fichiers",
    ["search.branches"] = "Rechercher des branches",
    ["search.tags"] = "Rechercher des tags",
    ["search.select_result"] = "Sélectionnez un résultat :",
    ["search.enter_term"] = "Entrez le terme de recherche :",
    ["search.enter_file"] = "Entrez le nom du fichier :",
    ["search.enter_author"] = "Entrez le nom de l'auteur :",
    ["search.title"] = "Recherche",
    ["search.prompt"] = "Entrez votre recherche :",
    ["search.no_results"] = "Aucun résultat trouvé",
    ["search.commits.title"] = "Rechercher dans les commits",
    ["search.commits.prompt"] = "Entrez le terme de recherche :",
    ["search.commits.empty"] = "Le terme de recherche ne peut pas être vide",
    ["search.commits.none"] = "Aucun commit trouvé",
    ["search.commits.no_results"] = "Aucun résultat trouvé pour cette recherche",
    ["search.commits.details_error"] = "Erreur lors de la récupération des détails du commit",
    ["search.commits.details_title"] = "Détails du commit %s",
    ["search.commits.details"] = "Détails",
    ["search.files.prompt"] = "Entrez le motif de recherche :",
    ["search.files.none"] = "Aucun fichier trouvé",
    ["search.files.results"] = "Résultats de la recherche",
    ["search.author.prompt"] = "Entrez le nom de l'auteur :",
    ["search.author.none"] = "Aucun commit trouvé pour cet auteur",
    ["search.author.results"] = "Commits par %s",
    ["search.branches.prompt"] = "Entrez le motif de recherche :",
    ["search.branches.none"] = "Aucune branche trouvée",
    ["search.branches.results"] = "Branches trouvées",
    ["search.branches.switched"] = "Basculé sur la branche",

    -- Message de test
    ["test.message_only_in_english"] = "Message de test",

    -- Titres des menus
    ["menu.branches_title"] = "GitPilot - Gestion des Branches",
    ["menu.commits_title"] = "GitPilot - Gestion des Commits",
    ["menu.remotes_title"] = "GitPilot - Gestion des Dépôts Distants",
    ["menu.tags_title"] = "GitPilot - Gestion des Tags",
    ["menu.stash_title"] = "GitPilot - Gestion du Cache",
    ["menu.rebase_title"] = "GitPilot - Rebase",
    ["menu.search_title"] = "GitPilot - Recherche",

    -- Titres des sections
    ["branch.title"] = "Gestion des branches",
    ["commit.title"] = "Gestion des commits",
    ["tag.title"] = "Gestion des tags",
    ["stash.title"] = "Gestion du cache",
    ["remote.title"] = "Gestion des dépôts distants",

    -- Gestion des branches
    ["branch.current"] = "Branche actuelle : %s",
    ["branch.none"] = "Aucune branche trouvée",
    ["branch.create.title"] = "Créer une nouvelle branche",
    ["branch.create.prompt"] = "Nom de la nouvelle branche :",
    ["branch.create.success"] = "Branche créée avec succès",
    ["branch.create.error"] = "Erreur lors de la création de la branche",
    ["branch.create.exists"] = "La branche existe déjà",
    ["branch.delete.title"] = "Supprimer une branche",
    ["branch.delete.prompt"] = "Sélectionnez la branche à supprimer :",
    ["branch.delete.confirm"] = "Voulez-vous vraiment supprimer cette branche ?",
    ["branch.delete.success"] = "Branche supprimée avec succès",
    ["branch.delete.error"] = "Erreur lors de la suppression de la branche",
    ["branch.delete.current"] = "Impossible de supprimer la branche courante",
    ["branch.switch.title"] = "Changer de branche",
    ["branch.switch.prompt"] = "Sélectionnez une branche :",
    ["branch.switch.success"] = "Changement de branche réussi",
    ["branch.switch.error"] = "Erreur lors du changement de branche",
    ["branch.merge.title"] = "Fusionner une branche",
    ["branch.merge.prompt"] = "Sélectionnez la branche à fusionner :",
    ["branch.merge.success"] = "Fusion réussie",
    ["branch.merge.error"] = "Erreur lors de la fusion",

    -- Gestion des commits
    ["commit.files.none"] = "Aucun fichier à commiter",
    ["commit.files.select"] = "Sélectionnez les fichiers à commiter :",
    ["commit.message.empty"] = "Le message ne peut pas être vide",
    ["commit.type.select"] = "Sélectionnez le type de commit :",
    ["commit.type.feat"] = "Nouvelle fonctionnalité",
    ["commit.type.fix"] = "Correction de bug",
    ["commit.type.docs"] = "Documentation",
    ["commit.type.style"] = "Style de code",
    ["commit.type.refactor"] = "Refactoring",
    ["commit.type.test"] = "Tests",
    ["commit.type.chore"] = "Maintenance",
    ["commit.action.success"] = "Commit créé avec succès",
    ["commit.action.error"] = "Erreur lors de la création du commit",
    ["commit.action.amend_success"] = "Commit modifié avec succès",
    ["commit.action.amend_error"] = "Erreur lors de la modification du commit",

    -- Gestion des tags
    ["tag.none"] = "Aucun tag trouvé",
    ["tag.message"] = "Message",
    ["tag.commit_info"] = "Informations du commit",
    ["tag.details_title"] = "Détails du tag",
    ["tag.create.title"] = "Créer un tag",
    ["tag.create.name_prompt"] = "Nom du tag :",
    ["tag.create.message_prompt"] = "Message du tag :",
    ["tag.create.success"] = "Tag créé avec succès",
    ["tag.create.error"] = "Erreur lors de la création du tag",
    ["tag.create.exists"] = "Le tag existe déjà",
    ["tag.delete.title"] = "Supprimer un tag",
    ["tag.delete.prompt"] = "Sélectionnez le tag à supprimer :",
    ["tag.delete.confirm"] = "Voulez-vous supprimer ce tag ?",
    ["tag.delete.success"] = "Tag supprimé avec succès",
    ["tag.delete.error"] = "Erreur lors de la suppression du tag",
    ["tag.push.title"] = "Pousser les tags",
    ["tag.push.prompt"] = "Sélectionnez les tags à pousser :",
    ["tag.push.confirm"] = "Voulez-vous pousser ces tags ?",
    ["tag.push.success"] = "Tags poussés avec succès",
    ["tag.push.error"] = "Erreur lors de la poussée des tags",

    -- Gestion du cache (stash)
    ["stash.none"] = "Aucune modification en cache",
    ["stash.create.title"] = "Créer un cache",
    ["stash.create.message_prompt"] = "Message pour le cache :",
    ["stash.create.success"] = "Cache créé avec succès",
    ["stash.create.error"] = "Erreur lors de la création du cache",
    ["stash.create.no_changes"] = "Aucune modification à mettre en cache",
    ["stash.apply.title"] = "Appliquer un cache",
    ["stash.apply.prompt"] = "Sélectionnez le cache à appliquer :",
    ["stash.apply.success"] = "Cache appliqué avec succès",
    ["stash.apply.error"] = "Erreur lors de l'application du cache",
    ["stash.delete.title"] = "Supprimer un cache",
    ["stash.delete.prompt"] = "Sélectionnez le cache à supprimer :",
    ["stash.delete.confirm"] = "Voulez-vous supprimer ce cache ?",
    ["stash.delete.success"] = "Cache supprimé avec succès",
    ["stash.delete.error"] = "Erreur lors de la suppression du cache",

    -- Gestion des dépôts distants
    ["remote.none"] = "Aucun dépôt distant trouvé",
    ["remote.add"] = "Ajouter un dépôt distant",
    ["remote.remove"] = "Supprimer un dépôt distant",
    ["remote.push"] = "Pousser les modifications",
    ["remote.pull"] = "Tirer les modifications",
    ["remote.url"] = "URL",
    ["remote.tracking_info"] = "Informations de suivi",
    ["remote.details_title"] = "Détails du dépôt distant",
    ["remote.push.normal"] = "Normal (par défaut)",
    ["remote.push.force"] = "Force (--force)",
    ["remote.push.force_lease"] = "Force avec bail (--force-with-lease)",
    ["remote.action.success"] = "Opération distante effectuée avec succès",
    ["remote.action.error"] = "Erreur lors de l'opération distante",
    ["remote.added"] = "Dépôt distant ajouté avec succès",
    ["remote.deleted"] = "Dépôt distant supprimé",
    ["remote.fetched"] = "Dépôt distant mis à jour",
    ["remote.url.prompt"] = "URL du dépôt distant :",
    ["remote.name.prompt"] = "Nom du dépôt distant :"
}
