return {
    -- General messages
    welcome = "Welcome to GitPilot!",
    select_action = "Select an action:",
    confirm = "Confirm",
    cancel = "Cancel",
    success = "Success!",
    error = "Error",
    warning = "Warning",
    
    -- Main menu
    menu = {
        main = "Main Menu",
        commits = "📝 Manage commits",
        commits_title = "📝 Commit Management",
        branches = "🌿 Manage branches",
        branches_title = "🌿 Branch Management",
        remotes = "🔄 Manage remotes",
        remotes_title = "🔄 Remote Management",
        tags = "🏷️ Manage tags",
        tags_title = "🏷️ Tag Management",
        stash = "📦 Manage stash",
        stash_title = "📦 Stash Management",
        search = "🔍 Search",
        search_title = "🔍 Search",
        rebase = "🔄 Rebase assistant",
        rebase_title = "🔄 Rebase Assistant",
        conflict = "🚧 Resolve conflicts",
        history = "📜 View history",
        
        -- Commit submenu
        create_commit = "📝 Create new commit",
        amend_commit = "✏️ Amend last commit",
        history = "📜 View commit history",
        
        -- Remote submenu
        add_remote = "➕ Add remote repository",
        remove_remote = "❌ Remove remote repository",
        fetch = "⬇️ Fetch changes",
        push = "⬆️ Push changes",
        
        -- Branch menu
        create_branch = "➕ Create new branch",
        switch_branch = "🔄 Switch branch",
        merge_branch = "🔀 Merge branch",
        delete_branch = "❌ Delete branch",
        
        -- Tags submenu
        create_tag = "➕ Create tag",
        delete_tag = "❌ Delete tag",
        list_tags = "📋 List tags",
        push_tags = "⬆️ Push tags",
    },
    
    -- Commit management
    commit = {
        title = "📝 Commit Management",
        files = {
            select = "Select files to commit",
            selected = "Selected files",
            none = "No files to commit",
            all = "Select all files",
            none_action = "Deselect all files",
            staged = "Staged files",
            unstaged = "Unstaged files"
        },
        type = {
            title = "Select commit type",
            feat = "✨ New feature",
            fix = "🐛 Bug fix",
            docs = "📚 Documentation",
            style = "💎 Code style",
            refactor = "♻️ Code refactoring",
            perf = "⚡ Performance improvement",
            test = "🧪 Tests",
            build = "🔧 Build system",
            ci = "👷 CI/CD",
            chore = "🔨 Chore",
            revert = "⏪ Revert changes"
        },
        message = {
            title = "Commit Message",
            prompt = "Enter commit message:",
            hint = "Brief description of changes",
            scope = "Enter scope (optional):",
            body = "Enter detailed description (optional):",
            breaking = "Breaking changes (optional):",
            footer = "Footer notes (optional):",
            preview = "Preview commit message:",
            empty = "Commit message cannot be empty",
            too_short = "Commit message is too short"
        },
        action = {
            create = "Create commit",
            amend = "Amend last commit",
            success = "Changes committed successfully",
            amend_success = "Commit amended successfully",
            error = "Error creating commit: %s",
            amend_error = "Error amending commit: %s",
            cancel = "Commit cancelled"
        },
        status = {
            staged = "Staged changes",
            unstaged = "Unstaged changes",
            untracked = "Untracked files",
            no_changes = "No changes to commit"
        }
    },

    -- Commit messages
    commit_messages = {
        create = "📝 Create new commit",
        amend = "✏️ Amend last commit",
        history = "📜 View history",
        discard = "🗑️ Discard changes",
        title = "Commit message",
        description = "Description (optional)",
        success = "Commit created successfully",
        amend_success = "Commit amended successfully",
        error = "Error creating commit",
        no_changes = "No changes to commit",
        confirm_discard = "Do you really want to discard all changes? This action cannot be undone. (y/N)"
    },

    -- Branch management
    branch = {
        title = "🌿 Branch Management",
        current = "Current branch: %s",
        none = "No branches found",
        create = {
            title = "Create New Branch",
            prompt = "Enter branch name:",
            from = "Create from: %s",
            success = "Branch '%s' created successfully",
            error = "Error creating branch: %s",
            exists = "Branch '%s' already exists",
            invalid = "Invalid branch name"
        },
        switch = {
            title = "Switch Branch",
            prompt = "Select branch to switch to:",
            confirm = "Switch to branch '%s'?",
            success = "Switched to branch '%s'",
            error = "Error switching branch: %s",
            unsaved = "You have unsaved changes. Stash or commit them first"
        },
        merge = {
            title = "Merge Branch",
            prompt = "Select branch to merge into current branch:",
            confirm = "Merge '%s' into '%s'?",
            success = "Branch '%s' merged successfully",
            error = "Error merging branch: %s",
            conflict = "Merge conflicts detected",
            abort = "Merge aborted",
            no_ff = "Merge with commit (no fast-forward)",
            squash = "Squash merge"
        },
        delete = {
            title = "Delete Branch",
            prompt = "Select branch to delete:",
            confirm = "Delete branch '%s'? This cannot be undone! (y/N)",
            success = "Branch '%s' deleted successfully",
            error = "Error deleting branch: %s",
            unmerged = "Branch '%s' is not fully merged",
            force = "Force delete unmerged branch?"
        },
        status = {
            ahead = "%d commits ahead of '%s'",
            behind = "%d commits behind '%s'",
            diverged = "Diverged from '%s' by %d commits",
            up_to_date = "Up to date with '%s'",
            local_only = "Local branch only",
            tracking = "Tracking '%s'"
        },
        type = {
            local = "Local branch",
            remote = "Remote branch",
            tracking = "Tracking branch"
        }
    },
    
    -- Branch messages
    branch_messages = {
        current = "current branch",
        create = "➕ Create new branch",
        switch = "🔄 Switch branch",
        merge = "🔀 Merge branch",
        delete = "❌ Delete branch",
        create_title = "Create new branch",
        switch_title = "Switch branch",
        merge_title = "Merge branch",
        delete_title = "Delete branch",
        switch_success = "Switched to branch '%{name}'",
        create_success = "Branch '%{name}' created successfully",
        merge_success = "Successfully merged branch '%{name}'",
        delete_success = "Branch '%{name}' deleted successfully",
        error_exists = "Branch '%{name}' already exists",
        error_not_exists = "Branch '%{name}' does not exist",
        error_current = "Cannot delete the current branch",
        confirm_delete = "Are you sure you want to delete branch '%{name}'?",
    },

    -- Tag management
    tag = {
        name = {
            prompt = "Enter tag name:",
            invalid = "Invalid tag name"
        },
        message = {
            prompt = "Enter tag message (optional for lightweight tag):",
        },
        exists = "Tag already exists",
        created_light = "Lightweight tag created successfully",
        created_annotated = "Annotated tag created successfully",
        none = "No tags found",
        confirm_delete = "Are you sure you want to delete tag '%s'? (y/N)",
        deleted = "Tag '%s' deleted successfully",
        delete_title = "Delete Tag",
        push_success = "Tags pushed successfully",
        push_error = "Error pushing tags: %s"
    },

    -- Remote management
    remote = {
        title = "🔄 Remote Management",
        none = "No remote repositories found",
        name = {
            prompt = "Enter remote name:",
            invalid = "Invalid remote name",
            exists = "Remote with this name already exists"
        },
        url = {
            prompt = "Enter remote URL:",
            invalid = "Invalid remote URL"
        },
        add = {
            title = "Add Remote Repository",
            success = "Remote '%s' added successfully",
            error = "Error adding remote: %s"
        },
        remove = {
            title = "Remove Remote Repository",
            select = "Select remote to remove:",
            confirm = "Are you sure you want to remove remote '%s'?",
            success = "Remote '%s' removed successfully",
            error = "Error removing remote: %s"
        },
        fetch = {
            title = "Fetch Changes",
            all = "Fetch from all remotes",
            specific = "Fetch from '%s'",
            success = "Changes fetched successfully",
            error = "Error fetching changes: %s"
        },
        push = {
            title = "Push Changes",
            select_remote = "Select remote to push to:",
            select_branch = "Select branch to push:",
            confirm = "Push to %s/%s?",
            force = "Force push (--force-with-lease)",
            success = "Changes pushed successfully",
            error = "Error pushing changes: %s"
        },
        pull = {
            title = "Pull Changes",
            select_remote = "Select remote to pull from:",
            select_branch = "Select branch to pull:",
            confirm = "Pull from %s/%s?",
            success = "Changes pulled successfully",
            error = "Error pulling changes: %s"
        }
    },

    -- Rebase assistant
    rebase = {
        intro = "Interactive Rebase Assistant",
        warning = "⚠️ This operation will modify history",
        backup = "A backup will be created automatically",
        title = "📝 Interactive Rebase - Organize Your Commits",
        help_title = "❓ Usage Guide",
        action = {
            pick = "✅ Keep commit as is",
            reword = "📝 Edit commit message",
            edit = "🔧 Edit commit content",
            squash = "🔗 Merge with previous (keep both messages)",
            fixup = "🔗 Merge with previous (keep only previous message)",
            drop = "❌ Remove this commit"
        },
        help_move = "↑/↓ (j/k) : Navigate | J/K : Move commit",
        help_start = "ENTER : Start rebase | P : Preview changes",
        help_cancel = "q/ESC : Cancel",
        no_commits = "⚠️ No commits to reorganize",
        started = "✨ Interactive rebase started",
        preview = "🔍 Changes Preview",
        conflicts = {
            title = "⚠️ Conflicts Detected - Resolution Required",
            actions = "Available Actions:",
            no_conflicts = "✅ No conflicts to resolve",
            ours = "Keep OUR changes",
            theirs = "Keep THEIR changes",
            add = "Mark as resolved",
            continue = "Continue rebase",
            skip = "Skip this commit",
            abort = "Abort rebase",
            resolved = "✅ Conflict resolved for %s",
            done = "🎉 All conflicts resolved!"
        }
    },

    -- Conflict resolution
    conflict = {
        found = "Conflicts found in files:",
        none = "No conflicts detected",
        options = {
            ours = "Keep our changes",
            theirs = "Keep their changes",
            both = "Keep both",
            manual = "Edit manually"
        },
        help = "Use arrows to navigate and Enter to select"
    },

    -- Stash management
    stash = {
        title = "📦 Stash Management",
        select_files = "Select files to stash",
        no_changes = "No changes to stash",
        none = "No stashes found",
        create = {
            prompt = "Enter stash message (optional):",
            success = "Changes stashed successfully",
            error = "Error stashing changes"
        },
        apply = {
            title = "Apply Stash",
            confirm = "Apply stash '%s'?",
            success = "Stash applied successfully",
            error = "Error applying stash"
        },
        delete = {
            title = "Delete Stash",
            confirm = "Delete stash '%s'? (y/N)",
            success = "Stash deleted successfully",
            error = "Error deleting stash"
        },
        navigation = {
            select_all = "Select all",
            deselect_all = "Deselect all",
            toggle = "Toggle selection",
            confirm = "Confirm",
            cancel = "Cancel"
        }
    },

    -- Search functionality
    search = {
        title = "🔍 Search",
        no_results = "No results found",
        commits = {
            title = "Search Commits",
            prompt = "Enter search term for commits:",
            results = "Search Results - Commits",
            none = "No matching commits found",
            details = "Commit Details",
            copy_hash = "Hash copied to clipboard",
            by_message = "Search by commit message",
            by_files = "Search by changed files"
        },
        files = {
            title = "Search Files",
            prompt = "Enter file pattern to search:",
            results = "Search Results - Files",
            none = "No matching files found",
            in_content = "Search in file contents",
            by_name = "Search by file name",
            by_extension = "Search by file extension"
        },
        author = {
            title = "Search by Author",
            prompt = "Enter author name:",
            results = "Search Results - Author Commits",
            none = "No commits found for this author",
            email = "Search by email",
            name = "Search by name"
        },
        branches = {
            title = "Search Branches",
            prompt = "Enter branch pattern to search:",
            results = "Search Results - Branches",
            none = "No matching branches found",
            local = "Local branches",
            remote = "Remote branches",
            all = "All branches"
        },
        navigation = {
            next = "Next result",
            previous = "Previous result",
            details = "Show details",
            close = "Close",
            help = "Press '?' for help"
        }
    },

    -- Contextual help messages
    help = {
        rebase = "Rebase allows you to reorganize your commits. Follow the guide!",
        conflict = "A conflict occurs when two changes overlap.",
        stash = "Stash allows you to temporarily store your changes.",
        general = "Press ? for help, Esc to cancel",
        keys = {
            navigation = "↑/↓: Navigation",
            select = "Enter: Select",
            cancel = "Esc: Cancel",
            help = "?: Help"
        }
    }
}
