local M = {}
local utils = require("gitpilot.utils")
local config = require("gitpilot.config")
local i18n = require("gitpilot.i18n")

-- Configuration par défaut
local default_config = {
    template_directory = vim.fn.stdpath('data') .. '/gitpilot/templates/patches',
    auto_preview = true,
    max_preview_lines = 100,
    patch_format = "unified",
    ignore_whitespace = false
}

-- Configuration actuelle
local current_config = vim.deepcopy(default_config)

-- Configure le module
function M.setup(opts)
    current_config = vim.tbl_deep_extend("force", current_config, opts or {})
    
    -- Crée le répertoire des templates s'il n'existe pas
    if current_config.template_directory then
        vim.fn.mkdir(current_config.template_directory, "p")
    end
end

-- Crée un patch à partir des commits spécifiés
-- @param start_commit: le commit de début (optionnel)
-- @param end_commit: le commit de fin (optionnel)
-- @param output_dir: le répertoire de sortie pour les patches
function M.create_patch(start_commit, end_commit, output_dir)
    local cmd = "git format-patch"
    
    if start_commit and end_commit then
        cmd = cmd .. " " .. start_commit .. ".." .. end_commit
    elseif start_commit then
        cmd = cmd .. " " .. start_commit
    else
        -- Par défaut, crée un patch pour le dernier commit
        cmd = cmd .. " -1"
    end
    
    if output_dir then
        cmd = cmd .. " -o " .. output_dir
    end
    
    local success, result = utils.execute_command(cmd)
    return success, result
end

-- Applique un patch
-- @param patch_file: le chemin vers le fichier patch
-- @param check_only: vérifie seulement si le patch peut être appliqué sans l'appliquer
function M.apply_patch(patch_file, check_only)
    local cmd = "git am"
    
    if check_only then
        cmd = cmd .. " --check"
    end
    
    cmd = cmd .. " " .. patch_file
    
    local success, result = utils.execute_command(cmd)
    return success, result
end

-- Liste les patches dans un répertoire
-- @param directory: le répertoire contenant les patches
function M.list_patches(directory)
    local cmd = "ls -1 " .. (directory or ".") .. "/*.patch"
    local success, result = utils.execute_command(cmd)
    
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
-- @param patch_file: le chemin vers le fichier patch
function M.show_patch(patch_file)
    local cmd = "cat " .. patch_file
    local success, result = utils.execute_command(cmd)
    return success, result
end

-- Vérifie si un patch peut être appliqué
-- @param patch_file: le chemin vers le fichier patch
function M.check_patch(patch_file)
    return M.apply_patch(patch_file, true)
end

return M
