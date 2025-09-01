return {
    -- Messages généraux
    ["welcome"] = "Bienvenue dans GitPilot !",
    ["select_action"] = "Sélectionnez une action :",
    ["confirm.title"] = "Confirmation requise",
    ["confirm.yes"] = "Oui",
    ["confirm.no"] = "Non",
    ["cancel"] = "Annuler",
    ["success"] = "Succès !",
    ["error"] = "Erreur",
    ["warning"] = "Avertissement",
    ["patch.error.create_directory"] = "Erreur lors de la création du répertoire des modèles",

    -- Messages d'information
    ["info.branch_created"] = "La branche '%{name}' a été créée",
    ["info.current_branch"] = "Branche actuelle : %{name}",
    ["info.branch_switched"] = "Basculé sur la branche '%{name}'",

    -- Messages d'erreur spécifiques aux branches
    ["branch.error.not_git_repo"] = "N'est pas un dépôt Git",
    ["branch.error.invalid_name"] = "Nom de branche invalide",
    ["branch.error.already_exists"] = "La branche '%{name}' existe déjà",
    ["branch.error.not_found"] = "La branche '%{name}' n'existe pas",
    ["branch.error.create_failed"] = "Échec de la création de la branche '%{name}'",
    ["branch.error.checkout_failed"] = "Échec du basculement vers la branche '%{name}'",
    ["branch.error.merge_failed"] = "Échec de la fusion de la branche '%{name}'",
    ["branch.error.delete_failed"] = "Échec de la suppression de la branche '%{name}'",
    ["branch.error.delete_current"] = "Impossible de supprimer la branche courante",
    ["branch.error.invalid_start_point"] = "Le point de départ '%{name}' n'existe pas",
    ["branch.error.no_branches"] = "Aucune branche trouvée",
    ["branch.error.list_failed"] = "Échec de la récupération de la liste des branches",
    ["branch.error.unmerged"] = "La branche '%{name}' n'est pas entièrement fusionnée",
    ["branch.error.uncommitted"] = "Vous avez des modifications non validées",
    ["branch.error.no_upstream"] = "La branche '%{name}' n'a pas de branche amont",

    -- Messages d'avertissement pour les branches
    ["branch.warning.uncommitted_changes"] = "Vous avez des modifications non validées",
    ["branch.warning.merge_conflicts"] = "Des conflits sont survenus lors de la fusion de '%{name}'",
    ["branch.warning.not_fully_merged"] = "La branche '%{name}' n'est pas entièrement fusionnée",
    ["branch.warning.no_tracking"] = "La branche ne suit aucune branche distante",

    -- Messages de succès pour les branches
    ["branch.success.created"] = "Branche '%{name}' créée avec succès",
    ["branch.success.checked_out"] = "Basculé sur la branche '%{name}'",
    ["branch.success.merged"] = "Branche '%{name}' fusionnée avec succès",
    ["branch.success.deleted"] = "Branche '%{name}' supprimée avec succès",

    -- Messages d'interaction pour les branches
    ["branch.select_branch"] = "Sélectionnez une branche :",
    ["branch.prompt.name"] = "Nom de la branche :",
    ["branch.prompt.start_point"] = "Point de départ (optionnel) :",
    ["branch.prompt.delete"] = "Êtes-vous sûr de vouloir supprimer la branche '%{name}' ?",
    ["branch.prompt.force_delete"] = "La branche n'est pas entièrement fusionnée. Forcer la suppression ?",
    ["branch.prompt.merge"] = "Voulez-vous fusionner la branche '%{name}' ?",

    -- Menus principaux
    ["menu.main_title"] = "GitPilot - Menu Principal",
    ["menu.main"] = "Menu Principal",
    ["menu.commits"] = "Opérations sur les Commits",
    ["menu.branches"] = "Opérations sur les Branches",
    ["menu.remotes"] = "Opérations sur les Dépôts Distants",
    ["menu.tags"] = "Opérations sur les Tags",
    ["menu.stash"] = "Opérations sur le Stash",
    ["menu.search"] = "Rechercher",
    ["menu.rebase"] = "Rebase",
    ["menu.backup"] = "Sauvegarde",
    ["menu.back"] = "Retour",
    ["menu.help"] = "Aide",
    ["menu.commits_title"] = "GitPilot - Commits",
    ["menu.branches_title"] = "GitPilot - Branches",
    ["menu.remotes_title"] = "GitPilot - Dépôts Distants",
    ["menu.tags_title"] = "GitPilot - Tags",
    ["menu.stash_title"] = "GitPilot - Stash",
    ["menu.search_title"] = "GitPilot - Recherche",
    ["menu.rebase_title"] = "GitPilot - Rebase",
    ["menu.backup_title"] = "GitPilot - Sauvegarde",

    -- Gestion des commits
    ["commit.title"] = "Gestion des Commits",
    ["commit.create"] = "Créer un commit",
    ["commit.amend"] = "Modifier le dernier commit",
    ["commit.files.none"] = "Aucun fichier à commiter",
    ["commit.files.select"] = "Sélectionnez les fichiers à commiter :",
    ["commit.type.select"] = "Sélectionnez le type de commit :",
    ["commit.type.feat"] = "Nouvelle fonctionnalité",
    ["commit.type.fix"] = "Correction de bug",
    ["commit.type.docs"] = "Documentation",
    ["commit.type.style"] = "Style de code",
    ["commit.type.refactor"] = "Refactorisation de code",
    ["commit.type.test"] = "Tests",
    ["commit.type.chore"] = "Tâches diverses",
    ["commit.message.prompt"] = "Message de commit :",
    ["commit.message.empty"] = "Le message de commit ne peut pas être vide",
    ["commit.action.success"] = "Commit créé avec succès",
    ["commit.action.error"] = "Erreur lors de la création du commit : %s",
    ["commit.action.amend_success"] = "Commit modifié avec succès",
    ["commit.action.amend_error"] = "Erreur lors de la modification du commit : %s",

    -- Messages d'erreur pour les commits
    ["commit.error.not_git_repo"] = "N'est pas un dépôt Git",
    ["commit.error.no_changes"] = "Aucune modification à commiter",
    ["commit.error.create_failed"] = "Échec de la création du commit",
    ["commit.error.no_commits"] = "Aucun commit dans l'historique",
    ["commit.error.amend_failed"] = "Échec de la modification du dernier commit",
    ["commit.error.revert_failed"] = "Échec de l'annulation du commit",
    ["commit.error.cherry_pick_failed"] = "Échec du cherry-pick du commit",
    ["commit.error.invalid_hash"] = "Hash de commit invalide",
    ["commit.error.not_found"] = "Commit non trouvé",
    ["commit.error.push_failed"] = "Échec de l'envoi des modifications",

    -- Messages de succès pour les commits
    ["commit.success.created"] = "Commit créé avec succès",
    ["commit.success.amended"] = "Commit modifié avec succès",
    ["commit.success.reverted"] = "Commit annulé avec succès",
    ["commit.success.cherry_picked"] = "Commit cherry-pické avec succès",
    ["commit.success.pushed"] = "Modifications poussées avec succès",

    -- Messages d'interaction pour les commits
    ["commit.enter_message"] = "Message de commit :",
    ["commit.enter_amend_message"] = "Nouveau message de commit (laisser vide pour garder l'actuel) :",
    ["commit.prompt.select"] = "Sélectionnez un commit :",
    ["commit.prompt.revert"] = "Sélectionnez un commit à annuler :",
    ["commit.prompt.cherry_pick"] = "Sélectionnez un commit à cherry-picker :",
    ["commit.confirm.amend"] = "Voulez-vous modifier le dernier commit ?",
    ["commit.confirm.revert"] = "Voulez-vous annuler ce commit ?",
    ["commit.confirm.cherry_pick"] = "Voulez-vous cherry-picker ce commit ?",

    -- Gestion des branches
    ["branch.title"] = "Gestion des Branches",
    ["branch.current"] = "Branche actuelle : %s",
    ["branch.none"] = "Aucune branche trouvée",
    ["branch.create_new"] = "Créer une nouvelle branche",
    ["branch.enter_name"] = "Nom de la nouvelle branche :",
    ["branch.select_action"] = "Choisissez une action :",
    ["branch.checkout"] = "Basculer sur cette branche",
    ["branch.merge"] = "Fusionner cette branche",
    ["branch.delete"] = "Supprimer cette branche",
    ["branch.push"] = "Pousser cette branche",
    ["branch.pull"] = "Tirer cette branche",
    ["branch.rebase"] = "Rebaser cette branche",
    ["branch.refresh"] = "Rafraîchir les branches",
    ["branch.create.title"] = "Créer une Branche",
    ["branch.create.prompt"] = "Nom de la nouvelle branche :",
    ["branch.create.success"] = "Branche '%s' créée avec succès",
    ["branch.create.error"] = "Erreur lors de la création de la branche : %s",
    ["branch.create.exists"] = "La branche '%s' existe déjà",
    ["branch.delete.title"] = "Supprimer une Branche",
    ["branch.delete.prompt"] = "Sélectionnez la branche à supprimer :",
    ["branch.delete.confirm"] = "Supprimer la branche '%s' ? Cette action est irréversible !",
    ["branch.delete.success"] = "Branche '%s' supprimée avec succès",
    ["branch.delete.error"] = "Erreur lors de la suppression de la branche : %s",
    ["branch.switch.title"] = "Changer de Branche",
    ["branch.switch.prompt"] = "Sélectionnez une branche :",
    ["branch.switch.success"] = "Basculé sur la branche '%s'",
    ["branch.switch.error"] = "Erreur lors du changement de branche : %s",
    ["branch.merge.title"] = "Fusionner une Branche",
    ["branch.merge.prompt"] = "Sélectionnez la branche à fusionner :",
    ["branch.merge.success"] = "Branche '%s' fusionnée avec succès",
    ["branch.merge.error"] = "Erreur lors de la fusion de la branche : %s",

    -- Gestion des dépôts distants
    ["remote.title"] = "Gestion des Dépôts Distants",
    ["remote.add"] = "Ajouter un dépôt distant",
    ["remote.remove"] = "Supprimer un dépôt distant",
    ["remote.push"] = "Pousser les modifications",
    ["remote.pull"] = "Tirer les modifications",
    ["remote.fetch"] = "Récupérer les modifications",
    ["remote.prune"] = "Nettoyer les branches distantes",
    ["remote.none"] = "Aucun dépôt distant trouvé",
    ["remote.name.prompt"] = "Nom du dépôt distant :",
    ["remote.url.prompt"] = "URL du dépôt distant :",
    ["remote.added"] = "Dépôt distant ajouté avec succès",
    ["remote.deleted"] = "Dépôt distant supprimé",
    ["remote.fetched"] = "Dépôt distant mis à jour",
    ["remote.url"] = "URL",
    ["remote.tracking_info"] = "Informations de Suivi",
    ["remote.details_title"] = "Détails du Dépôt Distant",
    ["remote.push.normal"] = "Normal (par défaut)",
    ["remote.push.force"] = "Forcé (--force)",
    ["remote.push.force_lease"] = "Forcé avec lease (--force-with-lease)",
    ["remote.action.success"] = "Opération distante terminée avec succès",
    ["remote.action.error"] = "Erreur lors de l'opération distante : %s",

    -- Messages d'erreur pour les dépôts distants
    ["remote.error.not_git_repo"] = "N'est pas un dépôt Git",
    ["remote.error.list_failed"] = "Échec de la récupération de la liste des dépôts distants",
    ["remote.error.no_remotes"] = "Aucun dépôt distant trouvé",
    ["remote.error.invalid_name"] = "Nom de dépôt distant invalide",
    ["remote.error.invalid_url"] = "URL de dépôt distant invalide",
    ["remote.error.already_exists"] = "Le dépôt distant '%{name}' existe déjà",
    ["remote.error.not_found"] = "Le dépôt distant '%{name}' n'existe pas",
    ["remote.error.add_failed"] = "Échec de l'ajout du dépôt distant",
    ["remote.error.remove_failed"] = "Échec de la suppression du dépôt distant",
    ["remote.error.fetch_failed"] = "Échec de la récupération depuis le dépôt distant",
    ["remote.error.pull_failed"] = "Échec du tirage depuis le dépôt distant",
    ["remote.error.push_failed"] = "Échec de la poussée vers le dépôt distant",
    ["remote.error.prune_failed"] = "Échec du nettoyage du dépôt distant",

    -- Messages d'avertissement pour les dépôts distants
    ["remote.warning.uncommitted_changes"] = "Vous avez des modifications non validées",
    ["remote.warning.no_tracking"] = "La branche actuelle ne suit aucune branche distante",
    ["remote.warning.diverged"] = "La branche locale a divergé de la branche distante",

    -- Messages de succès pour les dépôts distants
    ["remote.success.added"] = "Dépôt distant '%{name}' ajouté avec succès",
    ["remote.success.removed"] = "Dépôt distant '%{name}' supprimé avec succès",
    ["remote.success.fetched"] = "Récupéré avec succès depuis '%{name}'",
    ["remote.success.pulled"] = "Tiré avec succès depuis '%{name}'",
    ["remote.success.pushed"] = "Poussé avec succès vers '%{name}'",
    ["remote.success.pruned"] = "Nettoyé avec succès '%{name}'",

    -- Messages d'interaction pour les dépôts distants
    ["remote.select_remote"] = "Sélectionnez un dépôt distant :",
    ["remote.prompt.name"] = "Nom du dépôt distant :",
    ["remote.prompt.url"] = "URL du dépôt distant :",
    ["remote.prompt.delete"] = "Êtes-vous sûr de vouloir supprimer le dépôt distant '%{name}' ?",
    ["remote.prompt.fetch"] = "Voulez-vous récupérer depuis '%{name}' ?",
    ["remote.prompt.pull"] = "Voulez-vous tirer depuis '%{name}' ?",
    ["remote.prompt.push"] = "Voulez-vous pousser vers '%{name}' ?",
    ["remote.prompt.prune"] = "Voulez-vous nettoyer les branches supprimées de '%{name}' ?",

    -- Gestion des tags
    ["tag.title"] = "Gestion des Tags",
    ["tag.none"] = "Aucun tag trouvé",
    ["tag.message"] = "Message",
    ["tag.commit_info"] = "Informations du Commit",
    ["tag.details_title"] = "Détails du Tag",
    ["tag.create.title"] = "Créer un Tag",
    ["tag.create.name_prompt"] = "Nom du tag :",
    ["tag.create.message_prompt"] = "Message (optionnel) :",
    ["tag.create.success"] = "Tag '%s' créé avec succès",
    ["tag.create.error"] = "Erreur lors de la création du tag : %s",
    ["tag.create.exists"] = "Le tag '%s' existe déjà",
    ["tag.delete.title"] = "Supprimer un Tag",
    ["tag.delete.prompt"] = "Sélectionnez le tag à supprimer :",
    ["tag.delete.confirm"] = "Supprimer le tag '%s' ? Cette action est irréversible !",
    ["tag.delete.success"] = "Tag '%s' supprimé avec succès",
    ["tag.delete.error"] = "Erreur lors de la suppression du tag : %s",
    ["tag.push.title"] = "Pousser les Tags",
    ["tag.push.prompt"] = "Sélectionnez les tags à pousser :",
    ["tag.push.confirm"] = "Pousser les tags sélectionnés ?",
    ["tag.push.success"] = "Tags poussés avec succès",
    ["tag.push.error"] = "Erreur lors de la poussée des tags : %s",

    -- Messages d'erreur pour les tags
    ["tag.error.not_git_repo"] = "N'est pas un dépôt Git",
    ["tag.error.list_failed"] = "Échec de la récupération de la liste des tags",
    ["tag.error.no_tags"] = "Aucun tag trouvé",
    ["tag.error.invalid_name"] = "Nom de tag invalide",
    ["tag.error.already_exists"] = "Le tag '%{name}' existe déjà",
    ["tag.error.create_failed"] = "Échec de la création du tag",
    ["tag.error.not_found"] = "Le tag '%{name}' n'existe pas",
    ["tag.error.delete_failed"] = "Échec de la suppression du tag",
    ["tag.error.push_failed"] = "Échec de la poussée du tag",
    ["tag.error.show_failed"] = "Échec de l'affichage des détails du tag",

    -- Messages de succès pour les tags
    ["tag.success.created"] = "Tag '%{name}' créé avec succès",
    ["tag.success.deleted"] = "Tag '%{name}' supprimé avec succès",
    ["tag.success.pushed"] = "Tag '%{name}' poussé avec succès",

    -- Messages d'interaction pour les tags
    ["tag.select_tag"] = "Sélectionnez un tag :",
    ["tag.prompt.name"] = "Nom du tag :",
    ["tag.prompt.message"] = "Message du tag (optionnel) :",
    ["tag.prompt.delete"] = "Êtes-vous sûr de vouloir supprimer le tag '%{name}' ?",
    ["tag.prompt.push"] = "Voulez-vous pousser le tag '%{name}' vers le dépôt distant ?",

    -- Messages d'aperçu pour les tags
    ["tag.preview.title"] = "Tag : %{name}",
    ["tag.preview.details"] = "Détails du tag",
    ["tag.preview.commit"] = "Commit associé",
    ["tag.preview.author"] = "Auteur",
    ["tag.preview.date"] = "Date",
    ["tag.preview.message"] = "Message",

    -- Gestion du stash
    ["stash.title"] = "Gestion du Stash",
    ["stash.none"] = "Aucun stash trouvé",
    ["stash.create.title"] = "Créer un Stash",
    ["stash.create.message_prompt"] = "Message du stash (optionnel) :",
    ["stash.create.success"] = "Stash créé avec succès",
    ["stash.create.error"] = "Erreur lors de la création du stash : %s",
    ["stash.create.no_changes"] = "Aucune modification à stasher",
    ["stash.apply.title"] = "Appliquer un Stash",
    ["stash.apply.prompt"] = "Sélectionnez le stash à appliquer :",
    ["stash.apply.success"] = "Stash appliqué avec succès",
    ["stash.apply.error"] = "Erreur lors de l'application du stash : %s",
    ["stash.delete.title"] = "Supprimer un Stash",
    ["stash.delete.prompt"] = "Sélectionnez le stash à supprimer :",
    ["stash.delete.confirm"] = "Supprimer le stash sélectionné ? Cette action est irréversible !",
    ["stash.delete.success"] = "Stash supprimé avec succès",
    ["stash.delete.error"] = "Erreur lors de la suppression du stash : %s",

    -- Messages d'erreur pour le stash
    ["stash.error.not_git_repo"] = "N'est pas un dépôt Git",
    ["stash.error.no_changes"] = "Aucune modification à stasher",
    ["stash.error.save_failed"] = "Échec de la sauvegarde du stash",
    ["stash.error.pop_failed"] = "Échec du pop du stash",
    ["stash.error.apply_failed"] = "Échec de l'application du stash",
    ["stash.error.drop_failed"] = "Échec de la suppression du stash",
    ["stash.error.list_failed"] = "Échec de la liste des stashes",
    ["stash.error.no_stashes"] = "Aucun stash trouvé",
    ["stash.error.not_found"] = "Stash non trouvé",
    ["stash.error.show_failed"] = "Échec de l'affichage du stash",

    -- Messages de succès pour le stash
    ["stash.success.saved"] = "Modifications stashées avec succès",
    ["stash.success.popped"] = "Stash poppé avec succès",
    ["stash.success.applied"] = "Stash appliqué avec succès",
    ["stash.success.dropped"] = "Stash supprimé avec succès",
    ["stash.success.cleared"] = "Tous les stashes ont été supprimés avec succès",

    -- Messages d'interaction pour le stash
    ["stash.prompt.message"] = "Message du stash (optionnel) :",
    ["stash.prompt.select"] = "Sélectionnez un stash :",
    ["stash.prompt.pop"] = "Sélectionnez un stash à popper :",
    ["stash.prompt.apply"] = "Sélectionnez un stash à appliquer :",
    ["stash.prompt.drop"] = "Sélectionnez un stash à supprimer :",
    ["stash.confirm.pop"] = "Voulez-vous popper ce stash ?",
    ["stash.confirm.apply"] = "Voulez-vous appliquer ce stash ?",
    ["stash.confirm.drop"] = "Voulez-vous supprimer ce stash ?",
    ["stash.confirm.clear"] = "Voulez-vous supprimer tous les stashes ?",

    -- Opérations de recherche
    ["search.title"] = "Recherche",
    ["search.menu.title"] = "Opérations de Recherche",
    ["search.menu.description"] = "Rechercher dans le dépôt",
    ["search.prompt"] = "Entrez votre recherche :",
    ["search.no_results"] = "Aucun résultat trouvé",
    
    -- Recherche de commits
    ["search.commits"] = "Rechercher des commits",
    ["search.commits.title"] = "Recherche dans les Commits",
    ["search.commits.description"] = "Rechercher des commits spécifiques",
    ["search.commits.prompt"] = "Entrez le terme de recherche :",
    ["search.commits.query"] = "Entrez la requête de recherche :",
    ["search.commits.empty"] = "Le terme de recherche ne peut pas être vide",
    ["search.commits.none"] = "Aucun commit trouvé",
    ["search.commits.no_results"] = "Aucun résultat pour cette recherche",
    ["search.commits.results"] = "%{count} commits trouvés :",
    ["search.commits.details"] = "Détails",
    ["search.commits.details_title"] = "Détails du Commit %s",
    ["search.commits.details_error"] = "Erreur lors de la récupération des détails du commit",
    
    -- Recherche de fichiers
    ["search.files"] = "Rechercher des fichiers",
    ["search.files.title"] = "Recherche dans les Fichiers",
    ["search.files.description"] = "Rechercher du contenu dans les fichiers",
    ["search.files.query"] = "Entrez le motif de recherche :",
    ["search.files.no_results"] = "Aucun fichier correspondant à votre recherche",
    ["search.files.results"] = "%{count} fichiers trouvés :",
    
    -- Erreurs de recherche
    ["search.error.not_git_repo"] = "N'est pas un dépôt Git",
    ["search.error.empty_query"] = "La requête de recherche ne peut pas être vide",
    ["search.error.commits_failed"] = "Échec de la recherche de commits",
    ["search.error.files_failed"] = "Échec de la recherche de fichiers",
    ["search.error.branches_failed"] = "Échec de la recherche de branches",
    ["search.error.tags_failed"] = "Échec de la recherche de tags",
    ["search.error.invalid_query"] = "Requête de recherche invalide",
    ["search.error.search_failed"] = "La recherche a échoué : %{error}",
    
    -- Messages d'information pour la recherche
    ["search.info.no_commits_found"] = "Aucun commit trouvé",
    ["search.info.no_files_found"] = "Aucun fichier trouvé",
    ["search.info.no_branches_found"] = "Aucune branche trouvée",
    ["search.info.no_tags_found"] = "Aucun tag trouvé",
    ["search.info.searching"] = "Recherche en cours...",

    -- Messages de succès pour la recherche
    ["search.success.commits_found"] = "%{count} commits trouvés",
    ["search.success.files_found"] = "%{count} fichiers trouvés",
    ["search.success.branches_found"] = "%{count} branches trouvées",
    ["search.success.tags_found"] = "%{count} tags trouvés",

    -- Messages d'interaction pour la recherche
    ["search.prompt.query"] = "Entrez votre requête de recherche :",
    ["search.prompt.select_commit"] = "Sélectionnez un commit :",
    ["search.prompt.select_file"] = "Sélectionnez un fichier :",
    ["search.prompt.select_branch"] = "Sélectionnez une branche :",
    ["search.prompt.select_tag"] = "Sélectionnez un tag :",

    -- Messages d'aperçu
    ["search.preview.commit_title"] = "Commit %{hash}",
    ["search.preview.file_title"] = "Fichier : %{path}",
    ["search.preview.branch_title"] = "Branche : %{name}",
    ["search.preview.tag_title"] = "Tag : %{name}",
    
    -- Messages de version
    ["version.restore"] = "Restaurer une Version",
    ["version.select_commit"] = "Sélectionnez un commit à restaurer :",
    ["version.confirm_restore"] = "Voulez-vous restaurer ce commit dans une nouvelle branche ?",
    ["version.enter_branch_name"] = "Nom de la nouvelle branche :",

    -- Messages de succès pour la version
    ["version.success.restored"] = "Version restaurée dans la branche '%{branch}'",

    -- Messages d'erreur pour la version
    ["version.error.no_commits"] = "Aucun commit trouvé",
    ["version.error.commit_not_found"] = "Commit non trouvé",
    ["version.error.restore_failed"] = "Échec de la restauration de la version : %{error}",

    -- Messages de sauvegarde
    ["backup.title"] = "Gestion des Sauvegardes",
    ["backup.create"] = "Créer une Sauvegarde",
    ["backup.restore"] = "Restaurer une Sauvegarde",
    ["backup.list"] = "Lister les Sauvegardes",
    ["backup.export"] = "Exporter en Patch",
    ["backup.import"] = "Importer un Patch",
    ["backup.mirror"] = "Configurer un Miroir",
    ["backup.sync"] = "Synchroniser le Miroir",
    ["backup.delete"] = "Supprimer une Sauvegarde",

    -- Messages de succès pour la sauvegarde
    ["backup.success.created"] = "Sauvegarde '%{name}' créée avec succès",
    ["backup.success.restored"] = "Sauvegarde restaurée dans la branche '%{name}'",
    ["backup.success.deleted"] = "Sauvegarde supprimée avec succès",
    ["backup.success.patch_exported"] = "Patch exporté avec succès vers '%{path}'",
    ["backup.success.patch_imported"] = "Patch importé avec succès",
    ["backup.success.mirror_configured"] = "Miroir configuré avec succès",
    ["backup.success.mirror_synced"] = "Miroir synchronisé avec succès",
    
    -- Messages d'erreur pour la sauvegarde
    ["backup.error.repo_name"] = "Impossible de déterminer le nom du dépôt",
    ["backup.error.create_failed"] = "Échec de la création de la sauvegarde : %{error}",
    ["backup.error.restore_failed"] = "Échec de la restauration de la sauvegarde : %{error}",
    ["backup.error.invalid_bundle"] = "Bundle invalide : %{error}",
    ["backup.error.delete_failed"] = "Échec de la suppression de la sauvegarde : %{error}",
    ["backup.error.patch_export_failed"] = "Échec de l'exportation du patch : %{error}",
    ["backup.error.patch_import_failed"] = "Échec de l'importation du patch : %{error}",
    ["backup.error.mirror_setup_failed"] = "Échec de la configuration du miroir : %{error}",
    ["backup.error.mirror_config_failed"] = "Échec de la configuration du miroir : %{error}",
    ["backup.error.mirror_sync_failed"] = "Échec de la synchronisation du miroir : %{error}",
    
    -- Messages d'information pour la sauvegarde
    ["backup.info.no_backups"] = "Aucune sauvegarde disponible",
    ["backup.info.select_backup"] = "Sélectionnez une sauvegarde :",
    ["backup.info.enter_branch"] = "Entrez le nom de la branche :",
    ["backup.info.enter_path"] = "Entrez le chemin de destination :",
    ["backup.info.enter_mirror"] = "Entrez l'URL du miroir :",
    
    -- Messages de l'interface utilisateur
    ["ui.no_items"] = "Aucun élément à sélectionner",
    ["ui.select_not_available"] = "Sélection non disponible",
    ["ui.select_prompt"] = "Sélectionnez une option :",
    ["ui.input_prompt"] = "Entrez une valeur :",
    ["test.message_only_in_english"] = "Message de Test",
    
    -- Messages de planification
    ["schedule.title"] = "Configuration des Sauvegardes Automatiques",
    ["schedule.configure"] = "Configurer les Sauvegardes Automatiques",
    ["schedule.toggle"] = "Activer/Désactiver les Sauvegardes Automatiques",
    ["schedule.on_branch_switch"] = "Sauvegarder lors du Changement de Branche",
    ["schedule.on_commit"] = "Sauvegarder après un Commit",
    ["schedule.on_push"] = "Sauvegarder après un Push",
    ["schedule.on_pull"] = "Sauvegarder après un Pull",
    ["schedule.daily"] = "Sauvegarde Quotidienne",
    ["schedule.weekly"] = "Sauvegarde Hebdomadaire",
    ["schedule.configure_retention"] = "Configurer la Rétention",
    ["schedule.max_backups"] = "Nombre maximum de sauvegardes à conserver :",
    ["schedule.retain_days"] = "Nombre de jours de conservation des sauvegardes :",
    
    -- Messages de succès pour la planification
    ["schedule.enabled"] = "Sauvegardes automatiques activées",
    ["schedule.disabled"] = "Sauvegardes automatiques désactivées",
    ["schedule.config_updated"] = "Configuration des sauvegardes mise à jour",
    
    -- Messages d'erreur pour la planification
    ["schedule.error.invalid_number"] = "Veuillez entrer un nombre valide",
    ["schedule.error.too_small"] = "La valeur doit être supérieure à 0",
    
    -- Messages de miroir
    ["mirror.title"] = "Gestion des Miroirs (Réplication de Dépôt)",
    ["mirror.add"] = "Ajouter un Miroir - Créer une copie synchronisée du dépôt",
    ["mirror.list"] = "Lister les Miroirs - Voir et gérer vos copies synchronisées",
    ["mirror.sync_all"] = "Synchroniser Tous les Miroirs - Mettre à jour toutes les copies",
    ["mirror.configure"] = "Configurer les Miroirs - Paramètres de synchronisation",
    ["mirror.enter_name"] = "Donnez un nom court et descriptif à votre miroir (ex: sauvegarde_github) :",
    ["mirror.enter_url"] = "Entrez l'URL du dépôt distant (ex: https://github.com/user/repo.git) :",
    ["mirror.no_mirrors"] = "Aucun miroir configuré. Ajoutez-en un pour sécuriser votre code !",
    ["mirror.never_synced"] = "Jamais synchronisé - Cliquez sur 'Synchroniser' pour démarrer",
    ["mirror.select_mirror"] = "Sélectionnez un miroir à gérer :",
    ["mirror.sync"] = "Synchroniser - Mettre à jour maintenant",
    ["mirror.enable"] = "Activer - Autoriser la synchronisation",
    ["mirror.disable"] = "Désactiver - Mettre en pause la synchronisation",
    ["mirror.remove"] = "Supprimer - Retirer ce miroir",
    ["mirror.actions_for"] = "Actions disponibles pour le miroir %s :",
    ["mirror.confirm_remove"] = "Êtes-vous sûr de vouloir supprimer le miroir %s ? Cela ne supprimera pas le dépôt distant.",

    -- Messages de configuration de miroir
    ["mirror.config.title"] = "Configuration de la Synchronisation des Miroirs",
    ["mirror.config.auto_sync"] = "Synchronisation Automatique - Garder les copies à jour sans intervention",
    ["mirror.config.sync_interval"] = "Intervalle de Synchronisation - Fréquence des mises à jour automatiques",
    ["mirror.config.sync_on_push"] = "Synchroniser au Push - Mise à jour immédiate après chaque push",
    ["mirror.config.enable_auto_sync"] = "Voulez-vous activer la synchronisation automatique ? Recommandé pour la sécurité.",
    ["mirror.config.enable_sync_on_push"] = "Synchroniser automatiquement après chaque push ? Recommandé pour la cohérence.",
    ["mirror.config.enter_interval"] = "Temps entre les synchronisations (en secondes, ex: 3600 pour 1 heure) :",

    -- Messages d'aide pour le miroir
    ["mirror.help.what_is"] = "Un miroir est une copie complète et synchronisée de votre dépôt Git. Il peut servir de sauvegarde ou de réplique.",
    ["mirror.help.why_use"] = "Les miroirs sont utiles pour :\n- Sauvegarder votre code\n- Distribuer le code sur plusieurs serveurs\n- Accélérer l'accès dans différentes régions",
    ["mirror.help.how_to"] = "Pour commencer :\n1. Ajoutez un miroir avec son URL\n2. Activez la synchronisation automatique\n3. Vérifiez régulièrement l'état du miroir",
    ["mirror.help.auto_sync"] = "La synchronisation automatique garde vos miroirs à jour sans intervention manuelle.",
    ["mirror.help.sync_interval"] = "Choisissez un intervalle adapté à votre fréquence de commits :\n- 1 heure : projets très actifs\n- 24 heures : projets moins actifs",

    -- Messages de succès pour le miroir
    ["mirror.success.added"] = "Miroir %{name} ajouté avec succès",
    ["mirror.success.removed"] = "Miroir %{name} supprimé avec succès",
    ["mirror.success.enabled"] = "Miroir %{name} activé",
    ["mirror.success.disabled"] = "Miroir %{name} désactivé",
    ["mirror.success.synced"] = "Miroir %{name} synchronisé avec succès",

    -- Messages d'erreur pour le miroir
    ["mirror.error.already_exists"] = "Le miroir %{name} existe déjà",
    ["mirror.error.invalid_url"] = "URL de miroir invalide",
    ["mirror.error.add_failed"] = "Échec de l'ajout du miroir : %{error}",
    ["mirror.error.config_failed"] = "Échec de la configuration du miroir",
    ["mirror.error.not_found"] = "Miroir %{name} non trouvé",
    ["mirror.error.remove_failed"] = "Échec de la suppression du miroir : %{error}",
    ["mirror.error.disabled"] = "Le miroir %{name} est désactivé",
    ["mirror.error.sync_failed"] = "Échec de la synchronisation de %{name} : %{error}",
    ["mirror.error.invalid_interval"] = "Intervalle invalide",

    -- Gestion des patchs
    ["patch.menu.title"] = "Gestion des Patches",
    ["patch.menu.description"] = "Créer, appliquer et gérer les patches Git",
    
    ["patch.create.title"] = "Créer un Patch",
    ["patch.create.description"] = "Créer un patch à partir des commits sélectionnés",
    ["patch.create.start_commit"] = "Commit de début (laisser vide pour le dernier commit)",
    ["patch.create.end_commit"] = "Commit de fin (laisser vide pour HEAD)",
    ["patch.create.output_dir"] = "Répertoire de sortie (laisser vide pour le répertoire courant)",
    ["patch.create.success"] = "Patch(s) créé(s) avec succès : %{files}",
    ["patch.create.error"] = "Erreur lors de la création du patch : %{error}",
    
    ["patch.apply.title"] = "Appliquer un Patch",
    ["patch.apply.description"] = "Appliquer un patch existant au dépôt",
    ["patch.apply.select"] = "Sélectionner un patch à appliquer",
    ["patch.apply.no_patches"] = "Aucun patch trouvé dans le répertoire",
    ["patch.apply.check_failed"] = "Le patch ne peut pas être appliqué : %{error}",
    ["patch.apply.success"] = "Patch appliqué avec succès",
    ["patch.apply.error"] = "Erreur lors de l'application du patch : %{error}",
    
    ["patch.list.title"] = "Lister les Patches",
    ["patch.list.description"] = "Voir les patches disponibles",
    ["patch.list.empty"] = "Aucun patch trouvé",
    ["patch.show.error"] = "Erreur lors de l'affichage du patch : %{error}",
    
    -- Historique interactif
    ["history.menu.title"] = "Historique Git",
    ["history.menu.description"] = "Parcourir et rechercher dans l'historique Git",
    
    ["history.browse.title"] = "Parcourir l'Historique",
    ["history.browse.description"] = "Voir la liste des commits récents",
    
    ["history.search.title"] = "Rechercher dans l'Historique",
    ["history.search.description"] = "Rechercher des commits par contenu",
    ["history.search.prompt"] = "Entrez le terme de recherche :",
    ["history.search.empty"] = "Le terme de recherche ne peut pas être vide",
    ["history.search.no_results"] = "Aucun résultat trouvé",
    ["history.search.results"] = "Résultats de la Recherche",
    
    ["history.graph.title"] = "Graphe des Branches",
    ["history.graph.description"] = "Visualiser le graphe des branches et des commits",
    
    ["history.filter.title"] = "Filtrer l'Historique",
    ["history.filter.description"] = "Filtrer les commits par auteur, date ou fichier",
    ["history.filter.by_author"] = "Filtrer par Auteur",
    ["history.filter.by_date"] = "Filtrer par Date",
    ["history.filter.by_file"] = "Filtrer par Fichier",
    ["history.filter.author_prompt"] = "Nom de l'auteur :",
    ["history.filter.date_prompt"] = "Date (AAAA-MM-JJ) :",
    ["history.filter.file_prompt"] = "Chemin du fichier :",
    ["history.filter.no_results"] = "Aucun commit trouvé avec ces critères",
    ["history.filter.results"] = "Commits Filtrés",
    
    ["history.details.commit"] = "Commit : %{hash}",
    ["history.details.author"] = "Auteur : %{author} <%{email}>",
    ["history.details.date"] = "Date : %{date}",
    ["history.details.subject"] = "Sujet : %{subject}",
    ["history.details.files"] = "Fichiers Modifiés :",
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
    ["issues.create.select_template"] = "Sélectionner un Modèle",
    ["issues.create.title_prompt"] = "Titre de l'issue :",
    ["issues.create.title_empty"] = "Le titre ne peut pas être vide",
    ["issues.create.body_prompt"] = "Description de l'issue :",
    ["issues.create.labels_prompt"] = "Étiquettes (séparées par des virgules) :",
    ["issues.create.assignees_prompt"] = "Assignés (séparés par des virgules) :",
    ["issues.create.success"] = "Issue #%{number} créée avec succès",
    ["issues.create.error"] = "Erreur lors de la création de l'issue : %{error}",
    
    ["issues.list.title"] = "Lister les Issues",
    ["issues.list.description"] = "Voir toutes les issues",
    ["issues.list.empty"] = "Aucune issue trouvée",
    ["issues.list.error"] = "Erreur lors de la récupération des issues : %{error}",
    
    ["issues.search.title"] = "Rechercher des Issues",
    ["issues.search.description"] = "Rechercher des issues par critères",
    ["issues.search.by_author"] = "Rechercher par Auteur",
    ["issues.search.by_label"] = "Rechercher par Étiquette",
    ["issues.search.by_status"] = "Rechercher par Statut",
    ["issues.search.author_prompt"] = "Nom de l'auteur :",
    ["issues.search.label_prompt"] = "Étiquette à rechercher :",
    ["issues.search.select_status"] = "Sélectionner un Statut",
    ["issues.search.no_results"] = "Aucune issue trouvée",
    ["issues.search.results"] = "Résultats de la Recherche",
    
    ["issues.link.title"] = "Lier un Commit à une Issue",
    ["issues.link.description"] = "Lier un commit à une issue",
    ["issues.link.commit_prompt"] = "Hash du commit :",
    ["issues.link.commit_empty"] = "Le hash du commit ne peut pas être vide",
    ["issues.link.issue_prompt"] = "Numéro de l'issue :",
    ["issues.link.issue_empty"] = "Le numéro de l'issue ne peut pas être vide",
    ["issues.link.success"] = "Commit lié à l'issue avec succès",
    ["issues.link.error"] = "Erreur lors de la liaison du commit : %{error}",
    
    ["issues.details.number"] = "Issue #%{number}",
    ["issues.details.title"] = "Titre : %{title}",
    ["issues.details.status"] = "Statut : %{status}",
    ["issues.details.author"] = "Auteur : %{author}",
    ["issues.details.labels"] = "Étiquettes",
    ["issues.details.assignees"] = "Assignés",
    
    ["issues.status.open"] = "Ouvert",
    ["issues.status.closed"] = "Fermé",
    
    -- Gestion des Conflits
    ["conflict.menu.title"] = "Gestion des Conflits",
    ["conflict.menu.description"] = "Résoudre les conflits de fusion",
    ["conflict.section.ours"] = "Notre version (%{ref})",
    ["conflict.section.theirs"] = "Leur version (%{ref})",
    ["conflict.resolve.use_ours"] = "Utiliser notre version",
    ["conflict.resolve.use_ours_desc"] = "Garder les changements de notre branche",
    ["conflict.resolve.use_theirs"] = "Utiliser leur version",
    ["conflict.resolve.use_theirs_desc"] = "Garder les changements de leur branche",
    ["conflict.resolve.manual"] = "Résolution manuelle",
    ["conflict.resolve.manual_desc"] = "Ouvrir l'éditeur pour une résolution manuelle",
    ["conflict.resolve.success"] = "Conflit résolu avec succès",
    ["conflict.resolve.error"] = "Erreur lors de la résolution du conflit",
    ["conflict.search.error"] = "Erreur lors de la recherche de conflits",
    ["conflict.no_conflicts"] = "Aucun conflit trouvé",
    ["conflict.select_file"] = "Sélectionnez un fichier avec des conflits :",
    ["conflict.select_conflict"] = "Sélectionnez un conflit à résoudre :",
    
    -- Gestion des conflits
    ["conflict.files.title"] = "Fichiers en Conflit",
    ["conflict.list.title"] = "Liste des Conflits",
    ["conflict.item"] = "Conflit #%{number} (lignes %{start}-%{end_line})",
    ["conflict.resolve.preview_diff"] = "Voir les différences",
    ["conflict.resolve.preview_diff_desc"] = "Comparer les versions côte à côte",
    ["conflict.resolve.use_previous"] = "Utiliser la résolution précédente",
    ["conflict.resolve.use_previous_desc"] = "Appliquer la même résolution que la dernière fois",
    ["conflict.resolve.manual_prompt"] = "Entrez le contenu résolu :",
    ["conflict.resolve.manual_empty"] = "Le contenu ne peut pas être vide",
    ["conflict.diff.error"] = "Erreur lors de la comparaison des versions",
    ["conflict.read.error"] = "Erreur de lecture du fichier",
    
    -- Messages d'erreur pour le rebase
    ["rebase.error.not_git_repo"] = "N'est pas un dépôt Git",
    ["rebase.error.already_rebasing"] = "Un rebase est déjà en cours",
    ["rebase.error.log_failed"] = "Échec de la récupération de l'historique des commits",
    ["rebase.error.no_commits"] = "Aucun commit trouvé pour le rebase",
    ["rebase.error.start_failed"] = "Échec du démarrage du rebase",
    ["rebase.error.continue_failed"] = "Échec de la poursuite du rebase",
    ["rebase.error.abort_failed"] = "Échec de l'abandon du rebase",
    ["rebase.error.skip_failed"] = "Échec du saut du commit actuel",
    ["rebase.error.not_rebasing"] = "Aucun rebase en cours",
    ["rebase.error.conflicts"] = "Les conflits doivent être résolus avant de continuer",

    -- Messages d'avertissement pour le rebase
    ["rebase.warning.uncommitted_changes"] = "Vous avez des modifications non validées",
    ["rebase.warning.no_changes"] = "Aucune modification à appliquer",
    ["rebase.warning.conflicts_pending"] = "Des conflits sont en attente de résolution",

    -- Messages de succès pour le rebase
    ["rebase.success.started"] = "Rebase démarré avec succès",
    ["rebase.success.continued"] = "Rebase poursuivi avec succès",
    ["rebase.success.aborted"] = "Rebase abandonné avec succès",
    ["rebase.success.skipped"] = "Commit sauté avec succès",
    ["rebase.success.completed"] = "Rebase terminé avec succès",

    -- Messages d'interaction pour le rebase
    ["rebase.prompt.select_commit"] = "Sélectionnez un commit pour le rebase :",
    ["rebase.prompt.continue"] = "Continuer le rebase ?",
    ["rebase.prompt.abort"] = "Abandonner le rebase ?",
    ["rebase.prompt.skip"] = "Sauter le commit actuel ?",
    ["rebase.confirm.abort"] = "Êtes-vous sûr de vouloir abandonner le rebase ?",
    ["rebase.confirm.skip"] = "Êtes-vous sûr de vouloir sauter ce commit ?",
    
    -- Éléments de menu pour les branches
    ["branch.pull"] = "Tirer la branche",
    ["branch.rebase"] = "Rebaser la branche",
    ["branch.refresh"] = "Rafraîchir les branches",

    -- Éléments de menu pour les commits
    ["commit.fixup"] = "Fixup un Commit",
    ["commit.revert"] = "Annuler un Commit",
    ["commit.cherry_pick"] = "Cherry-Picker un Commit",
    ["commit.show"] = "Afficher un Commit",

    -- Éléments de menu pour le stash
    ["stash.save"] = "Sauvegarder le Stash",
    ["stash.pop"] = "Popper le Stash",
    ["stash.apply"] = "Appliquer le Stash",
    ["stash.drop"] = "Supprimer le Stash",
    ["stash.show"] = "Afficher le Stash",
    ["stash.clear"] = "Vider Tout le Stash",

    -- Éléments de menu pour les tags
    ["tag.create"] = "Créer un Tag",
    ["tag.delete"] = "Supprimer un Tag",
    ["tag.push"] = "Pousser un Tag",
    ["tag.show"] = "Afficher un Tag",

    -- Éléments de menu pour les dépôts distants
    ["remote.fetch"] = "Récupérer depuis le Dépôt Distant",
    ["remote.pull"] = "Tirer depuis le Dépôt Distant",
    ["remote.push"] = "Pousser vers le Dépôt Distant",
    ["remote.prune"] = "Nettoyer le Dépôt Distant",

    -- Éléments de menu pour le rebase
    ["rebase.start"] = "Démarrer le Rebase",
    ["rebase.continue"] = "Continuer le Rebase",
    ["rebase.skip"] = "Sauter le Rebase",
    ["rebase.abort"] = "Abandonner le Rebase",
    ["rebase.interactive"] = "Rebase Interactif",

    -- Éléments de menu pour la recherche
    ["search.branches"] = "Rechercher des Branches",
    ["search.tags"] = "Rechercher des Tags",

    -- Éléments de menu pour la sauvegarde
    ["backup.restore"] = "Restaurer une Sauvegarde",
    ["backup.delete"] = "Supprimer une Sauvegarde",

    -- Messages d'erreur
    ["error.invalid_menu"] = "Menu sélectionné invalide",
}
