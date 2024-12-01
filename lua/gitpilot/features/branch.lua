local M = {}

-- Configuration par défaut
local config = {
    git = {
        cmd = 'git',
        timeout = 5000,
        test_mode = false
    }
}

-- Modules requis
local function get_deps()
    return {
        utils = require('gitpilot.utils'),
        ui = require('gitpilot.ui'),
        i18n = require('gitpilot.i18n')
    }
end

-- Configure le module
M.setup = function(opts)
    if opts then
        config = vim.tbl_deep_extend('force', config, opts or {})
    end
end

-- Liste toutes les branches
M.list_branches = function()
    local deps = get_deps()
    -- En mode test, on simule une liste de branches
    if config.git.test_mode then
        if vim.env.GITPILOT_TEST_NONEXISTENT == "1" then
            return {
                success = true,
                output = {"main", "develop"}
            }
        end
        return {
            success = true,
            output = {"main", "develop", "feature/test", "feature/test-switch"}
        }
    end

    local success, output = pcall(deps.utils.git_command, 'branch')
    if not success or not output then
        return {
            success = false,
            error = deps.i18n.t("branch.error.list"),
            output = {}
        }
    end
    
    local branches = {}
    for line in output:gmatch("[^\r\n]+") do
        local branch = line:gsub("^%s*%*?%s*", "")
        table.insert(branches, branch)
    end
    return {
        success = true,
        output = branches
    }
end

-- Créer une nouvelle branche
M.create_branch = function(branch_name)
    local deps = get_deps()
    if not branch_name or branch_name == "" then
        return {
            success = false,
            error = deps.i18n.t("branch.create.invalid_name")
        }
    end

    -- En mode test, on simule un conflit si demandé
    if config.git.test_mode and vim.env.GITPILOT_TEST_CONFLICTS == "1" then
        return {
            success = false,
            error = deps.i18n.t("branch.error.already_exists")
        }
    end

    local success, output = pcall(deps.utils.git_command, 'branch ' .. branch_name)
    if not success then
        return {
            success = false,
            error = deps.i18n.t("branch.create.error", { name = branch_name })
        }
    end

    return {
        success = true,
        output = deps.i18n.t("branch.create.success", { name = branch_name })
    }
end

-- Supprime une branche
M.delete_branch = function(branch_name)
    local deps = get_deps()
    if not branch_name or branch_name == "" then
        return {
            success = false,
            error = deps.i18n.t("branch.delete.invalid_name")
        }
    end

    -- Vérifie si la branche existe
    local exists = false
    local branches = M.list_branches().output
    for _, branch in ipairs(branches) do
        if branch == branch_name then
            exists = true
            break
        end
    end

    if not exists then
        return {
            success = false,
            error = deps.i18n.t("branch.error.not_found", { name = branch_name })
        }
    end

    local success, output = pcall(deps.utils.git_command, 'branch -D ' .. branch_name)
    if not success then
        return {
            success = false,
            error = deps.i18n.t("branch.delete.error", { name = branch_name })
        }
    end

    return {
        success = true,
        output = deps.i18n.t("branch.delete.success", { name = branch_name })
    }
end

-- Change de branche
M.switch_branch = function(branch_name)
    local deps = get_deps()
    if not branch_name or branch_name == "" then
        return {
            success = false,
            error = deps.i18n.t("branch.switch.invalid_name")
        }
    end

    -- Vérifie si la branche existe
    local exists = false
    local branches = M.list_branches().output
    for _, branch in ipairs(branches) do
        if branch == branch_name then
            exists = true
            break
        end
    end

    if not exists then
        return {
            success = false,
            error = deps.i18n.t("branch.error.not_found", { name = branch_name })
        }
    end

    local success, output = pcall(deps.utils.git_command, 'checkout ' .. branch_name)
    if not success then
        return {
            success = false,
            error = deps.i18n.t("branch.switch.error", { name = branch_name })
        }
    end

    return {
        success = true,
        output = deps.i18n.t("branch.switch.success", { name = branch_name })
    }
end

return M
