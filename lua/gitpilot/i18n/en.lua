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
        commit = "📝 Create commit",
        branch = "🌿 Manage branches",
        rebase = "🔄 Rebase assistant",
        conflict = "🚧 Resolve conflicts",
        stash = "📦 Manage stash",
        history = "📜 View history",
        search = "🔍 Search",
        tags = "🏷️ Manage tags",
        
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
        
        -- Tags submenu (old)
        -- create_tag = "➕ Create tag",
        -- delete_tag = "❌ Delete tag",
        -- push_tag = "⬆️ Push tags"
    },
    
    -- Commit assistant
    commit = {
        type = {
            title = "Change type:",
            feat = "✨ New feature",
            fix = "🐛 Bug fix",
            docs = "📚 Documentation",
            style = "💎 Code style",
            refactor = "♻️ Refactoring",
            test = "🧪 Tests",
            chore = "🔧 Maintenance"
        },
        files = {
            select = "Select files to include:",
            selected = "Selected files:",
            none = "No files selected",
            all = "Select all",
            none_action = "Deselect all"
        },
        message = {
            prompt = "Commit message:",
            hint = "Briefly describe your changes",
            warning = "⚠️ Message is too short",
            template = "{type}: {description}"
        }
    },

    -- Branch management
    branch = {
        current = "Current branch:",
        create = "➕ Create new branch",
        switch = "🔄 Switch branch",
        merge = "🔀 Merge branch",
        delete = "❌ Delete branch",
        
        create_title = "Create New Branch",
        create_success = "Branch '%{name}' created successfully",
        create_error = "Error creating branch: %{error}",
        
        switch_title = "Switch Branch",
        switch_success = "Switched to branch '%{name}'",
        switch_error = "Error switching branch: %{error}",
        
        merge_title = "Merge Branch",
        merge_confirm = "Merge '%{source}' into '%{target}'?",
        merge_success = "Successfully merged '%{name}'",
        merge_error = "Merge error: %{error}",
        
        delete_title = "Delete Branch",
        delete_confirm = "Delete branch '%{name}'?",
        delete_success = "Branch '%{name}' deleted",
        delete_error = "Error deleting branch: %{error}",
        
        exists = "This branch already exists",
        none = "No branches found",
        already_on = "You are already on this branch",
        no_merge_candidates = "No branches available for merging",
        no_delete_candidates = "No branches available for deletion",
        cannot_delete_current = "Cannot delete current branch",
        
        warning = {
            delete = "⚠️ This action is irreversible",
            unmerged = "⚠️ This branch is not merged"
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

    -- Stash manager
    stash = {
        create = "➕ Create stash",
        apply = "📥 Apply stash",
        pop = "📤 Pop stash",
        drop = "❌ Drop stash",
        list = "📋 Stash list",
        empty = "No stashes available",
        message = {
            prompt = "Stash message (optional):"
        },
        no_changes = "No changes to stash",
        none = "No stash found",
        created = "Stash created successfully",
        applied = "Stash applied successfully",
        dropped = "Stash dropped successfully",
        error = {
            create = "Error creating stash",
            apply = "Error applying stash",
            drop = "Error dropping stash"
        }
    },

    -- Search menu
    search = {
        commits = "🔍 Search commits",
        files = "📁 Search files",
        author = "👤 Search by author",
        branches = "🌿 Search branches",
        
        commits_prompt = "Enter search term:",
        files_prompt = "Enter file pattern:",
        author_prompt = "Enter author name:",
        branches_prompt = "Enter branch pattern:",
        
        commits_none = "No commits found",
        files_none = "No files found",
        author_none = "No commits found for this author",
        branches_none = "No branches found",
        
        commits_results = "Search Results - Commits",
        files_results = "Search Results - Files",
        author_results = "Search Results - Author",
        branches_results = "Search Results - Branches"
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
