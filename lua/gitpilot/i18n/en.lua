return {
    -- General messages
    ["welcome"] = "Welcome to GitPilot!",
    ["select_action"] = "Select an action:",
    ["confirm.title"] = "Confirmation Required",
    ["confirm.yes"] = "Yes",
    ["confirm.no"] = "No",
    ["cancel"] = "Cancel",
    ["success"] = "Success!",
    ["error"] = "Error",
    ["warning"] = "Warning",
    ["patch.error.create_directory"] = "Error creating template directory",
    
    -- Information messages
    ["info.branch_created"] = "Branch '%{name}' has been created",
    ["info.current_branch"] = "Current branch: %{name}",
    ["info.branch_switched"] = "Switched to branch '%{name}'",
    
    -- Branch specific error messages
    ["branch.error.not_git_repo"] = "Not a Git repository",
    ["branch.error.invalid_name"] = "Invalid branch name",
    ["branch.error.already_exists"] = "Branch '%{name}' already exists",
    ["branch.error.not_found"] = "Branch '%{name}' does not exist",
    ["branch.error.create_failed"] = "Failed to create branch '%{name}'",
    ["branch.error.checkout_failed"] = "Failed to checkout branch '%{name}'",
    ["branch.error.merge_failed"] = "Failed to merge branch '%{name}'",
    ["branch.error.delete_failed"] = "Failed to delete branch '%{name}'",
    ["branch.error.delete_current"] = "Cannot delete the current branch",
    ["branch.error.invalid_start_point"] = "Start point '%{name}' does not exist",
    ["branch.error.no_branches"] = "No branches found",
    ["branch.error.list_failed"] = "Failed to retrieve branch list",
    ["branch.error.unmerged"] = "Branch '%{name}' is not fully merged",
    ["branch.error.uncommitted"] = "You have uncommitted changes",
    ["branch.error.no_upstream"] = "Branch '%{name}' has no upstream branch",
    
    -- Branch warning messages
    ["branch.warning.uncommitted_changes"] = "You have uncommitted changes",
    ["branch.warning.merge_conflicts"] = "Conflicts occurred while merging '%{name}'",
    ["branch.warning.not_fully_merged"] = "Branch '%{name}' is not fully merged",
    ["branch.warning.no_tracking"] = "Branch is not tracking any remote",
    
    -- Branch success messages
    ["branch.success.created"] = "Branch '%{name}' created successfully",
    ["branch.success.checked_out"] = "Switched to branch '%{name}'",
    ["branch.success.merged"] = "Branch '%{name}' merged successfully",
    ["branch.success.deleted"] = "Branch '%{name}' deleted successfully",
    
    -- Branch interaction messages
    ["branch.select_branch"] = "Select a branch:",
    ["branch.prompt.name"] = "Branch name:",
    ["branch.prompt.start_point"] = "Start point (optional):",
    ["branch.prompt.delete"] = "Are you sure you want to delete branch '%{name}'?",
    ["branch.prompt.force_delete"] = "Branch is not fully merged. Force delete?",
    ["branch.prompt.merge"] = "Do you want to merge branch '%{name}'?",
    
    -- Main menus
    ["menu.main_title"] = "GitPilot - Main Menu",
    ["menu.main"] = "Main Menu",
    ["menu.commits"] = "Commit Operations",
    ["menu.branches"] = "Branch Operations",
    ["menu.remotes"] = "Remote Operations",
    ["menu.tags"] = "Tag Operations",
    ["menu.stash"] = "Stash Operations",
    ["menu.search"] = "Search",
    ["menu.rebase"] = "Rebase",
    ["menu.backup"] = "Backup",
    ["menu.back"] = "Back",
    ["menu.commits_title"] = "GitPilot - Commits",
    ["menu.branches_title"] = "GitPilot - Branches",
    ["menu.remotes_title"] = "GitPilot - Remotes",
    ["menu.tags_title"] = "GitPilot - Tags",
    ["menu.stash_title"] = "GitPilot - Stash",
    ["menu.search_title"] = "GitPilot - Search",
    ["menu.rebase_title"] = "GitPilot - Rebase",
    ["menu.backup_title"] = "GitPilot - Backup",
    
    -- Commit management
    ["commit.title"] = " Commit Management",
    ["commit.create"] = "Create commit",
    ["commit.amend"] = "Amend last commit",
    ["commit.files.none"] = "No files to commit",
    ["commit.files.select"] = "Select files to commit:",
    ["commit.type.select"] = "Select commit type:",
    ["commit.type.feat"] = "New feature",
    ["commit.type.fix"] = "Bug fix",
    ["commit.type.docs"] = "Documentation",
    ["commit.type.style"] = "Code style",
    ["commit.type.refactor"] = "Code refactoring",
    ["commit.type.test"] = "Tests",
    ["commit.type.chore"] = "Maintenance",
    ["commit.message.prompt"] = "Commit message:",
    ["commit.message.empty"] = "Commit message cannot be empty",
    ["commit.action.success"] = "Commit created successfully",
    ["commit.action.error"] = "Error creating commit: %s",
    ["commit.action.amend_success"] = "Commit amended successfully",
    ["commit.action.amend_error"] = "Error amending commit: %s",
    
    -- Commit error messages
    ["commit.error.not_git_repo"] = "Not a Git repository",
    ["commit.error.no_changes"] = "No changes to commit",
    ["commit.error.create_failed"] = "Failed to create commit",
    ["commit.error.no_commits"] = "No commits in history",
    ["commit.error.amend_failed"] = "Failed to amend last commit",
    ["commit.error.revert_failed"] = "Failed to revert commit",
    ["commit.error.cherry_pick_failed"] = "Failed to cherry-pick commit",
    ["commit.error.invalid_hash"] = "Invalid commit hash",
    ["commit.error.not_found"] = "Commit not found",

    -- Commit success messages
    ["commit.success.created"] = "Commit created successfully",
    ["commit.success.amended"] = "Commit amended successfully",
    ["commit.success.reverted"] = "Commit reverted successfully",
    ["commit.success.cherry_picked"] = "Commit cherry-picked successfully",

    -- Commit interaction messages
    ["commit.enter_message"] = "Commit message:",
    ["commit.enter_amend_message"] = "New commit message (empty to keep current):",
    ["commit.prompt.select"] = "Select a commit:",
    ["commit.prompt.revert"] = "Select a commit to revert:",
    ["commit.prompt.cherry_pick"] = "Select a commit to cherry-pick:",
    ["commit.confirm.amend"] = "Do you want to amend the last commit?",
    ["commit.confirm.revert"] = "Do you want to revert this commit?",
    ["commit.confirm.cherry_pick"] = "Do you want to cherry-pick this commit?",
    
    -- Branch management
    ["branch.title"] = " Branch Management",
    ["branch.current"] = "Current branch: %s",
    ["branch.none"] = "No branches found",
    ["branch.create_new"] = "Create new branch",
    ["branch.enter_name"] = "New branch name:",
    ["branch.select_branch"] = "Select a branch:",
    ["branch.select_action"] = "Choose an action:",
    ["branch.checkout"] = "Switch to this branch",
    ["branch.merge"] = "Merge this branch",
    ["branch.delete"] = "Delete this branch",
    ["branch.create.title"] = "Create Branch",
    ["branch.create.prompt"] = "New branch name:",
    ["branch.create.success"] = "Branch '%s' created successfully",
    ["branch.create.error"] = "Error creating branch: %s",
    ["branch.create.exists"] = "Branch '%s' already exists",
    ["branch.delete.title"] = "Delete Branch",
    ["branch.delete.prompt"] = "Select branch to delete:",
    ["branch.delete.confirm"] = "Delete branch '%s'? This action cannot be undone!",
    ["branch.delete.success"] = "Branch '%s' deleted successfully",
    ["branch.delete.error"] = "Error deleting branch: %s",
    ["branch.delete.current"] = "Cannot delete current branch",
    ["branch.switch.title"] = "Switch Branch",
    ["branch.switch.prompt"] = "Select branch:",
    ["branch.switch.success"] = "Switched to branch '%s'",
    ["branch.switch.error"] = "Error switching branch: %s",
    ["branch.merge.title"] = "Merge Branch",
    ["branch.merge.prompt"] = "Select branch to merge:",
    ["branch.merge.success"] = "Branch '%s' merged successfully",
    ["branch.merge.error"] = "Error merging branch: %s",
    
    -- Remote management
    ["remote.title"] = " Remote Management",
    ["remote.add"] = "Add remote",
    ["remote.remove"] = "Remove remote",
    ["remote.push"] = "Push changes",
    ["remote.pull"] = "Pull changes",
    ["remote.none"] = "No remotes found",
    ["remote.name.prompt"] = "Remote name:",
    ["remote.url.prompt"] = "Remote URL:",
    ["remote.added"] = "Remote added successfully",
    ["remote.deleted"] = "Remote deleted",
    ["remote.fetched"] = "Remote updated",
    ["remote.url"] = "URL",
    ["remote.tracking_info"] = "Tracking Information",
    ["remote.details_title"] = "Remote Details",
    ["remote.push.normal"] = "Normal (default)",
    ["remote.push.force"] = "Force (--force)",
    ["remote.push.force_lease"] = "Force with lease (--force-with-lease)",
    ["remote.action.success"] = "Remote operation completed successfully",
    ["remote.action.error"] = "Error performing remote operation: %s",
    
    -- Remote error messages
    ["remote.error.not_git_repo"] = "Not a Git repository",
    ["remote.error.list_failed"] = "Failed to retrieve remote list",
    ["remote.error.no_remotes"] = "No remotes found",
    ["remote.error.invalid_name"] = "Invalid remote name",
    ["remote.error.invalid_url"] = "Invalid remote URL",
    ["remote.error.already_exists"] = "Remote '%{name}' already exists",
    ["remote.error.not_found"] = "Remote '%{name}' does not exist",
    ["remote.error.add_failed"] = "Failed to add remote",
    ["remote.error.remove_failed"] = "Failed to remove remote",
    ["remote.error.fetch_failed"] = "Failed to fetch from remote",
    ["remote.error.pull_failed"] = "Failed to pull from remote",
    ["remote.error.push_failed"] = "Failed to push to remote",
    ["remote.error.prune_failed"] = "Failed to prune remote",

    -- Remote warning messages
    ["remote.warning.uncommitted_changes"] = "You have uncommitted changes",
    ["remote.warning.no_tracking"] = "Current branch is not tracking any remote",
    ["remote.warning.diverged"] = "Local branch has diverged from remote",

    -- Remote success messages
    ["remote.success.added"] = "Remote '%{name}' added successfully",
    ["remote.success.removed"] = "Remote '%{name}' removed successfully",
    ["remote.success.fetched"] = "Successfully fetched from '%{name}'",
    ["remote.success.pulled"] = "Successfully pulled from '%{name}'",
    ["remote.success.pushed"] = "Successfully pushed to '%{name}'",
    ["remote.success.pruned"] = "Successfully pruned '%{name}'",

    -- Remote interaction messages
    ["remote.select_remote"] = "Select a remote:",
    ["remote.prompt.name"] = "Remote name:",
    ["remote.prompt.url"] = "Remote URL:",
    ["remote.prompt.delete"] = "Are you sure you want to delete remote '%{name}'?",
    ["remote.prompt.fetch"] = "Do you want to fetch from '%{name}'?",
    ["remote.prompt.pull"] = "Do you want to pull from '%{name}'?",
    ["remote.prompt.push"] = "Do you want to push to '%{name}'?",
    ["remote.prompt.prune"] = "Do you want to prune deleted branches from '%{name}'?",
    
    -- Tag management
    ["tag.title"] = " Tag Management",
    ["tag.none"] = "No tags found",
    ["tag.message"] = "Message",
    ["tag.commit_info"] = "Commit Information",
    ["tag.details_title"] = "Tag Details",
    ["tag.create.title"] = "Create Tag",
    ["tag.create.name_prompt"] = "Tag name:",
    ["tag.create.message_prompt"] = "Message (optional):",
    ["tag.create.success"] = "Tag '%s' created successfully",
    ["tag.create.error"] = "Error creating tag: %s",
    ["tag.create.exists"] = "Tag '%s' already exists",
    ["tag.delete.title"] = "Delete Tag",
    ["tag.delete.prompt"] = "Select tag to delete:",
    ["tag.delete.confirm"] = "Delete tag '%s'? This action cannot be undone!",
    ["tag.delete.success"] = "Tag '%s' deleted successfully",
    ["tag.delete.error"] = "Error deleting tag: %s",
    ["tag.push.title"] = "Push Tags",
    ["tag.push.prompt"] = "Select tags to push:",
    ["tag.push.confirm"] = "Push selected tags?",
    ["tag.push.success"] = "Tags pushed successfully",
    ["tag.push.error"] = "Error pushing tags: %s",
    
    -- Tag error messages
    ["tag.error.not_git_repo"] = "Not a Git repository",
    ["tag.error.list_failed"] = "Failed to retrieve tag list",
    ["tag.error.no_tags"] = "No tags found",
    ["tag.error.invalid_name"] = "Invalid tag name",
    ["tag.error.already_exists"] = "Tag '%{name}' already exists",
    ["tag.error.create_failed"] = "Failed to create tag",
    ["tag.error.not_found"] = "Tag '%{name}' does not exist",
    ["tag.error.delete_failed"] = "Failed to delete tag",
    ["tag.error.push_failed"] = "Failed to push tag",
    ["tag.error.show_failed"] = "Failed to show tag details",

    -- Tag success messages
    ["tag.success.created"] = "Tag '%{name}' created successfully",
    ["tag.success.deleted"] = "Tag '%{name}' deleted successfully",
    ["tag.success.pushed"] = "Tag '%{name}' pushed successfully",

    -- Tag interaction messages
    ["tag.select_tag"] = "Select a tag:",
    ["tag.prompt.name"] = "Tag name:",
    ["tag.prompt.message"] = "Tag message (optional):",
    ["tag.prompt.delete"] = "Are you sure you want to delete tag '%{name}'?",
    ["tag.prompt.push"] = "Do you want to push tag '%{name}' to remote?",

    -- Tag preview messages
    ["tag.preview.title"] = "Tag: %{name}",
    ["tag.preview.details"] = "Tag details",
    ["tag.preview.commit"] = "Associated commit",
    ["tag.preview.author"] = "Author",
    ["tag.preview.date"] = "Date",
    ["tag.preview.message"] = "Message",

    -- Stash management
    ["stash.title"] = " Stash Management",
    ["stash.none"] = "No stashes found",
    ["stash.create.title"] = "Create Stash",
    ["stash.create.message_prompt"] = "Stash message (optional):",
    ["stash.create.success"] = "Stash created successfully",
    ["stash.create.error"] = "Error creating stash: %s",
    ["stash.create.no_changes"] = "No changes to stash",
    ["stash.apply.title"] = "Apply Stash",
    ["stash.apply.prompt"] = "Select stash to apply:",
    ["stash.apply.success"] = "Stash applied successfully",
    ["stash.apply.error"] = "Error applying stash: %s",
    ["stash.delete.title"] = "Delete Stash",
    ["stash.delete.prompt"] = "Select stash to delete:",
    ["stash.delete.confirm"] = "Delete selected stash? This action cannot be undone!",
    ["stash.delete.success"] = "Stash deleted successfully",
    ["stash.delete.error"] = "Error deleting stash: %s",
    
    -- Stash error messages
    ["stash.error.not_git_repo"] = "Not a Git repository",
    ["stash.error.no_changes"] = "No changes to stash",
    ["stash.error.save_failed"] = "Failed to save stash",
    ["stash.error.pop_failed"] = "Failed to pop stash",
    ["stash.error.apply_failed"] = "Failed to apply stash",
    ["stash.error.drop_failed"] = "Failed to drop stash",
    ["stash.error.list_failed"] = "Failed to list stashes",
    ["stash.error.no_stashes"] = "No stashes found",
    ["stash.error.not_found"] = "Stash not found",
    ["stash.error.show_failed"] = "Failed to show stash",

    -- Stash success messages
    ["stash.success.saved"] = "Changes stashed successfully",
    ["stash.success.popped"] = "Stash popped successfully",
    ["stash.success.applied"] = "Stash applied successfully",
    ["stash.success.dropped"] = "Stash dropped successfully",
    ["stash.success.cleared"] = "All stashes cleared successfully",

    -- Stash interaction messages
    ["stash.prompt.message"] = "Stash message (optional):",
    ["stash.prompt.select"] = "Select a stash:",
    ["stash.prompt.pop"] = "Select a stash to pop:",
    ["stash.prompt.apply"] = "Select a stash to apply:",
    ["stash.prompt.drop"] = "Select a stash to drop:",
    ["stash.confirm.pop"] = "Do you want to pop this stash?",
    ["stash.confirm.apply"] = "Do you want to apply this stash?",
    ["stash.confirm.drop"] = "Do you want to drop this stash?",
    ["stash.confirm.clear"] = "Do you want to clear all stashes?",
    
    -- Search operations
    ["search.title"] = " Search",
    ["search.menu.title"] = "Search Operations",
    ["search.menu.description"] = "Search in repository",
    ["search.prompt"] = "Enter your search:",
    ["search.no_results"] = "No results found",
    
    -- Commit search
    ["search.commits"] = "Search commits",
    ["search.commits.title"] = "Search in Commits",
    ["search.commits.description"] = "Search for specific commits",
    ["search.commits.prompt"] = "Enter search term:",
    ["search.commits.query"] = "Enter search query:",
    ["search.commits.empty"] = "Search term cannot be empty",
    ["search.commits.none"] = "No commits found",
    ["search.commits.no_results"] = "No results found for this search",
    ["search.commits.results"] = "Found %{count} commits:",
    ["search.commits.details"] = "Details",
    ["search.commits.details_title"] = "Commit Details %s",
    ["search.commits.details_error"] = "Error retrieving commit details",
    
    -- File search
    ["search.files"] = "Search files",
    ["search.files.title"] = "Search in Files",
    ["search.files.description"] = "Search for content in files",
    ["search.files.query"] = "Enter search pattern:",
    ["search.files.no_results"] = "No files found matching your query",
    ["search.files.results"] = "Found %{count} files:",
    
    -- Search errors
    ["search.error.not_git_repo"] = "Not a Git repository",
    ["search.error.empty_query"] = "Search query cannot be empty",
    ["search.error.commits_failed"] = "Failed to search commits",
    ["search.error.files_failed"] = "Failed to search files",
    ["search.error.branches_failed"] = "Failed to search branches",
    ["search.error.tags_failed"] = "Failed to search tags",
    ["search.error.invalid_query"] = "Invalid search query",
    ["search.error.search_failed"] = "Search failed: %{error}",
    
    -- Search info messages
    ["search.info.no_commits_found"] = "No commits found",
    ["search.info.no_files_found"] = "No files found",
    ["search.info.no_branches_found"] = "No branches found",
    ["search.info.no_tags_found"] = "No tags found",
    ["search.info.searching"] = "Searching...",

    -- Search success messages
    ["search.success.commits_found"] = "%{count} commits found",
    ["search.success.files_found"] = "%{count} files found",
    ["search.success.branches_found"] = "%{count} branches found",
    ["search.success.tags_found"] = "%{count} tags found",

    -- Search interaction messages
    ["search.prompt.query"] = "Enter your search query:",
    ["search.prompt.select_commit"] = "Select a commit:",
    ["search.prompt.select_file"] = "Select a file:",
    ["search.prompt.select_branch"] = "Select a branch:",
    ["search.prompt.select_tag"] = "Select a tag:",

    -- Preview messages
    ["search.preview.commit_title"] = "Commit %{hash}",
    ["search.preview.file_title"] = "File: %{path}",
    ["search.preview.branch_title"] = "Branch: %{name}",
    ["search.preview.tag_title"] = "Tag: %{name}",
    
    -- Version messages
    ["version.restore"] = "Restore Version",
    ["version.select_commit"] = "Select a commit to restore:",
    ["version.confirm_restore"] = "Do you want to restore this commit to a new branch?",
    ["version.enter_branch_name"] = "New branch name:",
    
    -- Version success messages
    ["version.success.restored"] = "Version restored to branch '%{branch}'",
    
    -- Version error messages
    ["version.error.no_commits"] = "No commits found",
    ["version.error.commit_not_found"] = "Commit not found",
    ["version.error.restore_failed"] = "Failed to restore version: %{error}",
    
    -- Backup messages
    ["backup.title"] = "Backup Management",
    ["backup.create"] = "Create Backup",
    ["backup.restore"] = "Restore Backup",
    ["backup.list"] = "List Backups",
    ["backup.export"] = "Export as Patch",
    ["backup.import"] = "Import Patch",
    ["backup.mirror"] = "Configure Mirror",
    ["backup.sync"] = "Sync Mirror",
    ["backup.delete"] = "Delete Backup",
    
    -- Backup success messages
    ["backup.success.created"] = "Backup '%{name}' created successfully",
    ["backup.success.restored"] = "Backup restored to branch '%{name}'",
    ["backup.success.deleted"] = "Backup deleted successfully",
    ["backup.success.patch_exported"] = "Patch exported successfully to '%{path}'",
    ["backup.success.patch_imported"] = "Patch imported successfully",
    ["backup.success.mirror_configured"] = "Mirror configured successfully",
    ["backup.success.mirror_synced"] = "Mirror synchronized successfully",
    
    -- Backup error messages
    ["backup.error.repo_name"] = "Unable to determine repository name",
    ["backup.error.create_failed"] = "Failed to create backup: %{error}",
    ["backup.error.restore_failed"] = "Failed to restore backup: %{error}",
    ["backup.error.invalid_bundle"] = "Invalid bundle: %{error}",
    ["backup.error.delete_failed"] = "Failed to delete backup: %{error}",
    ["backup.error.patch_export_failed"] = "Failed to export patch: %{error}",
    ["backup.error.patch_import_failed"] = "Failed to import patch: %{error}",
    ["backup.error.mirror_setup_failed"] = "Failed to setup mirror: %{error}",
    ["backup.error.mirror_config_failed"] = "Failed to configure mirror: %{error}",
    ["backup.error.mirror_sync_failed"] = "Failed to sync mirror: %{error}",
    
    -- Backup info messages
    ["backup.info.no_backups"] = "No backups available",
    ["backup.info.select_backup"] = "Select a backup:",
    ["backup.info.enter_branch"] = "Enter branch name:",
    ["backup.info.enter_path"] = "Enter destination path:",
    ["backup.info.enter_mirror"] = "Enter mirror URL:",
    
    -- UI messages
    ["ui.no_items"] = "No items to select",
    ["ui.select_not_available"] = "Selection not available",
    ["ui.select_prompt"] = "Select an option:",
    ["ui.input_prompt"] = "Enter a value:",
    ["test.message_only_in_english"] = "Test Message",
    
    -- Schedule messages
    ["schedule.title"] = "Automatic Backup Configuration",
    ["schedule.configure"] = "Configure Automatic Backups",
    ["schedule.toggle"] = "Enable/Disable Automatic Backups",
    ["schedule.on_branch_switch"] = "Backup on Branch Switch",
    ["schedule.on_commit"] = "Backup after Commit",
    ["schedule.on_push"] = "Backup after Push",
    ["schedule.on_pull"] = "Backup after Pull",
    ["schedule.daily"] = "Daily Backup",
    ["schedule.weekly"] = "Weekly Backup",
    ["schedule.configure_retention"] = "Configure Retention",
    ["schedule.max_backups"] = "Maximum number of backups to keep:",
    ["schedule.retain_days"] = "Number of days to retain backups:",
    
    -- Schedule success messages
    ["schedule.enabled"] = "Automatic backups enabled",
    ["schedule.disabled"] = "Automatic backups disabled",
    ["schedule.config_updated"] = "Backup configuration updated",
    
    -- Schedule error messages
    ["schedule.error.invalid_number"] = "Please enter a valid number",
    ["schedule.error.too_small"] = "Value must be greater than 0",
    
    -- Mirror messages
    ["mirror.title"] = "Mirror Management (Repository Replication)",
    ["mirror.add"] = "Add Mirror - Create a synchronized copy of the repository",
    ["mirror.list"] = "List Mirrors - View and manage your synchronized copies",
    ["mirror.sync_all"] = "Sync All Mirrors - Update all copies",
    ["mirror.configure"] = "Configure Mirrors - Synchronization settings",
    ["mirror.enter_name"] = "Give your mirror a short, descriptive name (e.g., backup_github):",
    ["mirror.enter_url"] = "Enter the remote repository URL (e.g., https://github.com/user/repo.git):",
    ["mirror.no_mirrors"] = "No mirrors configured. Add one to secure your code!",
    ["mirror.never_synced"] = "Never synced - Click 'Sync' to start",
    ["mirror.select_mirror"] = "Select a mirror to manage:",
    ["mirror.sync"] = "Sync - Update now",
    ["mirror.enable"] = "Enable - Allow synchronization",
    ["mirror.disable"] = "Disable - Pause synchronization",
    ["mirror.remove"] = "Remove - Delete this mirror",
    ["mirror.actions_for"] = "Available actions for mirror %s:",
    ["mirror.confirm_remove"] = "Are you sure you want to remove mirror %s? This won't delete the remote repository.",
    
    -- Mirror configuration messages
    ["mirror.config.title"] = "Mirror Synchronization Configuration",
    ["mirror.config.auto_sync"] = "Automatic Synchronization - Keep copies up-to-date without intervention",
    ["mirror.config.sync_interval"] = "Sync Interval - Frequency of automatic updates",
    ["mirror.config.sync_on_push"] = "Sync on Push - Immediate update after each push",
    ["mirror.config.enable_auto_sync"] = "Do you want to enable automatic synchronization? Recommended for safety.",
    ["mirror.config.enable_sync_on_push"] = "Automatically sync after each push? Recommended for consistency.",
    ["mirror.config.enter_interval"] = "Time between synchronizations (in seconds, e.g., 3600 for 1 hour):",
    
    -- Mirror help messages
    ["mirror.help.what_is"] = "A mirror is a complete, synchronized copy of your Git repository. It can serve as a backup or replica.",
    ["mirror.help.why_use"] = "Mirrors are useful for:\n- Backing up your code\n- Distributing code across multiple servers\n- Accelerating access in different regions",
    ["mirror.help.how_to"] = "To get started:\n1. Add a mirror with its URL\n2. Enable automatic synchronization\n3. Regularly check mirror status",
    ["mirror.help.auto_sync"] = "Automatic synchronization keeps your mirrors up-to-date without manual intervention.",
    ["mirror.help.sync_interval"] = "Choose an interval that matches your commit frequency:\n- 1 hour: very active projects\n- 24 hours: less active projects",
    
    -- Mirror success messages
    ["mirror.success.added"] = "Mirror %{name} added successfully",
    ["mirror.success.removed"] = "Mirror %{name} removed successfully",
    ["mirror.success.enabled"] = "Mirror %{name} enabled",
    ["mirror.success.disabled"] = "Mirror %{name} disabled",
    ["mirror.success.synced"] = "Mirror %{name} synced successfully",
    
    -- Mirror error messages
    ["mirror.error.already_exists"] = "Mirror %{name} already exists",
    ["mirror.error.invalid_url"] = "Invalid mirror URL",
    ["mirror.error.add_failed"] = "Failed to add mirror: %{error}",
    ["mirror.error.config_failed"] = "Failed to configure mirror",
    ["mirror.error.not_found"] = "Mirror %{name} not found",
    ["mirror.error.remove_failed"] = "Failed to remove mirror: %{error}",
    ["mirror.error.disabled"] = "Mirror %{name} is disabled",
    ["mirror.error.sync_failed"] = "Failed to sync %{name}: %{error}",
    ["mirror.error.invalid_interval"] = "Invalid interval",
    
    -- Patch management
    ["patch.menu.title"] = "Patch Management",
    ["patch.menu.description"] = "Create, apply and manage Git patches",
    
    ["patch.create.title"] = "Create Patch",
    ["patch.create.description"] = "Create a patch from selected commits",
    ["patch.create.start_commit"] = "Start commit (empty for last commit)",
    ["patch.create.end_commit"] = "End commit (empty for HEAD)",
    ["patch.create.output_dir"] = "Output directory (empty for current directory)",
    ["patch.create.success"] = "Patch(es) created successfully: %{files}",
    ["patch.create.error"] = "Error creating patch: %{error}",
    
    ["patch.apply.title"] = "Apply Patch",
    ["patch.apply.description"] = "Apply an existing patch to the repository",
    ["patch.apply.select"] = "Select a patch to apply",
    ["patch.apply.no_patches"] = "No patches found in directory",
    ["patch.apply.check_failed"] = "Patch cannot be applied: %{error}",
    ["patch.apply.success"] = "Patch applied successfully",
    ["patch.apply.error"] = "Error applying patch: %{error}",
    
    ["patch.list.title"] = "List Patches",
    ["patch.list.description"] = "View available patches",
    ["patch.list.empty"] = "No patches found",
    ["patch.show.error"] = "Error displaying patch: %{error}",
    
    -- Interactive History
    ["history.menu.title"] = "Git History",
    ["history.menu.description"] = "Browse and search Git history",
    
    ["history.browse.title"] = "Browse History",
    ["history.browse.description"] = "View list of recent commits",
    
    ["history.search.title"] = "Search History",
    ["history.search.description"] = "Search commits by content",
    ["history.search.prompt"] = "Enter search term:",
    ["history.search.empty"] = "Search term cannot be empty",
    ["history.search.no_results"] = "No results found",
    ["history.search.results"] = "Search Results",
    
    ["history.graph.title"] = "Branch Graph",
    ["history.graph.description"] = "Visualize branch and commit graph",
    
    ["history.filter.title"] = "Filter History",
    ["history.filter.description"] = "Filter commits by author, date, or file",
    ["history.filter.by_author"] = "Filter by Author",
    ["history.filter.by_date"] = "Filter by Date",
    ["history.filter.by_file"] = "Filter by File",
    ["history.filter.author_prompt"] = "Author name:",
    ["history.filter.date_prompt"] = "Date (YYYY-MM-DD):",
    ["history.filter.file_prompt"] = "File path:",
    ["history.filter.no_results"] = "No commits found with these criteria",
    ["history.filter.results"] = "Filtered Commits",
    
    ["history.details.commit"] = "Commit: %{hash}",
    ["history.details.author"] = "Author: %{author} <%{email}>",
    ["history.details.date"] = "Date: %{date}",
    ["history.details.subject"] = "Subject: %{subject}",
    ["history.details.files"] = "Modified Files:",
    ["history.details.stats"] = "Statistics:",
    
    ["history.error.fetch"] = "Error fetching history",
    ["history.error.details"] = "Error fetching commit details",
    ["history.error.search"] = "Error during search",
    ["history.error.graph"] = "Error generating graph",
    
    -- Issues Management
    ["issues.menu.title"] = "Issues Management",
    ["issues.menu.description"] = "Create and manage GitHub/GitLab issues",
    
    ["issues.create.title"] = "Create Issue",
    ["issues.create.description"] = "Create a new issue",
    ["issues.create.select_template"] = "Select Template",
    ["issues.create.title_prompt"] = "Issue title:",
    ["issues.create.title_empty"] = "Title cannot be empty",
    ["issues.create.body_prompt"] = "Issue description:",
    ["issues.create.labels_prompt"] = "Labels (comma-separated):",
    ["issues.create.assignees_prompt"] = "Assignees (comma-separated):",
    ["issues.create.success"] = "Issue #%{number} created successfully",
    ["issues.create.error"] = "Error creating issue: %{error}",
    
    ["issues.list.title"] = "List Issues",
    ["issues.list.description"] = "View all issues",
    ["issues.list.empty"] = "No issues found",
    ["issues.list.error"] = "Error fetching issues: %{error}",
    
    ["issues.search.title"] = "Search Issues",
    ["issues.search.description"] = "Search issues by criteria",
    ["issues.search.by_author"] = "Search by Author",
    ["issues.search.by_label"] = "Search by Label",
    ["issues.search.by_status"] = "Search by Status",
    ["issues.search.author_prompt"] = "Author name:",
    ["issues.search.label_prompt"] = "Label to search:",
    ["issues.search.select_status"] = "Select Status",
    ["issues.search.no_results"] = "No issues found",
    ["issues.search.results"] = "Search Results",
    
    ["issues.link.title"] = "Link Commit to Issue",
    ["issues.link.description"] = "Link a commit to an issue",
    ["issues.link.commit_prompt"] = "Commit hash:",
    ["issues.link.commit_empty"] = "Commit hash cannot be empty",
    ["issues.link.issue_prompt"] = "Issue number:",
    ["issues.link.issue_empty"] = "Issue number cannot be empty",
    ["issues.link.success"] = "Successfully linked commit to issue",
    ["issues.link.error"] = "Error linking commit: %{error}",
    
    ["issues.details.number"] = "Issue #%{number}",
    ["issues.details.title"] = "Title: %{title}",
    ["issues.details.status"] = "Status: %{status}",
    ["issues.details.author"] = "Author: %{author}",
    ["issues.details.labels"] = "Labels",
    ["issues.details.assignees"] = "Assignees",
    
    ["issues.status.open"] = "Open",
    ["issues.status.closed"] = "Closed",
    
    -- Conflict Management
    ["conflict.menu.title"] = "Conflict Management",
    ["conflict.menu.description"] = "Resolve merge conflicts",
    ["conflict.section.ours"] = "Our version (%{ref})",
    ["conflict.section.theirs"] = "Their version (%{ref})",
    ["conflict.resolve.use_ours"] = "Use our version",
    ["conflict.resolve.use_ours_desc"] = "Keep changes from our branch",
    ["conflict.resolve.use_theirs"] = "Use their version",
    ["conflict.resolve.use_theirs_desc"] = "Keep changes from their branch",
    ["conflict.resolve.manual"] = "Manual resolution",
    ["conflict.resolve.manual_desc"] = "Open editor for manual resolution",
    ["conflict.resolve.success"] = "Conflict resolved successfully",
    ["conflict.resolve.error"] = "Error resolving conflict",
    ["conflict.search.error"] = "Error searching for conflicts",
    ["conflict.no_conflicts"] = "No conflicts found",
    ["conflict.select_file"] = "Select a file with conflicts:",
    ["conflict.select_conflict"] = "Select a conflict to resolve:",
    
    -- Conflict management
    ["conflict.files.title"] = "Conflicting Files",
    ["conflict.list.title"] = "Conflict List",
    ["conflict.item"] = "Conflict #%{number} (lines %{start}-%{end_line})",
    ["conflict.resolve.preview_diff"] = "View differences",
    ["conflict.resolve.preview_diff_desc"] = "Compare versions side by side",
    ["conflict.resolve.use_previous"] = "Use previous resolution",
    ["conflict.resolve.use_previous_desc"] = "Apply same resolution as last time",
    ["conflict.resolve.manual_prompt"] = "Enter resolved content:",
    ["conflict.resolve.manual_empty"] = "Content cannot be empty",
    ["conflict.diff.error"] = "Error comparing versions",
    ["conflict.read.error"] = "Error reading file",
    
    -- Rebase error messages
    ["rebase.error.not_git_repo"] = "Not a Git repository",
    ["rebase.error.already_rebasing"] = "A rebase is already in progress",
    ["rebase.error.log_failed"] = "Failed to retrieve commit history",
    ["rebase.error.no_commits"] = "No commits found for rebase",
    ["rebase.error.start_failed"] = "Failed to start rebase",
    ["rebase.error.continue_failed"] = "Failed to continue rebase",
    ["rebase.error.abort_failed"] = "Failed to abort rebase",
    ["rebase.error.skip_failed"] = "Failed to skip current commit",
    ["rebase.error.not_rebasing"] = "No rebase in progress",
    ["rebase.error.conflicts"] = "Conflicts must be resolved before continuing",

    -- Rebase warning messages
    ["rebase.warning.uncommitted_changes"] = "You have uncommitted changes",
    ["rebase.warning.no_changes"] = "No changes to apply",
    ["rebase.warning.conflicts_pending"] = "Conflicts are pending resolution",

    -- Rebase success messages
    ["rebase.success.started"] = "Rebase started successfully",
    ["rebase.success.continued"] = "Rebase continued successfully",
    ["rebase.success.aborted"] = "Rebase aborted successfully",
    ["rebase.success.skipped"] = "Commit skipped successfully",
    ["rebase.success.completed"] = "Rebase completed successfully",

    -- Rebase interaction messages
    ["rebase.prompt.select_commit"] = "Select a commit for rebase:",
    ["rebase.prompt.continue"] = "Continue rebase?",
    ["rebase.prompt.abort"] = "Abort rebase?",
    ["rebase.prompt.skip"] = "Skip current commit?",
    ["rebase.confirm.abort"] = "Are you sure you want to abort the rebase?",
    ["rebase.confirm.skip"] = "Are you sure you want to skip this commit?",
    
    -- Branch menu items
    ["branch.create_new"] = "Create New Branch",
    ["branch.checkout"] = "Checkout Branch",
    ["branch.merge"] = "Merge Branch",
    ["branch.delete"] = "Delete Branch",
    ["branch.push"] = "Push Branch",
    ["branch.pull"] = "Pull Branch",
    ["branch.rebase"] = "Rebase Branch",
    ["branch.refresh"] = "Refresh Branches",

    -- Commit menu items
    ["commit.create"] = "Create Commit",
    ["commit.amend"] = "Amend Last Commit",
    ["commit.fixup"] = "Fixup Commit",
    ["commit.revert"] = "Revert Commit",
    ["commit.cherry_pick"] = "Cherry Pick Commit",
    ["commit.show"] = "Show Commit",

    -- Stash menu items
    ["stash.save"] = "Save Stash",
    ["stash.pop"] = "Pop Stash",
    ["stash.apply"] = "Apply Stash",
    ["stash.drop"] = "Drop Stash",
    ["stash.show"] = "Show Stash",
    ["stash.clear"] = "Clear All Stashes",

    -- Tag menu items
    ["tag.create"] = "Create Tag",
    ["tag.delete"] = "Delete Tag",
    ["tag.push"] = "Push Tag",
    ["tag.show"] = "Show Tag",

    -- Remote menu items
    ["remote.add"] = "Add Remote",
    ["remote.remove"] = "Remove Remote",
    ["remote.fetch"] = "Fetch Remote",
    ["remote.pull"] = "Pull Remote",
    ["remote.push"] = "Push Remote",
    ["remote.prune"] = "Prune Remote",

    -- Rebase menu items
    ["rebase.start"] = "Start Rebase",
    ["rebase.continue"] = "Continue Rebase",
    ["rebase.skip"] = "Skip Rebase",
    ["rebase.abort"] = "Abort Rebase",
    ["rebase.interactive"] = "Interactive Rebase",

    -- Search menu items
    ["search.commits"] = "Search Commits",
    ["search.files"] = "Search Files",
    ["search.branches"] = "Search Branches",
    ["search.tags"] = "Search Tags",

    -- Backup menu items
    ["backup.create"] = "Create Backup",
    ["backup.restore"] = "Restore Backup",
    ["backup.delete"] = "Delete Backup",

    -- Error messages
    ["error.invalid_menu"] = "Invalid menu selected",
}
