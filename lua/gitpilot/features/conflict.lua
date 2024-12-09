local M = {}
local utils = require("gitpilot.utils")
local config = require("gitpilot.config")

-- Configuration par défaut
local default_config = {
    resolution_dir = vim.fn.stdpath('data') .. '/gitpilot/conflict_resolutions',
    max_saved_resolutions = 10
}

-- Configuration actuelle
local current_config = vim.deepcopy(default_config)

-- Configure le module
function M.setup(opts)
    current_config = vim.tbl_deep_extend("force", current_config, opts or {})
    -- Crée le répertoire de résolutions s'il n'existe pas
    vim.fn.mkdir(current_config.resolution_dir, "p")
end

-- Trouve les fichiers en conflit
function M.find_conflicts()
    local cmd = "git diff --name-only --diff-filter=U"
    local success, result = utils.execute_command(cmd)
    if not success then
        return false, {}
    end
    
    local files = {}
    for file in result:gmatch("[^\r\n]+") do
        table.insert(files, file)
    end
    return true, files
end

-- Obtient le contenu d'un fichier en conflit avec les marqueurs
function M.get_conflict_content(file)
    local fd = vim.loop.fs_open(file, "r", 438)
    if not fd then return nil end
    
    local stat = vim.loop.fs_fstat(fd)
    if not stat then
        vim.loop.fs_close(fd)
        return nil
    end
    
    local content = vim.loop.fs_read(fd, stat.size, 0)
    vim.loop.fs_close(fd)
    return content
end

-- Obtient le contenu d'un fichier en conflit avec les marqueurs
function M.get_conflict_content_with_markers(file)
    local content = M.get_conflict_content(file)
    if not content then
        return false, nil
    end
    
    local conflicts = {}
    local current_conflict = nil
    local line_number = 0
    
    for line in content:gmatch("[^\r\n]+") do
        line_number = line_number + 1
        
        if line:match("^<<<<<<< ") then
            current_conflict = {
                start_line = line_number,
                ours = {},
                theirs = {},
                ours_ref = line:match("^<<<<<<< (.+)"),
                end_line = nil
            }
        elseif line:match("^=======") and current_conflict then
            current_conflict.separator_line = line_number
        elseif line:match("^>>>>>>> ") and current_conflict then
            current_conflict.theirs_ref = line:match("^>>>>>>> (.+)")
            current_conflict.end_line = line_number
            table.insert(conflicts, current_conflict)
            current_conflict = nil
        elseif current_conflict then
            if current_conflict.separator_line then
                table.insert(current_conflict.theirs, line)
            else
                table.insert(current_conflict.ours, line)
            end
        end
    end
    
    return true, {
        content = content,
        conflicts = conflicts
    }
end

-- Résout un conflit spécifique dans un fichier
function M.resolve_conflict(file, resolution, conflict_index)
    local success, data = M.get_conflict_content_with_markers(file)
    if not success then
        return false, "Impossible de lire le fichier"
    end
    
    local content = data.content
    local conflict = data.conflicts[conflict_index]
    if not conflict then
        return false, "Conflit non trouvé"
    end
    
    local new_content
    if resolution == "ours" then
        new_content = table.concat(conflict.ours, "\n")
    elseif resolution == "theirs" then
        new_content = table.concat(conflict.theirs, "\n")
    elseif type(resolution) == "string" then
        new_content = resolution
    else
        return false, "Type de résolution invalide"
    end
    
    -- Remplace le conflit par la résolution
    local before_conflict = content:sub(1, conflict.start_line - 1)
    local after_conflict = content:sub(conflict.end_line + 1)
    local resolved_content = before_conflict .. new_content .. after_conflict
    
    -- Écrit le contenu résolu
    local file_handle = io.open(file, "w")
    if not file_handle then
        return false, "Impossible d'écrire dans le fichier"
    end
    
    file_handle:write(resolved_content)
    file_handle:close()
    
    -- Marque le fichier comme résolu
    local cmd = "git add " .. utils.shell_escape(file)
    local add_success = utils.execute_command(cmd)
    if not add_success then
        return false, "Impossible de marquer le fichier comme résolu"
    end
    
    return true
end

-- Obtient les différences entre deux versions
function M.get_diff(file, ref1, ref2)
    local cmd = string.format("git diff %s %s -- %s",
        utils.shell_escape(ref1),
        utils.shell_escape(ref2),
        utils.shell_escape(file)
    )
    
    local success, result = utils.execute_command(cmd)
    if not success then
        return false, nil
    end
    
    return true, result
end

-- Sauvegarde une résolution pour une utilisation future
function M.save_resolution(file, conflict_hash, resolution)
    local resolution_file = string.format("%s/%s_%s.resolution",
        current_config.resolution_dir,
        file:gsub("/", "_"),
        conflict_hash
    )
    
    local file_handle = io.open(resolution_file, "w")
    if not file_handle then
        return false
    end
    
    file_handle:write(resolution)
    file_handle:close()
    return true
end

-- Récupère une résolution précédente
function M.get_saved_resolution(file, conflict_hash)
    local resolution_file = string.format("%s/%s_%s.resolution",
        current_config.resolution_dir,
        file:gsub("/", "_"),
        conflict_hash
    )
    
    local file_handle = io.open(resolution_file, "r")
    if not file_handle then
        return nil
    end
    
    local resolution = file_handle:read("*all")
    file_handle:close()
    return resolution
end

-- Calcule un hash pour un conflit spécifique
function M.get_conflict_hash(conflict)
    local content = table.concat(conflict.ours, "\n") ..
                   table.concat(conflict.theirs, "\n")
    return vim.fn.sha256(content)
end

-- Obtient une prévisualisation de la résolution
function M.preview_resolution(file, resolution, conflict_index)
    local success, data = M.get_conflict_content_with_markers(file)
    if not success then
        return false, nil
    end
    
    local conflict = data.conflicts[conflict_index]
    if not conflict then
        return false, nil
    end
    
    local preview
    if resolution == "ours" then
        preview = table.concat(conflict.ours, "\n")
    elseif resolution == "theirs" then
        preview = table.concat(conflict.theirs, "\n")
    else
        preview = resolution
    end
    
    return true, preview
end

return M
