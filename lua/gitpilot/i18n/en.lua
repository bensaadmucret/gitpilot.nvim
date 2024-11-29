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
        history = "📜 View history"
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
        merge = "🔗 Merge branch",
        delete = "❌ Delete branch",
        select = "Select a branch:",
        select_merge = "Select branch to merge:",
        select_delete = "Select branch to delete:",
        confirm_merge = "Do you want to merge branch",
        confirm_delete = "Do you want to delete branch",
        created = "Branch created",
        switched = "Switched to branch",
        merged = "Branch merged",
        deleted = "Branch deleted",
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
        options = {
            pick = "✅ Use commit",
            reword = "📝 Edit message",
            edit = "🔧 Edit commit",
            squash = "🔗 Merge with previous",
            drop = "❌ Remove commit"
        },
        help = {
            pick = "Use commit as is",
            reword = "Use commit but edit the message",
            edit = "Mark commit for editing",
            squash = "Melt into previous commit",
            drop = "Remove the commit"
        },
        title = "📝 Interactive Rebase - Organize Your Commits",
        help_title = "❓ Usage Guide",
        action = {
            pick = "Keep commit as is",
            reword = "Edit commit message",
            edit = "Edit commit content",
            squash = "Merge with previous commit (keep both messages)",
            fixup = "Merge with previous commit (keep only previous message)",
            drop = "Remove this commit",
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
            done = "🎉 All conflicts resolved!",
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
        create = "Create stash",
        apply = "Apply stash",
        pop = "Pop stash",
        drop = "Drop stash",
        list = "Stash list",
        empty = "No stashes available"
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
