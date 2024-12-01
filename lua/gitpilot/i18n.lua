local M = {}

-- Default configuration
local config = {
    locale = "en",
    test_mode = false
}

-- Translations
local translations = {
    en = {
        -- Remote operations
        ["remote.name.prompt"] = "Enter remote name: ",
        ["remote.url.prompt"] = "Enter remote URL: ",
        ["remote.none"] = "No remotes found",
        ["remote.select.remove"] = "Select remote to remove:",
        ["remote.select.push"] = "Select remote to push to:",
        ["remote.select.pull"] = "Select remote to pull from:",
        ["remote.added"] = "Remote added successfully",
        ["remote.removed"] = "Remote removed successfully",
        ["remote.pushed"] = "Successfully pushed to remote",
        ["remote.pulled"] = "Successfully pulled from remote",
        ["remote.fetched"] = "Successfully fetched from remote",
        ["remote.error.exists"] = "Remote already exists",
        ["remote.error.notfound"] = "Remote not found",
        ["remote.error.failed"] = "Remote operation failed",

        -- Confirmation dialogs
        ["confirm"] = "Confirm",
        ["confirm.yes"] = "Yes",
        ["confirm.no"] = "No",
        ["confirm.delete"] = "Are you sure you want to delete this?",
        ["confirm.force"] = "Are you sure you want to force this operation?",

        -- Menu items
        ["menu.branches_title"] = "Git Branches",
        ["menu.remotes_title"] = "Git Remotes",
        ["menu.stashes_title"] = "Git Stashes",
        ["menu.tags_title"] = "Git Tags",

        -- Error messages
        ["error.git_not_found"] = "Git command not found",
        ["error.not_git_repo"] = "Not a git repository",
        ["error.invalid_input"] = "Invalid input",
        ["error.operation_failed"] = "Operation failed",

        -- Success messages
        ["success.operation_complete"] = "Operation completed successfully",
        ["success.changes_saved"] = "Changes saved successfully"
    }
}

-- Setup function
M.setup = function(opts)
    if opts then
        config = vim.tbl_deep_extend('force', config, opts or {})
    end
end

-- Translation function
M.t = function(key)
    -- In test mode, return the key itself
    if config.test_mode then
        return key
    end

    -- Get current locale translations
    local locale = translations[config.locale]
    if not locale then
        return key
    end

    -- Return translation or key if not found
    return locale[key] or key
end

-- Add translations
M.add_translations = function(locale, trans)
    translations[locale] = vim.tbl_deep_extend('force', translations[locale] or {}, trans)
end

-- Get current locale
M.get_locale = function()
    return config.locale
end

-- Set locale
M.set_locale = function(locale)
    if translations[locale] then
        config.locale = locale
        return true
    end
    return false
end

return M
