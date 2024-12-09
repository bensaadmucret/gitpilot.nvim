#!/usr/bin/env lua

-- Ajouter le répertoire lua au path de recherche
package.path = package.path .. ";./lua/?.lua"

local validate = require('gitpilot.i18n.validate')

print("Validating translations...")
local missing = validate.validate_translations()
if #missing > 0 then
    print("\nMissing translations:")
    for _, item in ipairs(missing) do
        print(string.format("Language %s missing key: %s", item.lang, item.key))
    end
else
    print("✓ All translations are present")
end

print("\nValidating variables...")
local inconsistent = validate.validate_variables()
if #inconsistent > 0 then
    print("\nInconsistent variables:")
    for _, item in ipairs(inconsistent) do
        print(string.format("\nKey: %s", item.key))
        print(string.format("Variable: %s", item.var))
        print(string.format("EN: %s", item.en))
        print(string.format("FR: %s", item.fr))
    end
else
    print("✓ All variables are consistent")
end
