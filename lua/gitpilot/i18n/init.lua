local M = {}

local translations = {
    fr = require('gitpilot.i18n.fr'),
    en = require('gitpilot.i18n.en')
}

local current_lang = 'en'  -- Default language

-- Setup function
M.setup = function(opts)
    if opts.language then
        if translations[opts.language] then
            current_lang = opts.language
        else
            vim.notify(
                string.format("Language '%s' not supported, falling back to English", opts.language),
                vim.log.levels.WARN
            )
        end
    else
        -- Try to detect system language
        local sys_lang = os.getenv("LANG") or ""
        if sys_lang:match("^fr") then
            current_lang = "fr"
        end
    end
end

-- Translation function with variable substitution
M.t = function(key, vars)
    local lang_table = translations[current_lang]
    
    -- Split the key by dots to access nested tables
    local result = lang_table
    for k in string.gmatch(key, "[^.]+") do
        if type(result) ~= "table" then
            result = translations['en'][key] or key
            break
        end
        result = result[k]
    end
    
    -- Get the translation string
    local str = result or translations['en'][key] or key
    
    -- If we have variables to substitute
    if vars then
        str = str:gsub("%%{(.-)}", function(var)
            return vars[var] or ""
        end)
    end
    
    return str
end

-- Get current language
M.get_language = function()
    return current_lang
end

-- Change language
M.set_language = function(lang)
    if translations[lang] then
        current_lang = lang
        return true
    end
    return false
end

-- Get available languages
M.get_available_languages = function()
    local langs = {}
    for lang, _ in pairs(translations) do
        table.insert(langs, lang)
    end
    return langs
end

return M
