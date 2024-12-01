-- Configuration de l'environnement de test
local helpers = require('test.helpers')

-- Configure l'environnement de test initial
helpers.setup()

-- Expose la fonction mock globalement pour faciliter son utilisation dans les tests
_G.mock = helpers.mock

-- Ajoute le chemin de recherche pour les modules
package.path = "./?.lua;./lua/?.lua;./lua/?/init.lua;" .. package.path
