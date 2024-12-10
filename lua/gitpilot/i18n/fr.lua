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
    ["info.current_branch"] = "Branche courante : %{name}",
    ["info.branch_switched"] = "Basculé sur la branche '%{name}'",

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

    -- Messages d'erreur spécifiques aux branches
    ["branch.error.delete_current"] = "Impossible de supprimer la branche actuelle. Veuillez d'abord basculer sur une autre branche.",
    ["branch.title"] = "Gestion des branches",
    ["branch.current"] = "Branche actuelle : %s",
    ["branch.none"] = "Aucune branche trouvée",
    ["branch.create.title"] = "Créer une branche",
    ["branch.create.prompt"] = "Nom de la nouvelle branche :",
    ["branch.create.success"] = "Branche '%s' créée avec succès",
    ["branch.create.error"] = "Erreur lors de la création de la branche : %s",
    ["branch.create.exists"] = "La branche '%s' existe déjà",
    ["branch.delete.title"] = "Supprimer une branche",
    ["branch.delete.prompt"] = "Sélectionnez la branche à supprimer :",
    ["branch.delete.confirm"] = "Supprimer la branche '%s' ? Cette action ne peut pas être annulée !",
    ["branch.delete.success"] = "Branche '%s' supprimée avec succès",
    ["branch.delete.error"] = "Erreur lors de la suppression de la branche : %s",
    ["branch.delete.current"] = "Impossible de supprimer la branche courante",
    ["branch.switch.title"] = "Changer de branche",
    ["branch.switch.prompt"] = "Sélectionnez la branche :",
    ["branch.switch.success"] = "Basculé sur la branche '%s'",
    ["branch.switch.error"] = "Erreur lors du changement de branche : %s",
    ["branch.merge.title"] = "Fusionner une branche",
    ["branch.merge.prompt"] = "Sélectionnez la branche à fusionner :",
    ["branch.merge.success"] = "Branche '%s' fusionnée avec succès",
    ["branch.merge.error"] = "Erreur lors de la fusion de la branche : %s",
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
    ["menu.rebase_title"] = "GitPilot - Rebase",
    ["menu.search_title"] = "GitPilot - Recherche",
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
    ["commit.title"] = "Gestion des commits",
    ["commit.create"] = "Créer un commit",
    ["commit.amend"] = "Modifier le dernier commit",
    ["commit.files.none"] = "Aucun fichier à commiter",
    ["commit.files.select"] = "Sélectionnez les fichiers à commiter :",
    ["commit.type.select"] = "Sélectionnez le type de commit :",
    ["commit.type.feat"] = "Nouvelle fonctionnalité",
    ["commit.type.fix"] = "Correction de bug",
    ["commit.type.docs"] = "Documentation",
    ["commit.type.style"] = "Style de code",
    ["commit.type.refactor"] = "Refactoring de code",
    ["commit.type.test"] = "Tests",
    ["commit.type.chore"] = "Maintenance",
    ["commit.message.prompt"] = "Message du commit :",
    ["commit.message.empty"] = "Le message du commit ne peut pas être vide",
    ["commit.action.success"] = "Commit créé avec succès",
    ["commit.action.error"] = "Erreur lors de la création du commit",
    ["commit.action.amend_success"] = "Commit modifié avec succès",
    ["commit.action.amend_error"] = "Erreur lors de la modification du commit",

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

    -- Search operations
    ["search.title"] = " Recherche",
    ["search.menu.title"] = "Opérations de recherche",
    ["search.menu.description"] = "Rechercher dans le dépôt",
    ["search.prompt"] = "Entrez votre recherche :",
    ["search.no_results"] = "Aucun résultat trouvé",
    
    -- Commit search
    ["search.commits"] = "Rechercher dans les commits",
    ["search.commits.title"] = "Recherche dans les Commits",
    ["search.commits.description"] = "Rechercher des commits spécifiques",
    ["search.commits.prompt"] = "Entrez le terme de recherche :",
    ["search.commits.query"] = "Entrez votre recherche :",
    ["search.commits.empty"] = "Le terme de recherche ne peut pas être vide",
    ["search.commits.none"] = "Aucun commit trouvé",
    ["search.commits.no_results"] = "Aucun résultat trouvé pour cette recherche",
    ["search.commits.results"] = "%{count} commits trouvés :",
    ["search.commits.details"] = "Détails",
    ["search.commits.details_title"] = "Détails du commit %s",
    ["search.commits.details_error"] = "Erreur lors de la récupération des détails du commit",
    
    -- File search
    ["search.files"] = "Rechercher dans les fichiers",
    ["search.files.title"] = "Recherche dans les Fichiers",
    ["search.files.description"] = "Rechercher du contenu dans les fichiers",
    ["search.files.query"] = "Entrez le motif de recherche :",
    ["search.files.no_results"] = "Aucun fichier ne correspond à votre recherche",
    ["search.files.results"] = "%{count} fichiers trouvés :",
    
    -- Search errors
    ["search.error.invalid_query"] = "Requête de recherche invalide",
    ["search.error.search_failed"] = "Échec de la recherche : %{error}",
    
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
    ["branch.create.success"] = "Branche '%s' créée avec succès",
    ["branch.create.error"] = "Erreur lors de la création de la branche : %s",
    ["branch.create.exists"] = "La branche '%s' existe déjà",
    ["branch.delete.title"] = "Supprimer une branche",
    ["branch.delete.prompt"] = "Sélectionnez la branche à supprimer :",
    ["branch.delete.confirm"] = "Supprimer la branche '%s' ? Cette action ne peut pas être annulée !",
    ["branch.delete.success"] = "Branche '%s' supprimée avec succès",
    ["branch.delete.error"] = "Erreur lors de la suppression de la branche : %s",
    ["branch.delete.current"] = "Impossible de supprimer la branche courante",
    ["branch.switch.title"] = "Changer de branche",
    ["branch.switch.prompt"] = "Sélectionnez la branche :",
    ["branch.switch.success"] = "Basculé sur la branche '%s'",
    ["branch.switch.error"] = "Erreur lors du changement de branche : %s",
    ["branch.merge.title"] = "Fusionner une branche",
    ["branch.merge.prompt"] = "Sélectionnez la branche à fusionner :",
    ["branch.merge.success"] = "Branche '%s' fusionnée avec succès",
    ["branch.merge.error"] = "Erreur lors de la fusion de la branche : %s",

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
    ["remote.name.prompt"] = "Nom du dépôt distant :",

    -- Messages de backup
    ["backup.title"] = "Gestion des sauvegardes",
    ["backup.create"] = "Créer une sauvegarde",
    ["backup.restore"] = "Restaurer une sauvegarde",
    ["backup.list"] = "Liste des sauvegardes",
    ["backup.export"] = "Exporter en patch",
    ["backup.import"] = "Importer un patch",
    ["backup.mirror"] = "Configurer un mirror",
    ["backup.sync"] = "Synchroniser le mirror",
    ["backup.delete"] = "Supprimer une sauvegarde",
    
    -- Messages de succès pour les backups
    ["backup.success.created"] = "Sauvegarde '%{name}' créée avec succès",
    ["backup.success.restored"] = "Sauvegarde restaurée dans la branche '%{name}'",
    ["backup.success.deleted"] = "Sauvegarde supprimée avec succès",
    ["backup.success.patch_exported"] = "Patch exporté avec succès dans '%{path}'",
    ["backup.success.patch_imported"] = "Patch importé avec succès",
    ["backup.success.mirror_configured"] = "Mirror configuré avec succès",
    ["backup.success.mirror_synced"] = "Mirror synchronisé avec succès",
    
    -- Messages d'erreur pour les backups
    ["backup.error.repo_name"] = "Impossible de déterminer le nom du dépôt",
    ["backup.error.create_failed"] = "Erreur lors de la création de la sauvegarde : %{error}",
    ["backup.error.restore_failed"] = "Erreur lors de la restauration de la sauvegarde : %{error}",
    ["backup.error.invalid_bundle"] = "Bundle invalide : %{error}",
    ["backup.error.delete_failed"] = "Erreur lors de la suppression de la sauvegarde : %{error}",
    ["backup.error.patch_export_failed"] = "Erreur lors de l'export du patch : %{error}",
    ["backup.error.patch_import_failed"] = "Erreur lors de l'import du patch : %{error}",
    ["backup.error.mirror_setup_failed"] = "Erreur lors de la configuration du mirror : %{error}",
    ["backup.error.mirror_config_failed"] = "Erreur lors de la configuration du mirror : %{error}",
    ["backup.error.mirror_sync_failed"] = "Erreur lors de la synchronisation du mirror : %{error}",
    
    -- Messages d'information pour les backups
    ["backup.info.no_backups"] = "Aucune sauvegarde disponible",
    ["backup.info.select_backup"] = "Sélectionnez une sauvegarde :",
    ["backup.info.enter_branch"] = "Entrez le nom de la branche :",
    ["backup.info.enter_path"] = "Entrez le chemin de destination :",
    ["backup.info.enter_mirror"] = "Entrez l'URL du mirror :",
    
    -- Messages de version
    ["version.restore"] = "Restaurer une version",
    ["version.select_commit"] = "Sélectionnez un commit à restaurer :",
    ["version.confirm_restore"] = "Voulez-vous restaurer ce commit dans une nouvelle branche ?",
    ["version.enter_branch_name"] = "Nom de la nouvelle branche :",
    
    -- Messages de succès pour les versions
    ["version.success.restored"] = "Version restaurée dans la branche '%{branch}'",
    
    -- Messages d'erreur pour les versions
    ["version.error.no_commits"] = "Aucun commit trouvé",
    ["version.error.commit_not_found"] = "Commit introuvable",
    ["version.error.restore_failed"] = "Erreur lors de la restauration : %{error}",
    
    -- Messages de planification
    ["schedule.title"] = "Configuration des sauvegardes automatiques",
    ["schedule.configure"] = "Configurer les sauvegardes automatiques",
    ["schedule.toggle"] = "Activer/Désactiver les sauvegardes automatiques",
    ["schedule.on_branch_switch"] = "Sauvegarder lors du changement de branche",
    ["schedule.on_commit"] = "Sauvegarder après chaque commit",
    ["schedule.on_push"] = "Sauvegarder après chaque push",
    ["schedule.on_pull"] = "Sauvegarder après chaque pull",
    ["schedule.daily"] = "Sauvegarde quotidienne",
    ["schedule.weekly"] = "Sauvegarde hebdomadaire",
    ["schedule.configure_retention"] = "Configurer la rétention",
    ["schedule.max_backups"] = "Nombre maximum de sauvegardes à conserver :",
    ["schedule.retain_days"] = "Nombre de jours de conservation :",
    
    -- Messages de succès pour la planification
    ["schedule.enabled"] = "Sauvegardes automatiques activées",
    ["schedule.disabled"] = "Sauvegardes automatiques désactivées",
    ["schedule.config_updated"] = "Configuration des sauvegardes mise à jour",
    
    -- Messages d'erreur pour la planification
    ["schedule.error.invalid_number"] = "Veuillez entrer un nombre valide",
    ["schedule.error.too_small"] = "La valeur doit être supérieure à 0",
    
    -- Messages de mirror
    ["mirror.title"] = "Gestion des mirrors (Réplication de dépôts)",
    ["mirror.add"] = "Ajouter un mirror - Créer une copie synchronisée du dépôt",
    ["mirror.list"] = "Liste des mirrors - Voir et gérer vos copies synchronisées",
    ["mirror.sync_all"] = "Synchroniser tous les mirrors - Mettre à jour toutes les copies",
    ["mirror.configure"] = "Configurer les mirrors - Paramètres de synchronisation",
    ["mirror.enter_name"] = "Donnez un nom court et descriptif à votre mirror (ex: backup_github) :",
    ["mirror.enter_url"] = "Entrez l'URL du dépôt distant (ex: https://github.com/user/repo.git) :",
    ["mirror.no_mirrors"] = "Aucun mirror configuré. Ajoutez-en un pour sécuriser votre code !",
    ["mirror.never_synced"] = "Jamais synchronisé - Cliquez sur 'Synchroniser' pour démarrer",
    ["mirror.select_mirror"] = "Sélectionnez un mirror à gérer :",
    ["mirror.sync"] = "Synchroniser - Mettre à jour maintenant",
    ["mirror.enable"] = "Activer - Permettre la synchronisation",
    ["mirror.disable"] = "Désactiver - Suspendre la synchronisation",
    ["mirror.remove"] = "Supprimer - Retirer ce mirror",
    ["mirror.actions_for"] = "Actions disponibles pour le mirror %s :",
    ["mirror.confirm_remove"] = "Êtes-vous sûr de vouloir supprimer le mirror %s ? Cette action ne supprime pas le dépôt distant.",
    ["mirror.help.what_is"] = "Un mirror est une copie complète et synchronisée de votre dépôt Git. Il peut servir de backup ou de réplique.",
    ["mirror.help.why_use"] = "Les mirrors sont utiles pour :\n- Sauvegarder votre code\n- Distribuer le code sur plusieurs serveurs\n- Accélérer l'accès dans différentes régions",
    ["mirror.help.how_to"] = "Pour commencer :\n1. Ajoutez un mirror avec son URL\n2. Activez la synchronisation automatique\n3. Vérifiez régulièrement l'état des mirrors",
    ["mirror.help.auto_sync"] = "La synchronisation automatique maintient vos mirrors à jour sans intervention manuelle.",
    ["mirror.help.sync_interval"] = "Choisissez un intervalle adapté à votre fréquence de commits :\n- 1 heure : projets très actifs\n- 24 heures : projets moins actifs",

    -- Messages de configuration des mirrors
    ["mirror.config.title"] = "Configuration de la synchronisation des mirrors",
    ["mirror.config.auto_sync"] = "Synchronisation automatique - Maintenir les copies à jour sans intervention",
    ["mirror.config.sync_interval"] = "Intervalle de synchronisation - Fréquence des mises à jour automatiques",
    ["mirror.config.sync_on_push"] = "Synchroniser après un push - Mise à jour immédiate après chaque push",
    ["mirror.config.enable_auto_sync"] = "Voulez-vous activer la synchronisation automatique ? Recommandé pour la sécurité.",
    ["mirror.config.enable_sync_on_push"] = "Synchroniser automatiquement après chaque push ? Recommandé pour la cohérence.",
    ["mirror.config.enter_interval"] = "Intervalle entre les synchronisations (en secondes, ex: 3600 pour 1 heure) :",

    -- Messages de succès pour les mirrors
    ["mirror.success.added"] = "Mirror %{name} ajouté avec succès",
    ["mirror.success.removed"] = "Mirror %{name} supprimé avec succès",
    ["mirror.success.enabled"] = "Mirror %{name} activé",
    ["mirror.success.disabled"] = "Mirror %{name} désactivé",
    ["mirror.success.synced"] = "Mirror %{name} synchronisé avec succès",

    -- Messages d'erreur pour les mirrors
    ["mirror.error.already_exists"] = "Le mirror %{name} existe déjà",
    ["mirror.error.invalid_url"] = "URL de mirror invalide",
    ["mirror.error.add_failed"] = "Erreur lors de l'ajout du mirror : %{error}",
    ["mirror.error.config_failed"] = "Erreur lors de la configuration du mirror",
    ["mirror.error.not_found"] = "Mirror %{name} introuvable",
    ["mirror.error.remove_failed"] = "Erreur lors de la suppression du mirror : %{error}",
    ["mirror.error.disabled"] = "Le mirror %{name} est désactivé",
    ["mirror.error.sync_failed"] = "Erreur lors de la synchronisation de %{name} : %{error}",
    ["mirror.error.invalid_interval"] = "Intervalle invalide",

    -- Patch management
    ["patch.menu.title"] = "Gestion des patches",
    ["patch.menu.description"] = "Créer, appliquer et gérer les patches Git",
    
    ["patch.create.title"] = "Créer un patch",
    ["patch.create.description"] = "Créer un patch à partir des commits sélectionnés",
    ["patch.create.start_commit"] = "Commit de début (vide pour le dernier commit)",
    ["patch.create.end_commit"] = "Commit de fin (vide pour HEAD)",
    ["patch.create.output_dir"] = "Répertoire de sortie (vide pour le répertoire courant)",
    ["patch.create.success"] = "Patch(es) créé(s) avec succès : %{files}",
    ["patch.create.error"] = "Erreur lors de la création du patch : %{error}",
    
    ["patch.apply.title"] = "Appliquer un patch",
    ["patch.apply.description"] = "Appliquer un patch existant au dépôt",
    ["patch.apply.select"] = "Sélectionner un patch à appliquer",
    ["patch.apply.no_patches"] = "Aucun patch trouvé dans le répertoire",
    ["patch.apply.check_failed"] = "Le patch ne peut pas être appliqué : %{error}",
    ["patch.apply.success"] = "Patch appliqué avec succès",
    ["patch.apply.error"] = "Erreur lors de l'application du patch : %{error}",
    
    ["patch.list.title"] = "Liste des patches",
    ["patch.list.description"] = "Voir la liste des patches disponibles",
    ["patch.list.empty"] = "Aucun patch trouvé",
    ["patch.show.error"] = "Erreur lors de l'affichage du patch : %{error}",
    
    -- Historique interactif
    ["history.menu.title"] = "Historique Git",
    ["history.menu.description"] = "Explorer et rechercher dans l'historique Git",
    
    ["history.browse.title"] = "Parcourir l'historique",
    ["history.browse.description"] = "Voir la liste des commits récents",
    
    ["history.search.title"] = "Rechercher dans l'historique",
    ["history.search.description"] = "Rechercher des commits par contenu",
    ["history.search.prompt"] = "Entrez votre terme de recherche :",
    ["history.search.empty"] = "Le terme de recherche ne peut pas être vide",
    ["history.search.no_results"] = "Aucun résultat trouvé",
    ["history.search.results"] = "Résultats de la recherche",
    
    ["history.graph.title"] = "Graphe des branches",
    ["history.graph.description"] = "Visualiser le graphe des branches et commits",
    
    ["history.filter.title"] = "Filtrer l'historique",
    ["history.filter.description"] = "Filtrer les commits par auteur, date ou fichier",
    ["history.filter.by_author"] = "Filtrer par auteur",
    ["history.filter.by_date"] = "Filtrer par date",
    ["history.filter.by_file"] = "Filtrer par fichier",
    ["history.filter.author_prompt"] = "Nom de l'auteur :",
    ["history.filter.date_prompt"] = "Date (YYYY-MM-DD) :",
    ["history.filter.file_prompt"] = "Chemin du fichier :",
    ["history.filter.no_results"] = "Aucun commit trouvé avec ces critères",
    ["history.filter.results"] = "Commits filtrés",
    
    ["history.details.commit"] = "Commit : %{hash}",
    ["history.details.author"] = "Auteur : %{author} <%{email}>",
    ["history.details.date"] = "Date : %{date}",
    ["history.details.subject"] = "Sujet : %{subject}",
    ["history.details.files"] = "Fichiers modifiés :",
    ["history.details.stats"] = "Statistiques :",
    
    ["history.error.fetch"] = "Erreur lors de la récupération de l'historique",
    ["history.error.details"] = "Erreur lors de la récupération des détails du commit",
    ["history.error.search"] = "Erreur lors de la recherche",
    ["history.error.graph"] = "Erreur lors de la génération du graphe",
    
    -- Gestion des Issues
    ["issues.menu.title"] = "Gestion des Issues",
    ["issues.menu.description"] = "Créer et gérer les issues GitHub/GitLab",
    
    ["issues.create.title"] = "Créer une Issue",
    ["issues.create.description"] = "Créer une nouvelle issue",
    ["issues.create.select_template"] = "Sélectionner un template",
    ["issues.create.title_prompt"] = "Titre de l'issue :",
    ["issues.create.title_empty"] = "Le titre ne peut pas être vide",
    ["issues.create.body_prompt"] = "Description de l'issue :",
    ["issues.create.labels_prompt"] = "Labels (séparés par des virgules) :",
    ["issues.create.assignees_prompt"] = "Assignés (séparés par des virgules) :",
    ["issues.create.success"] = "Issue #%{number} créée avec succès",
    ["issues.create.error"] = "Erreur lors de la création de l'issue : %{error}",
    
    ["issues.list.title"] = "Liste des Issues",
    ["issues.list.description"] = "Voir toutes les issues",
    ["issues.list.empty"] = "Aucune issue trouvée",
    ["issues.list.error"] = "Erreur lors de la récupération des issues : %{error}",
    
    ["issues.search.title"] = "Rechercher des Issues",
    ["issues.search.description"] = "Rechercher des issues par critères",
    ["issues.search.by_author"] = "Rechercher par auteur",
    ["issues.search.by_label"] = "Rechercher par label",
    ["issues.search.by_status"] = "Rechercher par statut",
    ["issues.search.author_prompt"] = "Nom de l'auteur :",
    ["issues.search.label_prompt"] = "Label à rechercher :",
    ["issues.search.select_status"] = "Sélectionner un statut",
    ["issues.search.no_results"] = "Aucune issue trouvée",
    ["issues.search.results"] = "Résultats de la recherche",
    
    ["issues.link.title"] = "Lier Commit et Issue",
    ["issues.link.description"] = "Lier un commit à une issue",
    ["issues.link.commit_prompt"] = "Hash du commit :",
    ["issues.link.commit_empty"] = "Le hash du commit ne peut pas être vide",
    ["issues.link.issue_prompt"] = "Numéro de l'issue :",
    ["issues.link.issue_empty"] = "Le numéro de l'issue ne peut pas être vide",
    ["issues.link.success"] = "Commit lié à l'issue avec succès",
    ["issues.link.error"] = "Erreur lors de la liaison : %{error}",
    
    ["issues.details.number"] = "Issue #%{number}",
    ["issues.details.title"] = "Titre : %{title}",
    ["issues.details.status"] = "Statut : %{status}",
    ["issues.details.author"] = "Auteur : %{author}",
    ["issues.details.labels"] = "Labels",
    ["issues.details.assignees"] = "Assignés",
    
    ["issues.status.open"] = "Ouvert",
    ["issues.status.closed"] = "Fermé",
    
    -- Gestion des conflits
    ["conflict.menu.title"] = "Gestion des Conflits",
    ["conflict.menu.description"] = "Résoudre les conflits de fusion",
    
    ["conflict.files.title"] = "Fichiers en Conflit",
    ["conflict.list.title"] = "Liste des Conflits",
    ["conflict.item"] = "Conflit #%{number} (lignes %{start}-%{end_line})",
    
    ["conflict.section.ours"] = "Notre Version (%{ref})",
    ["conflict.section.theirs"] = "Leur Version (%{ref})",
    
    ["conflict.resolve.title"] = "Résoudre le Conflit",
    ["conflict.resolve.use_ours"] = "Utiliser notre version",
    ["conflict.resolve.use_ours_desc"] = "Garder les changements locaux",
    ["conflict.resolve.use_theirs"] = "Utiliser leur version",
    ["conflict.resolve.use_theirs_desc"] = "Accepter les changements distants",
    ["conflict.resolve.manual"] = "Résolution manuelle",
    ["conflict.resolve.manual_desc"] = "Entrer une résolution personnalisée",
    ["conflict.resolve.manual_prompt"] = "Entrez le contenu résolu :",
    ["conflict.resolve.manual_empty"] = "Le contenu ne peut pas être vide",
    ["conflict.resolve.preview_diff"] = "Voir les différences",
    ["conflict.resolve.preview_diff_desc"] = "Comparer les versions côte à côte",
    ["conflict.resolve.use_previous"] = "Utiliser la résolution précédente",
    ["conflict.resolve.use_previous_desc"] = "Appliquer la même résolution que la dernière fois",
    ["conflict.resolve.success"] = "Conflit résolu avec succès",
    ["conflict.resolve.error"] = "Erreur lors de la résolution du conflit",
    
    ["conflict.diff.error"] = "Erreur lors de la comparaison des versions",
    ["conflict.read.error"] = "Erreur lors de la lecture du fichier",
    ["conflict.search.error"] = "Erreur lors de la recherche des conflits",
    ["conflict.none_found"] = "Aucun conflit trouvé",
}
