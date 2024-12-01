local M = {}
local utils = require('gitpilot.utils')
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')

function M.setup(opts)
    opts = opts or {}
    M.config = vim.tbl_deep_extend('force', {
        git_cmd = 'git',
        timeout = 5000,
        test_mode = false
    }, opts)
end

---Liste tous les tags disponibles
---@return table { success: boolean, output: table, error: string? }
function M.list_tags()
    if vim.env.GITPILOT_TEST == "1" then
        if vim.env.GITPILOT_TEST_NO_RESULTS == "1" then
            return { success = true, output = {} }
        end
        return {
            success = true,
            output = {
                { name = "v1.0.0", hash = "abc1234", message = "Version 1.0.0" },
                { name = "v1.1.0", hash = "def5678", message = "Version 1.1.0" }
            }
        }
    end

    local result = utils.git_command('tag --format="%(refname:short)|%(objectname:short)|%(subject)"')
    if not result then
        return { success = false, error = i18n.t("tag.error.list") }
    end

    local tags = {}
    for line in result:gmatch("[^\r\n]+") do
        local name, hash, message = line:match("([^|]+)|([^|]+)|(.+)")
        if name and hash then
            table.insert(tags, {
                name = name,
                hash = hash,
                message = message or ""
            })
        end
    end
    return { success = true, output = tags }
end

---Crée un nouveau tag
---@param name string Nom du tag
---@param message string? Message associé au tag (optionnel)
---@return table { success: boolean, output: string?, error: string? }
function M.create_tag(name, message)
    if not name or name == "" then
        return { success = false, error = i18n.t("tag.create.invalid_name") }
    end

    if vim.env.GITPILOT_TEST == "1" then
        if vim.env.GITPILOT_TEST_CONFLICTS == "1" then
            return { success = false, error = i18n.t("tag.error.already_exists", { name = name }) }
        end
        return { success = true, output = i18n.t("tag.create.success", { name = name }) }
    end

    local cmd = message and string.format("tag -a %s -m '%s'", name, message) or string.format("tag %s", name)
    local result = utils.git_command(cmd)
    
    if not result or result:match("already exists") then
        return { 
            success = false, 
            error = result and result:match("already exists") and i18n.t("tag.error.already_exists", { name = name }) 
                or i18n.t("tag.error.create")
        }
    end
    
    return { success = true, output = i18n.t("tag.create.success", { name = name }) }
end

---Supprime un tag
---@param name string Nom du tag
---@return table { success: boolean, output: string?, error: string? }
function M.delete_tag(name)
    if not name or name == "" then
        return { success = false, error = i18n.t("tag.delete.invalid_name") }
    end

    if vim.env.GITPILOT_TEST == "1" then
        if vim.env.GITPILOT_TEST_NONEXISTENT == "1" then
            return { success = false, error = i18n.t("tag.error.not_found", { name = name }) }
        end
        return { success = true, output = i18n.t("tag.delete.success", { name = name }) }
    end

    local result = utils.git_command("tag -d " .. name)
    if not result or result:match("not found") then
        return { 
            success = false, 
            error = result and result:match("not found") and i18n.t("tag.error.not_found", { name = name }) 
                or i18n.t("tag.error.delete")
        }
    end

    return { success = true, output = i18n.t("tag.delete.success", { name = name }) }
end

---Pousse les tags vers le remote
---@param name string? Nom du tag spécifique (optionnel)
---@return table { success: boolean, output: string?, error: string? }
function M.push_tags(name)
    if vim.env.GITPILOT_TEST == "1" then
        if vim.env.GITPILOT_TEST_NONEXISTENT == "1" then
            return { success = false, error = i18n.t("tag.error.not_found", { name = name }) }
        end
        return { success = true, output = i18n.t("tag.push.success") }
    end

    if name then
        -- Vérifier si le tag existe avant de le pousser
        local tags = M.list_tags()
        if not tags.success then
            return { success = false, error = i18n.t("tag.error.push") }
        end

        local tag_exists = false
        for _, tag in ipairs(tags.output) do
            if tag.name == name then
                tag_exists = true
                break
            end
        end

        if not tag_exists then
            return { success = false, error = i18n.t("tag.error.not_found", { name = name }) }
        end
    end

    local cmd = name and string.format("push origin %s", name) or "push --tags"
    local result = utils.git_command(cmd)
    
    if not result then
        return { success = false, error = i18n.t("tag.error.push") }
    end

    return { success = true, output = i18n.t("tag.push.success") }
end

---Affiche l'interface utilisateur pour gérer les tags
function M.show_tags_ui()
    local tags = M.list_tags()
    if not tags.success then
        vim.notify(tags.error, vim.log.levels.ERROR)
        return
    end

    ui.show_tags_window(tags.output, {
        create_callback = M.create_tag,
        delete_callback = M.delete_tag,
        push_callback = M.push_tags
    })
end

return M
