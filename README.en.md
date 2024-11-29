# GitPilot.nvim

A powerful Neovim Git management plugin with multilingual support (English/French).

## ✨ Features

- 🌍 Fully bilingual interface (English/French)
- 🎯 Intuitive navigation with j/k
- 💡 Contextual help
- ⚡ Optimized performance
- 🔄 Automatic refresh

### Commit Management
- 📝 Multiple file selection
- 🏷️ Commit types with emojis
- 👀 Changes preview
- 📋 Guided commit messages

### Branch Management
- ➕ Create branches
- 🔄 Switch branches
- 🔗 Merge branches
- ❌ Delete branches

### Tag Management
- 📋 List tags
- ✨ Create tags (lightweight and annotated)
- 🗑️ Delete tags
- ⬆️ Push tags

### Remote Management
- 📋 List remotes
- ➕ Add remotes
- ❌ Remove remotes
- ⬇️ Selective fetch
- ⬆️ Advanced push options

### Stash Management
- 💾 Selective stash creation
- 📋 List stashes
- ↩️ Apply stash with options
- 🗑️ Delete stash

### Search and Navigation
- 🔍 Search commits
- 📂 Find files
- 👤 Search by author
- 🌿 Filter branches

### Interactive Rebase
- 📝 Reorder commits
- ✏️ Change actions (pick, reword, edit, squash, fixup, drop)
- 🔄 Resolve conflicts
- 👀 Preview changes

## 📦 Installation

### With [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    "bensaadmucret/gitpilot.nvim",
    config = function()
        require("gitpilot").setup({
            language = "en",  -- or "fr" for French
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

### With [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
    "bensaadmucret/gitpilot.nvim",
    config = function()
        require("gitpilot").setup({
            language = "en",
            -- other options...
        })
    end
}
```

## 🚀 Commands

- `:GitPilot` - Open main menu
- `:GitCommit` - Commit assistant
- `:GitBranchCreate` - Create a new branch
- `:GitBranchSwitch` - Switch branch
- `:GitBranchMerge` - Merge branch
- `:GitBranchDelete` - Delete branch
- `:GitRebase` - Interactive rebase assistant
- `:GitConflict` - Conflict resolution
- `:GitStash` - Stash management
- `:GitHistory` - History visualization

## ⌨️ Keyboard Shortcuts

In menus:
- `j/k` - Navigation
- `Enter` - Selection
- `q/Esc` - Close
- `?` - Help

## 🔧 Configuration

```lua
require("gitpilot").setup({
    -- Language (en or fr)
    language = "en",
    
    -- User interface
    ui = {
        -- Enable icons
        icons = true,
        -- Show help
        help = true,
        -- Confirm dangerous actions
        confirm_actions = true,
        -- Window configuration
        window = {
            width = 60,
            height = 20,
            border = "rounded"
        }
    },
    
    -- Git configuration
    git = {
        -- Git command to use
        cmd = "git",
        -- Command timeout in ms
        timeout = 5000
    }
})
```

## 📝 License

MIT

## 👥 Contributing

Contributions are welcome! Feel free to:
1. Fork the project
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request
