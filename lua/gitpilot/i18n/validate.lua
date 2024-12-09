local M = {}

-- Vérifie que toutes les clés existent dans les deux langues
M.validate_translations = function()
    local en = require('gitpilot.i18n.en')
    local fr = require('gitpilot.i18n.fr')
    local missing = {}
    local seen = {}

    local function check_keys(source_table, target_table, target_lang, prefix)
        for key, value in pairs(source_table) do
            local full_key = prefix and (prefix .. "." .. key) or key
            if not seen[full_key] then
                seen[full_key] = true
                if type(value) == "table" then
                    if type(target_table[key]) ~= "table" then
                        table.insert(missing, {lang = target_lang, key = full_key})
                    else
                        check_keys(value, target_table[key], target_lang, full_key)
                    end
                elseif target_table[key] == nil then
                    table.insert(missing, {lang = target_lang, key = full_key})
                end
            end
        end
    end

    -- Vérifier uniquement les clés anglaises dans le français
    check_keys(en, fr, "fr")

    return missing
end

-- Vérifie que les variables sont cohérentes
M.validate_variables = function()
    local en = require('gitpilot.i18n.en')
    local fr = require('gitpilot.i18n.fr')
    local inconsistent = {}

    local function extract_vars(str)
        local vars = {}
        for var in str:gmatch("%%{(.-)%}") do
            vars[var] = true
        end
        return vars
    end

    local function check_vars(en_table, fr_table, prefix)
        for key, value in pairs(en_table) do
            local full_key = prefix and (prefix .. "." .. key) or key
            if type(value) == "string" and type(fr_table[key]) == "string" then
                local en_vars = extract_vars(value)
                local fr_vars = extract_vars(fr_table[key])
                
                -- Vérifier que les variables sont les mêmes
                for var in pairs(en_vars) do
                    if not fr_vars[var] then
                        table.insert(inconsistent, {
                            key = full_key,
                            var = var,
                            en = value,
                            fr = fr_table[key]
                        })
                    end
                end
                for var in pairs(fr_vars) do
                    if not en_vars[var] then
                        table.insert(inconsistent, {
                            key = full_key,
                            var = var,
                            en = value,
                            fr = fr_table[key]
                        })
                    end
                end
            elseif type(value) == "table" and type(fr_table[key]) == "table" then
                check_vars(value, fr_table[key], full_key)
            end
        end
    end

    check_vars(en, fr)
    return inconsistent
end

return M
