local M = {}
local conflict = require("gitpilot.features.conflict")
local ui = require("gitpilot.ui")
local i18n = require("gitpilot.i18n")
local config = require("gitpilot.config")

-- Configuration par défaut
local default_config = {
    window = {
        width = 0.8,
        height = 0.8,
        border = "rounded"
    },
    highlight = {
        ours = "DiffAdd",
        theirs = "DiffDelete",
        marker = "DiffChange"
    }
}

-- Configuration actuelle
local current_config = vim.deepcopy(default_config)

-- Configure le module
function M.setup(opts)
    current_config = vim.tbl_deep_extend("force", current_config, opts or {})
    
    -- Configure le module de conflit
    conflict.setup({
        resolution_dir = config.get("conflict.resolution_dir"),
        max_saved_resolutions = config.get("conflict.max_saved_resolutions") or 10
    })
    
    -- Ajoute l'entrée de menu pour la gestion des conflits
    ui.add_menu_item({
        label = i18n.t("conflict.menu.title"),
        description = i18n.t("conflict.menu.description"),
        action = M.show_conflicts_menu
    })
end

-- Formate l'affichage d'un conflit
local function format_conflict_display(file_content, current_conflict)
    local lines = {}
    
    -- En-tête
    table.insert(lines, i18n.t("conflict.section.ours", {ref = current_conflict.ours_ref}))
    table.insert(lines, string.rep("-", 40))
    
    -- Notre version
    for _, line in ipairs(current_conflict.ours) do
        table.insert(lines, "  " .. line)
    end
    
    table.insert(lines, "")
    table.insert(lines, i18n.t("conflict.section.theirs", {ref = current_conflict.theirs_ref}))
    table.insert(lines, string.rep("-", 40))
    
    -- Leur version
    for _, line in ipairs(current_conflict.theirs) do
        table.insert(lines, "  " .. line)
    end
    
    return table.concat(lines, "\n")
end

-- Affiche le menu de résolution pour un conflit spécifique
local function show_resolution_menu(file, conflict_index, data)
    local current_conflict = data.conflicts[conflict_index]
    
    -- Vérifie s'il existe une résolution précédente
    local conflict_hash = conflict.get_conflict_hash(current_conflict)
    local saved_resolution = conflict.get_saved_resolution(file, conflict_hash)
    
    local menu_items = {
        {
            label = i18n.t("conflict.resolve.use_ours"),
            description = i18n.t("conflict.resolve.use_ours_desc"),
            action = function()
                local success = conflict.resolve_conflict(file, "ours", conflict_index)
                if success then
                    ui.info(i18n.t("conflict.resolve.success"))
                else
                    ui.error(i18n.t("conflict.resolve.error"))
                end
            end
        },
        {
            label = i18n.t("conflict.resolve.use_theirs"),
            description = i18n.t("conflict.resolve.use_theirs_desc"),
            action = function()
                local success = conflict.resolve_conflict(file, "theirs", conflict_index)
                if success then
                    ui.info(i18n.t("conflict.resolve.success"))
                else
                    ui.error(i18n.t("conflict.resolve.error"))
                end
            end
        },
        {
            label = i18n.t("conflict.resolve.manual"),
            description = i18n.t("conflict.resolve.manual_desc"),
            action = function()
                ui.input(i18n.t("conflict.resolve.manual_prompt"), function(resolution)
                    if resolution == "" then
                        ui.error(i18n.t("conflict.resolve.manual_empty"))
                        return
                    end
                    
                    local success = conflict.resolve_conflict(file, resolution, conflict_index)
                    if success then
                        -- Sauvegarde la résolution pour une utilisation future
                        conflict.save_resolution(file, conflict_hash, resolution)
                        ui.info(i18n.t("conflict.resolve.success"))
                    else
                        ui.error(i18n.t("conflict.resolve.error"))
                    end
                end)
            end
        },
        {
            label = i18n.t("conflict.resolve.preview_diff"),
            description = i18n.t("conflict.resolve.preview_diff_desc"),
            action = function()
                local success, diff = conflict.get_diff(file, current_conflict.ours_ref, current_conflict.theirs_ref)
                if success then
                    ui.show_text(diff)
                else
                    ui.error(i18n.t("conflict.diff.error"))
                end
            end
        }
    }
    
    -- Ajoute l'option de résolution précédente si disponible
    if saved_resolution then
        table.insert(menu_items, 1, {
            label = i18n.t("conflict.resolve.use_previous"),
            description = i18n.t("conflict.resolve.use_previous_desc"),
            action = function()
                local success = conflict.resolve_conflict(file, saved_resolution, conflict_index)
                if success then
                    ui.info(i18n.t("conflict.resolve.success"))
                else
                    ui.error(i18n.t("conflict.resolve.error"))
                end
            end
        })
    end
    
    ui.show_text(format_conflict_display(data.content, current_conflict))
    ui.show_menu(i18n.t("conflict.resolve.title"), menu_items)
end

-- Affiche la liste des conflits dans un fichier
local function show_file_conflicts(file)
    local success, data = conflict.get_conflict_content(file)
    if not success then
        ui.error(i18n.t("conflict.read.error"))
        return
    end
    
    if #data.conflicts == 0 then
        ui.info(i18n.t("conflict.none_found"))
        return
    end
    
    local menu_items = {}
    for i, conflict_data in ipairs(data.conflicts) do
        table.insert(menu_items, {
            label = i18n.t("conflict.item", {
                number = i,
                start = conflict_data.start_line,
                end_line = conflict_data.end_line
            }),
            action = function()
                show_resolution_menu(file, i, data)
            end
        })
    end
    
    ui.show_menu(i18n.t("conflict.list.title"), menu_items)
end

function M.show_conflicts_menu()
    local success, files = conflict.find_conflicts()
    if not success then
        ui.error(i18n.t("conflict.search.error"))
        return
    end
    
    if #files == 0 then
        ui.info(i18n.t("conflict.none_found"))
        return
    end
    
    local menu_items = {}
    for _, file in ipairs(files) do
        table.insert(menu_items, {
            label = file,
            action = function()
                show_file_conflicts(file)
            end
        })
    end
    
    ui.show_menu(i18n.t("conflict.files.title"), menu_items)
end

return M
