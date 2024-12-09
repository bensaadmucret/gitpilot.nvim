#!/usr/bin/env lua

-- Ajouter le répertoire lua au path de recherche
package.path = package.path .. ";./lua/?.lua"

local validate = require('gitpilot.i18n.validate')
local en = require('gitpilot.i18n.fr')

-- Obtenir les clés manquantes
local missing = validate.validate_translations()

-- Trier les clés manquantes par ordre alphabétique
table.sort(missing, function(a, b) return a.key < b.key end)

-- Générer le code pour les clés manquantes
print("-- Clés manquantes à ajouter dans fr.lua :")
print("")
for _, item in ipairs(missing) do
    if item.lang == "fr" then
        -- Récupérer la valeur en anglais
        local en_value = require('gitpilot.i18n.en')[item.key]
        if en_value then
            print(string.format('    ["%s"] = "%s",', item.key, en_value))
        end
    end
end
