# Développement & Asynchrone : Bonnes pratiques et contraintes

## Tests asynchrones et compatibilité Neovim

Pour garantir la robustesse des tests asynchrones (callbacks) avec Busted, il est impératif de lancer la suite de tests dans un environnement Neovim headless.

La gestion des upvalues Lua pour les callbacks asynchrones dépend de l’event loop de Neovim. Hors Neovim, certains tests asynchrones peuvent échouer avec l’erreur `attempt to call a nil value (upvalue 'done')`.

### Commande recommandée
```sh
nvim --headless -c 'PlenaryBustedDirectory tests'
```

### Bonnes pratiques du projet
- Les callbacks utilisateurs doivent toujours être propagés tels quels dans le code métier (pas d’enveloppement interne).
- Les tests doivent toujours passer une closure anonyme qui capture `done` : `function(...) done(...) end`
- Le mock asynchrone (`execute_command_async`) doit utiliser `vim.schedule` (ou fallback synchrone pour les environnements hors Neovim).

### Limite connue
Si vous exécutez les tests hors Neovim, certains tests asynchrones peuvent échouer pour des raisons structurelles liées à Lua/Busted.

---

## Check d’environnement conseillé
Ajoutez un check automatique en début de tests pour afficher un avertissement si l’on n’est pas dans Neovim.

---

## Pour toute contribution
Respectez ces règles pour garantir la stabilité et la maintenabilité du projet.
