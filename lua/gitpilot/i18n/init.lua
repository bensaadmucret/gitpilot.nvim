local M = {}

local translations = {
    fr = require('gitpilot.i18n.fr'),
    en = require('gitpilot.i18n.en')
}

local current_lang = 'en'  -- Default language

-- Setup function
M.setup = function(opts)
    opts = opts or {}
    if opts.language then
        if translations[opts.language] then
            current_lang = opts.language
        else
            vim.notify(
                string.format("Language '%s' not supported, falling back to English", opts.language),
                vim.log.levels.WARN
            )
            current_lang = 'en'  -- Always fallback to English
        end
    end
end

-- Helper function to get nested value
local function get_nested_value(tbl, key)
    local parts = {}
    for part in key:gmatch("[^.]+") do
        table.insert(parts, part)
    end
    
    local current = tbl
    for _, part in ipairs(parts) do
        if type(current) ~= "table" then
            return nil
        end
        current = current[part]
        if current == nil then
            return nil
        end
    end
    return current
end

-- Translation function with variable substitution
M.t = function(key, vars)
    local function get_translation(lang, k)
        -- First try direct key access
        local direct = translations[lang][k]
        if type(direct) == "string" then
            return direct
        end
        
        -- Then try nested access with branch_actions prefix
        if k:find("^branch%.") then
            local nested_key = k:gsub("^branch%.", "branch_actions.")
            local nested = get_nested_value(translations[lang], nested_key)
            if type(nested) == "string" then
                return nested
            end
        end
        
        -- Finally try normal nested access
        local nested = get_nested_value(translations[lang], k)
        if type(nested) == "string" then
            return nested
        end
        
        return nil
    end

    -- Get translation from current language
    local str = get_translation(current_lang, key)
    
    -- Fallback to English if not found
    if str == nil then
        str = get_translation('en', key)
    end
    
    -- If still not found, return the key
    if str == nil then
        return key
    end
    
    -- Handle variable substitution
    if vars then
        str = str:gsub("%%{([^}]+)}", function(var)
            return vars[var] or ""  -- Return empty string for missing variables
        end)
    end
    
    return str
end

-- Get current language
M.get_language = function()
    return current_lang
end

-- Set language
M.set_language = function(lang)
    if lang and translations[lang] then
        current_lang = lang
        return true
    end
    return false  -- Ne pas changer la langue si invalide
end

-- List available languages (new name)
M.list_languages = function()
    local langs = {}
    for lang, _ in pairs(translations) do
        table.insert(langs, lang)
    end
    return langs
end

-- Get available languages (old name for compatibility)
M.get_available_languages = M.list_languages

return M
