return {
    -- General messages
    welcome = "Welcome to GitPilot!",
    select_action = "Select an action:",
    confirm = {
        title = "Confirmation Required",
        yes = "Yes",
        no = "No"
    },
    cancel = "Cancel",
    success = "Success!",
    error = "Error",
    warning = "Warning",
    
    -- Main menu
    menu = {
        main = "Main Menu",
        commits = "Commit Operations",
        commits_title = "📝 Commit Management",
        branches = "Branch Operations",
        branches_title = "🌿 Branch Management",
        remotes = "Remote Operations",
        remotes_title = "🔄 Remote Management",
        tags = "Tag Operations",
        tags_title = "🏷️ Tag Management",
        stash = "Stash Operations",
        stash_title = "📦 Stash Management",
        search = "Search Operations",
        search_title = "🔍 Search",
        rebase = "Rebase Operations",
        rebase_title = "♻️ Rebase",
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
        push_tags = "⬆️ Push tags"
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

    -- Branch management
    branch = {
        title = "🌿 Branch Management",
        current = "Current branch: %s",
        none = "No branches found",
        create = {
            title = "Create Branch",
            prompt = "New branch name:",
            success = "Branch '%s' created successfully",
            error = "Error creating branch: %s",
            exists = "Branch '%s' already exists"
        },
        delete = {
            title = "Delete Branch",
            prompt = "Select branch to delete:",
            confirm = "Delete branch '%s'? This action cannot be undone!",
            success = "Branch '%s' deleted successfully",
            error = "Error deleting branch: %s",
            current = "Cannot delete current branch"
        },
        checkout = {
            title = "Switch Branch",
            prompt = "Select branch:",
            success = "Switched to branch '%s'",
            error = "Error switching branch: %s"
        }
    },

    -- Tag management
    tag = {
        title = "🏷️ Tag Management",
        none = "No tags found",
        create = {
            title = "Create Tag",
            name_prompt = "Tag name:",
            message_prompt = "Message (optional):",
            success = "Tag '%s' created successfully",
            error = "Error creating tag: %s",
            exists = "Tag '%s' already exists"
        },
        delete = {
            title = "Delete Tag",
            prompt = "Select tag to delete:",
            confirm = "Delete tag '%s'? This action cannot be undone!",
            success = "Tag '%s' deleted successfully",
            error = "Error deleting tag: %s"
        },
        push = {
            title = "Push Tags",
            prompt = "Select tags to push:",
            confirm = "Push selected tags?",
            success = "Tags pushed successfully",
            error = "Error pushing tags: %s"
        }
    },

    -- Stash management
    stash = {
        title = "📦 Stash Management",
        none = "No stashes found",
        create = {
            title = "Create Stash",
            message_prompt = "Stash message (optional):",
            success = "Stash created successfully",
            error = "Error creating stash: %s",
            no_changes = "No changes to stash"
        },
        apply = {
            title = "Apply Stash",
            prompt = "Select stash to apply:",
            success = "Stash applied successfully",
            error = "Error applying stash: %s"
        },
        delete = {
            title = "Delete Stash",
            prompt = "Select stash to delete:",
            confirm = "Delete selected stash? This action cannot be undone!",
            success = "Stash deleted successfully",
            error = "Error deleting stash: %s"
        }
    },

    -- Search
    search = {
        title = "🔍 Search",
        prompt = "Enter your search:",
        no_results = "No results found",
        commits = {
            title = "Search in commits",
            prompt = "Enter search term:"
        }
    },

    -- Rebase operations
    rebase = {
        title = "♻️ Rebase",
        intro = "Interactive Rebase Assistant",
        warning = "⚠️ This operation will modify history",
        backup = "A backup will be created automatically",
        select_base = "Select base branch or commit:",
        actions = {
            pick = "pick - use commit",
            reword = "reword - edit commit message",
            edit = "edit - edit commit",
            squash = "squash - combine with previous commit",
            fixup = "fixup - combine silently with previous commit",
            drop = "drop - remove commit"
        },
        conflict = {
            detected = "Rebase conflicts detected",
            resolve = "Please resolve conflicts and continue",
            abort = "Or abort the rebase"
        },
        continue = {
            prompt = "Continue rebase?",
            success = "Rebase completed successfully",
            error = "Error continuing rebase: %s"
        },
        abort = {
            prompt = "Abort rebase?",
            success = "Rebase aborted successfully",
            error = "Error aborting rebase: %s"
        }
    }
}
