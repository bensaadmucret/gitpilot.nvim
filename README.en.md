# 🌟 GitPilot.nvim

Your intelligent Git copilot for Neovim - An intuitive and guided interface to manage Git like a pro.

## ✨ Features

- 🌍 Multilingual interface (English and French)
- 🎯 Interactive rebase assistant
- 🔄 Intuitive branch management
- 🚧 Guided conflict resolution
- 📦 Advanced stash management
- 📝 Smart commit assistant
- 📊 History visualization

## 📥 Installation

### With [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    "bensaadmucret/gitpilot.nvim",
    config = function()
        require("gitpilot").setup({
            language = "en", -- or "fr" for French
            ui = {
                icons = true,
                help = true,
                confirm_actions = true
            }
        })
    end,
}
```

### With [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
    'bensaadmucret/gitpilot.nvim',
    config = function()
        require('gitpilot').setup({
            language = "en", -- or "fr" for French
            ui = {
                icons = true,
                help = true,
                confirm_actions = true
            }
        })
    end
}
```

### With [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'bensaadmucret/gitpilot.nvim'

" In your init.vim/init.lua, after plug#end():
lua require('gitpilot').setup({
    language = "en",
    ui = {
        icons = true,
        help = true,
        confirm_actions = true
    }
})
```

## 🎮 Usage

Once installed, you can access the main menu with:
```vim
:GitPilot
```

### Available Commands

- `:GitPilot` - Opens the interactive main menu
- `:GitCommit` - Launches the commit assistant
- `:GitBranch` - Opens the branch manager
- `:GitRebase` - Starts the rebase assistant
- `:GitConflict` - Helps with conflict resolution
- `:GitStash` - Manages stashes
- `:GitHistory` - Visualizes history

## ⚙️ Configuration

Default configuration:
```lua
require('gitpilot').setup({
    -- Language (en or fr)
    language = "en",
    
    -- User interface options
    ui = {
        -- Use icons
        icons = true,
        -- Show contextual help
        help = true,
        -- Ask for confirmation on dangerous actions
        confirm_actions = true,
        -- Floating window position
        window = {
            width = 60,
            height = 20,
            border = "rounded",
            position = "center"
        }
    },
    
    -- Git configuration
    git = {
        -- Auto fetch interval (in minutes)
        auto_fetch = 5,
        -- Show git status in real time
        live_status = true
    }
})
```

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
