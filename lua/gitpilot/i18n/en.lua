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
        main_title = " GitPilot - Main Menu",
        main = "Main Menu",
        commits = "Commit Operations",
        commits_title = " Commit Management",
        branches = "Branch Operations",
        branches_title = " Branch Management",
        remotes = "Remote Operations",
        remotes_title = " Remote Management",
        tags = "Tag Operations",
        tags_title = " Tag Management",
        stash = "Stash Operations",
        stash_title = " Stash Management",
        search = "Search Operations",
        search_title = " Search",
        rebase = "Rebase Operations",
        rebase_title = " Rebase"
    },

    -- Commit management
    commit = {
        title = " Commit Management",
        create = "Create commit",
        amend = "Amend last commit",
        files = {
            none = "No files to commit",
            select = "Select files to commit:"
        },
        type = {
            select = "Select commit type:",
            feat = "New feature",
            fix = "Bug fix",
            docs = "Documentation",
            style = "Code style",
            refactor = "Code refactoring",
            test = "Tests",
            chore = "Maintenance"
        },
        message = {
            prompt = "Commit message:",
            empty = "Commit message cannot be empty"
        },
        action = {
            success = "Commit created successfully",
            error = "Error creating commit: %s",
            amend_success = "Commit amended successfully",
            amend_error = "Error amending commit: %s"
        }
    },

    -- Branch management
    branch = {
        title = " Branch Management",
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
        switch = {
            title = "Switch Branch",
            prompt = "Select branch:",
            success = "Switched to branch '%s'",
            error = "Error switching branch: %s"
        },
        merge = {
            title = "Merge Branch",
            prompt = "Select branch to merge:",
            success = "Branch '%s' merged successfully",
            error = "Error merging branch: %s"
        }
    },

    -- Remote management
    remote = {
        title = " Remote Management",
        add = "Add remote",
        remove = "Remove remote",
        push = "Push changes",
        pull = "Pull changes",
        none = "No remotes found",
        name = {
            prompt = "Remote name:"
        },
        url = {
            prompt = "Remote URL:"
        },
        added = "Remote added successfully",
        deleted = "Remote deleted",
        fetched = "Remote updated",
        url = "URL",
        tracking_info = "Tracking Information",
        details_title = "Remote Details",
        push = {
            normal = "Normal (default)",
            force = "Force (--force)",
            force_lease = "Force with lease (--force-with-lease)"
        },
        action = {
            success = "Remote operation completed successfully",
            error = "Error performing remote operation: %s"
        }
    },

    -- Tag management
    tag = {
        title = " Tag Management",
        none = "No tags found",
        message = "Message",
        commit_info = "Commit Information",
        details_title = "Tag Details",
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
        title = " Stash Management",
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
        title = " Search",
        prompt = "Enter your search:",
        no_results = "No results found",
        commits = {
            title = "Search in commits",
            prompt = "Enter search term:",
            empty = "Search term cannot be empty",
            none = "No commits found",
            no_results = "No results found for this search",
            details_error = "Error retrieving commit details",
            details_title = "Commit Details %s",
            details = "Details"
        },
        files = {
            prompt = "Enter search pattern:",
            none = "No files found",
            results = "Search Results"
        },
        author = {
            prompt = "Enter author name:",
            none = "No commits found for this author",
            results = "Commits by %s"
        },
        branches = {
            prompt = "Enter search pattern:",
            none = "No branches found",
            results = "Found Branches",
            switched = "Switched to branch"
        }
    }
}
