local M = {}
local utils = require('gitpilot.utils')
local ui = require('gitpilot.ui')

-- Configuration par défaut
local default_config = {
    types = {
        feat = "Nouvelles fonctionnalités",
        fix = "Corrections de bugs",
        docs = "Documentation",
        style = "Changements de style (formatage, espaces, etc.)",
        refactor = "Refactoring du code",
        perf = "Améliorations des performances",
        test = "Ajout ou modification de tests",
        build = "Changements affectant le système de build",
        ci = "Changements de configuration CI",
        chore = "Autres changements"
    },
    max_subject_length = 72,
    max_body_length = 100,
    enforce_conventions = true,
    auto_scope = true
}

-- Configuration actuelle
local current_config = vim.deepcopy(default_config)

-- Configure le module
function M.setup(opts)
    current_config = vim.tbl_deep_extend("force", current_config, opts or {})
    COMMIT_TYPES = current_config.types
end

-- Types de commit selon Conventional Commits
local COMMIT_TYPES = current_config.types

-- Patterns pour détecter le type de changement
local FILE_PATTERNS = {
    test = {
        ["test.*%.lua$"] = true,
        [".*_spec%.lua$"] = true,
    },
    docs = {
        ["README%.md$"] = true,
        ["docs/.*"] = true,
    },
    build = {
        ["Makefile$"] = true,
        ["%.rockspec$"] = true,
    },
    ci = {
        ["%.github/.*"] = true,
        ["%.gitlab%-ci%.yml$"] = true,
    }
}

-- Vérifie si le répertoire courant est un dépôt git
local function is_git_repo()
    local success, _ = utils.execute_command("git rev-parse --is-inside-work-tree")
    return success
end

-- Détecte le type de changement basé sur le nom du fichier
local function detect_change_type(file_path)
    if not file_path then
        return "chore"
    end

    -- Protection contre les caractères spéciaux
    file_path = file_path:gsub("[^%w%./%-_]", "")
    
    for type, patterns in pairs(FILE_PATTERNS) do
        for pattern, _ in pairs(patterns) do
            if file_path:match(pattern) then
                return type
            end
        end
    end
    
    -- Détection basée sur le chemin
    if file_path:match("^lua/.*%.lua$") then
        if file_path:match("/features/") then
            return "feat"
        end
        return "refactor"
    end
    
    return "chore"
end

-- Analyse les fichiers modifiés pour générer un résumé
local function analyze_changes()
    if not is_git_repo() then
        return nil, "Le répertoire courant n'est pas un dépôt git"
    end

    local changes = {}
    local success, status = utils.execute_command("git status --porcelain")
    
    if not success then
        return nil, "Impossible d'obtenir le statut git"
    end

    if status == "" then
        return nil, "Aucun changement à valider"
    end
    
    for line in status:gmatch("[^\r\n]+") do
        local status_code = line:sub(1, 2)
        local file_path = line:sub(4)
        
        -- Vérifie la validité du chemin de fichier
        if not file_path or file_path == "" then
            goto continue
        end

        -- Ignore les fichiers supprimés
        if status_code:match("^%s*D") then
            goto continue
        end
        
        local change_type = detect_change_type(file_path)
        changes[change_type] = changes[change_type] or {}
        table.insert(changes[change_type], file_path)
        
        ::continue::
    end

    -- Vérifie si des changements ont été détectés
    local has_changes = false
    for _, _ in pairs(changes) do
        has_changes = true
        break
    end

    if not has_changes then
        return nil, "Aucun changement valide détecté"
    end
    
    return changes
end

-- Génère un message de commit basé sur les changements
function M.generate_message()
    local changes, err = analyze_changes()
    if not changes then
        ui.show_error(err or "Erreur inconnue lors de l'analyse des changements")
        return nil, err
    end
    
    -- Détermine le type principal de changement
    local primary_type = "chore"
    local type_order = {"feat", "fix", "test", "docs", "refactor", "style", "perf", "build", "ci", "chore"}
    
    for _, type in ipairs(type_order) do
        if changes[type] then
            primary_type = type
            break
        end
    end
    
    -- Construit le message de commit
    local message = primary_type .. ": "
    local details = {}
    
    -- Ajoute un résumé basé sur le type principal
    if primary_type == "feat" then
        message = message .. "Ajout de nouvelles fonctionnalités"
    elseif primary_type == "fix" then
        message = message .. "Correction de bugs"
    elseif primary_type == "test" then
        message = message .. "Ajout/modification de tests"
    elseif primary_type == "docs" then
        message = message .. "Mise à jour de la documentation"
    else
        message = message .. COMMIT_TYPES[primary_type]:lower()
    end
    
    -- Ajoute les détails pour chaque type de changement
    for _, type in ipairs(type_order) do
        if changes[type] and #changes[type] > 0 then
            -- Trie les fichiers pour une meilleure lisibilité
            table.sort(changes[type])
            local files = table.concat(changes[type], ", ")
            -- Nettoie les chemins de fichiers pour plus de clarté
            files = files:gsub("lua/gitpilot/", ""):gsub("%.lua", "")
            table.insert(details, COMMIT_TYPES[type] .. ":\n- " .. files)
        end
    end
    
    if #details > 0 then
        message = message .. "\n\n" .. table.concat(details, "\n\n")
    end
    
    return message
end

return M
