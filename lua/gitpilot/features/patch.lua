local M = {}
local utils = require("gitpilot.utils")
local config = require("gitpilot.config")
local i18n = require("gitpilot.i18n")

-- Configuration par défaut
local default_config = {
    template_directory = "",  -- Sera initialisé dans setup
    auto_preview = true,
    max_preview_lines = 100,
    patch_format = "unified",
    ignore_whitespace = false
}

-- Configuration actuelle
local current_config = default_config

-- Configure le module
function M.setup(opts)
    -- Dans un environnement de test, utilise un répertoire temporaire
    if not vim then
        default_config.template_directory = "/tmp/gitpilot/templates/patches"
    else
        default_config.template_directory = vim.fn.stdpath('data') .. '/gitpilot/templates/patches'
    end

    -- Fusionne les options avec la configuration par défaut
    current_config = vim and vim.tbl_deep_extend("force", vim.deepcopy(default_config), opts or {}) or default_config

    -- Crée le répertoire des templates s'il n'existe pas
    local template_dir = opts and opts.template_directory or current_config.template_directory
    if template_dir and template_dir ~= "" then
        local mkdir_cmd = string.format("mkdir -p %s", template_dir)
        utils.run_command(mkdir_cmd)
    end
end

-- Crée un patch à partir des commits spécifiés
function M.create_patch(start_commit, end_commit, output_dir)
    local cmd = "git format-patch"
    
    if start_commit and end_commit then
        cmd = cmd .. " " .. start_commit .. ".." .. end_commit
    elseif start_commit then
        cmd = cmd .. " -1 " .. start_commit
    else
        cmd = cmd .. " -1 HEAD"
    end
    
    if output_dir then
        cmd = cmd .. " -o " .. output_dir
    end
    
    local success, result = utils.run_command(cmd)
    return success, result
end

-- Applique un patch
function M.apply_patch(patch_file)
    if not patch_file then
        return false, i18n.t("patch.error.no_patch_file")
    end
    
    local cmd = "git apply"
    
    cmd = cmd .. " " .. patch_file
    
    local success, result = utils.run_command(cmd)
    return success, result
end

-- Liste les patches disponibles
function M.list_patches(directory)
    local cmd = "ls -1 " .. (directory or ".") .. "/*.patch"
    local success, result = utils.run_command(cmd)
    
    if not success then
        return false, {}
    end
    
    local patches = {}
    for patch in result:gmatch("[^\r\n]+") do
        table.insert(patches, patch)
    end
    
    return true, patches
end

-- Affiche le contenu d'un patch
function M.show_patch(patch_file)
    local cmd = "cat " .. patch_file
    local success, result = utils.run_command(cmd)
    return success, result
end

return M
