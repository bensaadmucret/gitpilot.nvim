local utils = require('gitpilot.utils')

local M = {}

-- Langue par défaut
local DEFAULT_LANG = 'fr'

-- Langue courante
local current_lang = DEFAULT_LANG

-- Cache pour les traductions
local translations_cache = {}

-- Langues disponibles
local available_langs = {
    en = require('gitpilot.i18n.en'),
    fr = require('gitpilot.i18n.fr')
}

-- Valide une traduction
local function validate_translation(lang, translations)
    if not translations then
        error(string.format("Traductions manquantes pour la langue : %s", lang))
        return false
    end

    -- Vérifie que toutes les clés de la langue par défaut existent
    local default_translations = available_langs[DEFAULT_LANG]
    for key, _ in pairs(default_translations) do
        if translations[key] == nil then
            error(string.format("Clé manquante '%s' dans la langue : %s", key, lang))
            return false
        end
    end

    return true
end

-- Détecte la langue système
function M.get_system_lang()
    local success, locale_output = utils.execute_command('locale', {cache = true})
    if not success then
        return DEFAULT_LANG
    end

    local lang = locale_output:match("LANG=([^%.]+)")
    if not lang then
        return DEFAULT_LANG
    end

    -- Convertit le format locale (ex: "fr_FR") en code de langue (ex: "fr")
    local lang_code = lang:match("^([^_]+)")
    return lang_code and available_langs[lang_code] and lang_code or DEFAULT_LANG
end

-- Définit la langue
function M.set_language(lang)
    if not lang or not available_langs[lang] then
        vim.notify(string.format("Langue non supportée : %s, utilisation de %s", lang, DEFAULT_LANG), vim.log.levels.WARN)
        current_lang = DEFAULT_LANG
        return false
    end

    -- Valide la traduction
    if not validate_translation(lang, available_langs[lang]) then
        current_lang = DEFAULT_LANG
        return false
    end

    current_lang = lang
    return true
end

-- Obtient la langue courante
function M.get_language()
    return current_lang
end

-- Obtient les langues disponibles
function M.get_available_languages()
    local langs = {}
    for lang, _ in pairs(available_langs) do
        table.insert(langs, lang)
    end
    table.sort(langs)
    return langs
end

-- Traduit une clé avec variables optionnelles
function M.t(key, vars)
    if not key then return "" end
    
    -- Utilise le cache si disponible
    local cache_key = key .. (vars and vim.inspect(vars) or "")
    if translations_cache[cache_key] then
        return translations_cache[cache_key]
    end
    
    -- Essaie la langue courante d'abord
    local translation = available_langs[current_lang] and available_langs[current_lang][key]
    
    -- Repli sur la langue par défaut si pas de traduction
    if not translation and current_lang ~= DEFAULT_LANG then
        translation = available_langs[DEFAULT_LANG] and available_langs[DEFAULT_LANG][key]
        if translation then
            vim.notify(string.format("Traduction manquante pour '%s' en %s", key, current_lang), vim.log.levels.DEBUG)
        end
    end
    
    -- Retourne la clé si pas de traduction trouvée
    if not translation then
        vim.notify(string.format("Clé de traduction manquante : %s", key), vim.log.levels.WARN)
        return key
    end
    
    -- Gère la substitution de variables
    if vars then
        translation = translation:gsub("%%{([^}]+)}", function(var)
            if vars[var] == nil then
                vim.notify(string.format("Variable manquante '%s' dans la traduction de '%s'", var, key), vim.log.levels.WARN)
            end
            return tostring(vars[var] or ("%{" .. var .. "}"))
        end)
    end
    
    -- Met en cache la traduction
    translations_cache[cache_key] = translation
    
    return translation
end

-- Nettoie le cache des traductions
function M.clear_cache()
    translations_cache = {}
end

-- Initialise le module
function M.setup(opts)
    opts = opts or {}
    
    -- Réinitialise le cache
    M.clear_cache()
    
    -- Définit la langue initiale
    if opts.language then
        M.set_language(opts.language)
    elseif not utils.is_test_env() then
        -- En environnement non-test, utilise la langue système
        M.set_language(M.get_system_lang())
    else
        -- En environnement de test, utilise le français
        M.set_language('fr')
    end
end

-- Retourne toutes les traductions chargées
function M.get_translations()
    return available_langs[current_lang]
end

return M
