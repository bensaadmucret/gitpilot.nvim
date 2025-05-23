# GitPilot.nvim

## ⚠️ Limitation connue

La suite de tests `tests/features/tag_spec.lua` ne passe pas actuellement en raison d'un déséquilibre dans la fermeture des blocs `describe`/`it` (erreur : `<eof> expected near 'end'`).

Merci de corriger la structure des tests avant d'utiliser `busted` pour la validation automatisée.

[![Test](https://github.com/bensaadmucret/gitpilot.nvim/actions/workflows/test.yml/badge.svg)](https://github.com/bensaadmucret/gitpilot.nvim/actions/workflows/test.yml)
[![Coverage Status](https://coveralls.io/repos/github/bensaadmucret/gitpilot.nvim/badge.svg?branch=main)](https://coveralls.io/github/bensaadmucret/gitpilot.nvim?branch=main)
[![Neovim v0.5.0+](https://img.shields.io/badge/Neovim-v0.5.0+-blueviolet.svg)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Lua-5.1-blue.svg)](https://lua.org)

Un plugin Neovim puissant pour la gestion Git avec support multilingue (Français/Anglais).

## ✨ Fonctionnalités

- 🌍 Interface entièrement bilingue (Français/Anglais)
- 🎯 Navigation intuitive avec j/k
- 💡 Aide contextuelle
- ⚡ Performances optimisées
- 🔄 Actualisation automatique

### Gestion des Commits
- 📝 Sélection multiple de fichiers
- 🏷️ Types de commit avec emojis
- 👀 Prévisualisation des changements
- 📋 Messages de commit guidés

### Gestion des Branches
- ➕ Création de branches
- 🔄 Changement de branche
- 🔗 Fusion de branches
- ❌ Suppression de branches

### Gestion des Tags
- 📋 Liste des tags
- ✨ Création de tags (légers et annotés)
- 🗑️ Suppression de tags
- ⬆️ Push des tags

### Gestion des Remotes
- 📋 Liste des remotes
- ➕ Ajout de remotes
- ❌ Suppression de remotes
- ⬇️ Fetch sélectif
- ⬆️ Options de push avancées

### Gestion du Stash
- 💾 Création sélective de stash
- 📋 Liste des stash
- ↩️ Application de stash avec options
- 🗑️ Suppression de stash

### Recherche et Navigation
- 🔍 Recherche dans les commits
- 📂 Recherche de fichiers
- 👤 Recherche par auteur
- 🌿 Filtrage des branches

### Rebase Interactif
- 📝 Réorganisation des commits
- ✏️ Modification des actions (pick, reword, edit, squash, fixup, drop)
- 🔄 Résolution des conflits
- 👀 Prévisualisation des changements

## 🧪 Tests et Environnement requis

> **Note sur les tests asynchrones :**
>
> Les tests automatisés liés à l'exécution asynchrone (notamment `async.lua` et `execute_command_async`) nécessitent d'être lancés dans un environnement Neovim (présence de `vim.loop` ou `vim.fn.system`).
> 
> - En CI classique ou dans un shell Lua, ces tests sont automatiquement ignorés (skip) pour éviter les faux négatifs.
> - Pour valider l'asynchrone en conditions réelles, exécutez les tests dans une session Neovim avec un runner adapté (ex : [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)).
>
> **Exemple de lancement sous Neovim :**
> ```vim
> :PlenaryBustedDirectory tests/features/
> ```

## 📦 Installation

### Avec [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    "bensaadmucret/gitpilot.nvim",
    config = function()
        require("gitpilot").setup({
            language = "fr",  -- ou "en" pour l'anglais
            ui = {
                icons = true,
                help = true,
                confirm_actions = true,
                window = {
                    width = 60,
                    height = 20,
                    border = "rounded"
                }
            },
            git = {
                cmd = "git",
                timeout = 5000
            }
        })
    end,
}
```

### Avec [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
    "bensaadmucret/gitpilot.nvim",
    config = function()
        require("gitpilot").setup({
            language = "fr",
            -- autres options...
        })
    end
}
```

## 🚀 Commandes

- `:GitPilot` - Ouvre le menu principal
- `:GitCommit` - Assistant de commit
- `:GitBranchCreate` - Créer une nouvelle branche
- `:GitBranchSwitch` - Changer de branche
- `:GitBranchMerge` - Fusionner une branche
- `:GitBranchDelete` - Supprimer une branche
- `:GitRebase` - Assistant de rebase interactif
- `:GitConflict` - Résolution de conflits
- `:GitStash` - Gestion du stash
- `:GitHistory` - Visualisation de l'historique

## ⌨️ Raccourcis Clavier

Dans les menus :
- `j/k` - Navigation
- `Enter` - Sélection
- `q/Esc` - Fermer
- `?` - Aide

## 🔧 Configuration

```lua
require("gitpilot").setup({
    -- Langue (fr ou en)
    language = "fr",
    
    -- Interface utilisateur
    ui = {
        -- Activer les icônes
        icons = true,
        -- Afficher l'aide
        help = true,
        -- Confirmer les actions dangereuses
        confirm_actions = true,
        -- Configuration des fenêtres
        window = {
            width = 60,
            height = 20,
            border = "rounded"
        }
    },
    
    -- Configuration Git
    git = {
        -- Commande Git à utiliser
        cmd = "git",
        -- Timeout des commandes en ms
        timeout = 5000
    }
})
```

## 📝 License

MIT

## 👥 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
1. Fork le projet
2. Créer une branche pour votre fonctionnalité
3. Commiter vos changements
4. Pousser vers la branche
5. Ouvrir une Pull Request
