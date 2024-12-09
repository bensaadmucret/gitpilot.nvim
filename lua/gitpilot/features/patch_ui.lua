local M = {}
local patch = require("gitpilot.features.patch")
local ui = require("gitpilot.ui")
local i18n = require("gitpilot.i18n")
local utils = require("gitpilot.utils")

local function show_patch_menu()
    local menu_items = {
        {
            label = i18n.t("patch.create.title"),
            description = i18n.t("patch.create.description"),
            action = M.create_patch_menu
        },
        {
            label = i18n.t("patch.apply.title"),
            description = i18n.t("patch.apply.description"),
            action = M.apply_patch_menu
        },
        {
            label = i18n.t("patch.list.title"),
            description = i18n.t("patch.list.description"),
            action = M.list_patches_menu
        }
    }
    
    ui.show_menu(i18n.t("patch.menu.title"), menu_items)
end

function M.create_patch_menu()
    -- Demande le commit de début (optionnel)
    ui.input(i18n.t("patch.create.start_commit"), function(start_commit)
        -- Demande le commit de fin (optionnel)
        ui.input(i18n.t("patch.create.end_commit"), function(end_commit)
            -- Demande le répertoire de sortie (optionnel)
            ui.input(i18n.t("patch.create.output_dir"), function(output_dir)
                local success, result = patch.create_patch(
                    start_commit ~= "" and start_commit or nil,
                    end_commit ~= "" and end_commit or nil,
                    output_dir ~= "" and output_dir or nil
                )
                
                if success then
                    ui.info(i18n.t("patch.create.success", {files = result}))
                else
                    ui.error(i18n.t("patch.create.error", {error = result}))
                end
            end)
        end)
    end)
end

function M.apply_patch_menu()
    -- Liste les patches disponibles
    local success, patches = patch.list_patches()
    if not success or #patches == 0 then
        ui.error(i18n.t("patch.apply.no_patches"))
        return
    end
    
    -- Crée les éléments du menu pour chaque patch
    local menu_items = {}
    for _, patch_file in ipairs(patches) do
        table.insert(menu_items, {
            label = patch_file,
            action = function()
                -- Vérifie d'abord si le patch peut être appliqué
                local check_success, check_result = patch.check_patch(patch_file)
                if not check_success then
                    ui.error(i18n.t("patch.apply.check_failed", {error = check_result}))
                    return
                end
                
                -- Applique le patch
                local apply_success, apply_result = patch.apply_patch(patch_file)
                if apply_success then
                    ui.info(i18n.t("patch.apply.success"))
                else
                    ui.error(i18n.t("patch.apply.error", {error = apply_result}))
                end
            end
        })
    end
    
    ui.show_menu(i18n.t("patch.apply.select"), menu_items)
end

function M.list_patches_menu()
    local success, patches = patch.list_patches()
    if not success or #patches == 0 then
        ui.info(i18n.t("patch.list.empty"))
        return
    end
    
    -- Crée les éléments du menu pour chaque patch
    local menu_items = {}
    for _, patch_file in ipairs(patches) do
        table.insert(menu_items, {
            label = patch_file,
            action = function()
                -- Affiche le contenu du patch
                local show_success, content = patch.show_patch(patch_file)
                if show_success then
                    ui.info(content)
                else
                    ui.error(i18n.t("patch.show.error", {error = content}))
                end
            end
        })
    end
    
    ui.show_menu(i18n.t("patch.list.title"), menu_items)
end

-- Configuration du module
function M.setup()
    -- Crée le répertoire de patches s'il n'existe pas
    local patch_dir = require("gitpilot.config").get("patch.directory")
    if patch_dir then
        vim.fn.mkdir(patch_dir, "p")
    end
    
    -- Crée le répertoire de templates s'il n'existe pas
    local template_dir = require("gitpilot.config").get("patch.template_directory")
    if template_dir then
        vim.fn.mkdir(template_dir, "p")
    end
    
    -- Ajoute l'entrée de menu pour les patches
    ui.add_menu_item({
        label = i18n.t("patch.menu.title"),
        description = i18n.t("patch.menu.description"),
        action = show_patch_menu
    })
end

return M
