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
    -- Ask for the start commit (optional)
    ui.input(i18n.t("patch.create.start_commit"), function(start_commit)
        -- Ask for the end commit (optional)
        ui.input(i18n.t("patch.create.end_commit"), function(end_commit)
            -- Ask for the output directory (optional)
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
    -- List available patches
    local success, patches = patch.list_patches()
    if not success or #patches == 0 then
        ui.error(i18n.t("patch.apply.no_patches"))
        return
    end
    
    -- Create menu items for each patch
    local menu_items = {}
    for _, patch_file in ipairs(patches) do
        table.insert(menu_items, {
            label = patch_file,
            action = function()
                -- Check if the patch can be applied first
                local check_success, check_result = patch.check_patch(patch_file)
                if not check_success then
                    ui.error(i18n.t("patch.apply.check_failed", {error = check_result}))
                    return
                end
                
                -- Apply the patch
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
    
    -- Create menu items for each patch
    local menu_items = {}
    for _, patch_file in ipairs(patches) do
        table.insert(menu_items, {
            label = patch_file,
            action = function()
                -- Show the patch content
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

-- Configure the module
function M.setup(opts)
    current_config = vim.tbl_deep_extend("force", current_config, opts or {})
    
    -- Create templates directory if it doesn't exist
    local template_dir = require("gitpilot.config").get("patch.template_directory")
    if template_dir then
        vim.fn.mkdir(template_dir, "p")
    end
    
    -- Add menu entry for patches
    ui.add_menu_item({
        label = i18n.t("patch.menu.title"),
        description = i18n.t("patch.menu.description"),
        action = show_patch_menu
    })
end

return M
