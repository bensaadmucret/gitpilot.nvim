# 🌟 GitPilot.nvim

Votre copilote Git intelligent pour Neovim - Une interface intuitive et guidée pour gérer Git comme un pro.

## ✨ Caractéristiques

- 🌍 Interface multilingue (Français et Anglais)
- 🎯 Assistant de rebase interactif
- 🔄 Gestion intuitive des branches
- 🚧 Résolution de conflits guidée
- 📦 Gestion avancée des stash
- 📝 Assistant de commit intelligent
- 📊 Visualisation de l'historique

## 📥 Installation

### Avec [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    "bensaadmucret/gitpilot.nvim",
    config = function()
        require("gitpilot").setup({
            language = "fr", -- ou "en" pour l'anglais
            ui = {
                icons = true,
                help = true,
                confirm_actions = true
            }
        })
    end,
}
```

### Avec [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
    'bensaadmucret/gitpilot.nvim',
    config = function()
        require('gitpilot').setup({
            language = "fr", -- ou "en" pour l'anglais
            ui = {
                icons = true,
                help = true,
                confirm_actions = true
            }
        })
    end
}
```

### Avec [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'bensaadmucret/gitpilot.nvim'

" Dans votre init.vim/init.lua, après plug#end():
lua require('gitpilot').setup({
    language = "fr",
    ui = {
        icons = true,
        help = true,
        confirm_actions = true
    }
})
```

## 🎮 Utilisation

Une fois installé, vous pouvez accéder au menu principal avec :
```vim
:GitPilot
```

### Commandes disponibles

- `:GitPilot` - Ouvre le menu principal interactif
- `:GitCommit` - Lance l'assistant de commit
- `:GitBranch` - Ouvre le gestionnaire de branches
- `:GitRebase` - Démarre l'assistant de rebase
- `:GitConflict` - Aide à la résolution des conflits
- `:GitStash` - Gère les stash
- `:GitHistory` - Visualise l'historique

## ⚙️ Configuration

Configuration par défaut :
```lua
require('gitpilot').setup({
    -- Langue (fr ou en)
    language = "en",
    
    -- Options de l'interface utilisateur
    ui = {
        -- Utiliser les icônes
        icons = true,
        -- Afficher l'aide contextuelle
        help = true,
        -- Demander confirmation pour les actions dangereuses
        confirm_actions = true,
        -- Position de la fenêtre flottante
        window = {
            width = 60,
            height = 20,
            border = "rounded"
        }
    },
    
    -- Personnalisation des commandes git
    git = {
        -- Commande git par défaut
        cmd = "git",
        -- Timeout pour les commandes git (en ms)
        timeout = 5000
    }
})
```

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
1. Fork le projet
2. Créer une branche pour votre fonctionnalité
3. Commiter vos changements
4. Pousser vers la branche
5. Ouvrir une Pull Request

## 📝 License

MIT
