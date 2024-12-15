-- lua/gitpilot/features/help.lua

local M = {}
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')

-- Git command help information
local git_help = {
    commit = {
        title = "Git Commit",
        description = "Create a new commit with your changes",
        usage = "git commit -m \"your message\"",
        common_flags = {
            ["-m"] = "Add commit message",
            ["-a"] = "Commit all modified files",
            ["--amend"] = "Modify the last commit",
        },
        tips = {
            "Write clear and concise commit messages",
            "Use present tense in commit messages",
            "Separate subject from body with a blank line",
        }
    },
    branch = {
        title = "Git Branch",
        description = "Manage branches in your repository",
        usage = "git branch <branch-name>",
        common_flags = {
            ["-d"] = "Delete a branch",
            ["-m"] = "Rename a branch",
            ["-a"] = "List all branches (local and remote)",
        },
        tips = {
            "Use descriptive branch names",
            "Delete merged branches to keep repository clean",
            "Use feature/ or bugfix/ prefixes for clarity",
        }
    },
    stash = {
        title = "Git Stash",
        description = "Temporarily store modified files",
        usage = "git stash",
        common_flags = {
            ["save"] = "Save changes with a message",
            ["pop"] = "Apply and remove latest stash",
            ["apply"] = "Apply but keep the stash",
        },
        tips = {
            "Name your stashes for better organization",
            "Use git stash list to view all stashes",
            "Clean up old stashes regularly",
        }
    },
    rebase = {
        title = "Git Rebase",
        description = "Reapply commits on top of another base",
        usage = "git rebase <base>",
        common_flags = {
            ["-i"] = "Interactive rebase",
            ["--onto"] = "Rebase onto specific branch",
            ["--continue"] = "Continue after resolving conflicts",
        },
        tips = {
            "Don't rebase published branches",
            "Use interactive rebase to clean history",
            "Always create a backup branch before rebasing",
        }
    },
    tag = {
        title = "Git Tag",
        description = "Mark specific points in history",
        usage = "git tag <tag-name>",
        common_flags = {
            ["-a"] = "Create annotated tag",
            ["-d"] = "Delete a tag",
            ["-l"] = "List tags",
        },
        tips = {
            "Use semantic versioning for release tags",
            "Add descriptive messages to annotated tags",
            "Push tags explicitly with git push --tags",
        }
    },
}

function M.show_help(command)
    local help_info = git_help[command]
    if not help_info then
        ui.show_error(i18n.t("help.command_not_found"))
        return
    end

    local content = string.format([[
# %s

%s

## Usage
%s

## Common Flags
%s

## Tips
%s]],
        help_info.title,
        help_info.description,
        help_info.usage,
        format_flags(help_info.common_flags),
        format_tips(help_info.tips)
    )

    ui.float_window(content)
end

function format_flags(flags)
    local formatted_flags = {}
    for flag, desc in pairs(flags) do
        table.insert(formatted_flags, string.format("* %s: %s", flag, desc))
    end
    return table.concat(formatted_flags, "\n")
end

function format_tips(tips)
    local formatted_tips = {}
    for _, tip in ipairs(tips) do
        table.insert(formatted_tips, string.format("* %s", tip))
    end
    return table.concat(formatted_tips, "\n")
end

return M
