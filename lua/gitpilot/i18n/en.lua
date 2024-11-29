return {
    -- General messages
    welcome = "Welcome to Git Simple!",
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
        }
    },

    -- Branch manager
    branch = {
        current = "Current branch:",
        create = "Create new branch",
        switch = "Switch branch",
        merge = "Merge branch",
        delete = "Delete branch",
        warning = {
            delete = "⚠️ This action is irreversible",
            unmerged = "⚠️ This branch is not merged"
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
