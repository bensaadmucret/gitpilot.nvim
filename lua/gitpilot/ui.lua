local i18n = require('gitpilot.i18n')
local M = {}

-- Configuration locale
local config = {}

-- Setup function
M.setup = function(opts)
    config = opts
end

-- Création d'une fenêtre flottante
M.create_floating_window = function(title, content, options)
    options = vim.tbl_extend("force", {
        width = config.ui.window.width,
        height = config.ui.window.height,
        border = config.ui.window.border,
        title = title,
        relative = 'editor',
        row = 3,
        col = 10,
        style = 'minimal'
    }, options or {})

    local buf = vim.api.nvim_create_buf(false, true)
    
    -- Ajouter le contenu
    local lines = type(content) == "table" and content or vim.split(content, "\n")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    
    -- Créer la fenêtre
    local win = vim.api.nvim_open_win(buf, true, {
        relative = options.relative,
        width = options.width,
        height = #lines,
        row = options.row,
        col = options.col,
        style = options.style,
        border = options.border,
        title = options.title,
        title_pos = "center"
    })
    
    -- Appliquer les highlights
    vim.api.nvim_win_set_option(win, 'winhl', 'Normal:GitSimpleNormal,FloatBorder:GitSimpleBorder')
    
    -- Rendre le buffer non modifiable
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    
    return buf, win
end

-- Menu principal
M.show_main_menu = function()
    local menu_items = {
        i18n.t("menu.commit"),
        i18n.t("menu.branch"),
        i18n.t("menu.rebase"),
        i18n.t("menu.conflict"),
        i18n.t("menu.stash"),
        i18n.t("menu.history")
    }
    
    local buf, win = M.create_floating_window(
        i18n.t("select_action"),
        menu_items,
        {
            width = 40,
            height = #menu_items + 2
        }
    )
    
    -- Mappings
    local opts = {buffer = buf, noremap = true, silent = true}
    
    -- Navigation
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #menu_items then
            vim.api.nvim_win_set_cursor(win, {cursor[1] + 1, cursor[2]})
        end
    end, opts)
    
    vim.keymap.set('n', 'k', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] > 1 then
            vim.api.nvim_win_set_cursor(win, {cursor[1] - 1, cursor[2]})
        end
    end, opts)
    
    -- Sélection
    vim.keymap.set('n', '<CR>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local selection = cursor[1]
        
        -- Fermer la fenêtre
        vim.api.nvim_win_close(win, true)
        
        -- Exécuter l'action correspondante
        local actions = {
            [1] = function() M.show_commits_menu() end,
            [2] = function() M.show_branches_menu() end,
            [3] = function() require('gitpilot.commands').interactive_rebase() end,
            [4] = function() require('gitpilot.commands').conflict_resolver() end,
            [5] = function() M.show_stash_menu() end,
            [6] = function() require('gitpilot.commands').visual_history() end
        }
        
        if actions[selection] then
            actions[selection]()
        end
    end, opts)
    
    -- Fermeture
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
    
    -- Aide
    vim.keymap.set('n', '?', function()
        M.show_help()
    end, opts)
end

-- Menu des commits
M.show_commits_menu = function()
    local menu_items = {
        {
            label = i18n.t("menu.create_commit"),
            action = function() require('gitpilot.commands').smart_commit() end
        },
        {
            label = i18n.t("menu.amend_commit"),
            action = function() require('gitpilot.commands').amend_commit() end
        },
        {
            label = i18n.t("menu.history"),
            action = function() require('gitpilot.commands').visual_history() end
        }
    }
    
    local buf, win = M.create_floating_window(
        i18n.t("menu.commits"),
        menu_items,
        {
            width = 40,
            height = #menu_items + 2
        }
    )
    
    -- Mappings
    local opts = {buffer = buf, noremap = true, silent = true}
    
    -- Navigation
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #menu_items then
            vim.api.nvim_win_set_cursor(win, {cursor[1] + 1, cursor[2]})
        end
    end, opts)
    
    vim.keymap.set('n', 'k', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] > 1 then
            vim.api.nvim_win_set_cursor(win, {cursor[1] - 1, cursor[2]})
        end
    end, opts)
    
    -- Sélection
    vim.keymap.set('n', '<CR>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local selection = cursor[1]
        
        -- Fermer la fenêtre
        vim.api.nvim_win_close(win, true)
        
        -- Exécuter l'action correspondante
        if menu_items[selection] and menu_items[selection].action then
            menu_items[selection].action()
        end
    end, opts)
    
    -- Fermeture
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
end

-- Menu des branches
M.show_branches_menu = function()
    local menu_items = {
        {
            label = i18n.t("menu.create_branch"),
            action = function() require('gitpilot.commands').safe_branch_manager() end
        },
        {
            label = i18n.t("menu.switch_branch"),
            action = function() require('gitpilot.commands').safe_branch_manager() end
        },
        {
            label = i18n.t("menu.merge_branch"),
            action = function() require('gitpilot.commands').safe_branch_manager() end
        },
        {
            label = i18n.t("menu.delete_branch"),
            action = function() require('gitpilot.commands').safe_branch_manager() end
        }
    }
    
    local buf, win = M.create_floating_window(
        i18n.t("menu.branches"),
        menu_items,
        {
            width = 40,
            height = #menu_items + 2
        }
    )
    
    -- Mappings
    local opts = {buffer = buf, noremap = true, silent = true}
    
    -- Navigation
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #menu_items then
            vim.api.nvim_win_set_cursor(win, {cursor[1] + 1, cursor[2]})
        end
    end, opts)
    
    vim.keymap.set('n', 'k', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] > 1 then
            vim.api.nvim_win_set_cursor(win, {cursor[1] - 1, cursor[2]})
        end
    end, opts)
    
    -- Sélection
    vim.keymap.set('n', '<CR>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local selection = cursor[1]
        
        -- Fermer la fenêtre
        vim.api.nvim_win_close(win, true)
        
        -- Exécuter l'action correspondante
        if menu_items[selection] and menu_items[selection].action then
            menu_items[selection].action()
        end
    end, opts)
    
    -- Fermeture
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
end

-- Menu du stash
M.show_stash_menu = function()
    local menu_items = {
        {
            label = i18n.t("menu.create_stash"),
            action = function() require('gitpilot.commands').advanced_stash() end
        },
        {
            label = i18n.t("menu.apply_stash"),
            action = function() require('gitpilot.commands').advanced_stash() end
        },
        {
            label = i18n.t("menu.delete_stash"),
            action = function() require('gitpilot.commands').advanced_stash() end
        }
    }
    
    local buf, win = M.create_floating_window(
        i18n.t("menu.stash"),
        menu_items,
        {
            width = 40,
            height = #menu_items + 2
        }
    )
    
    -- Mappings
    local opts = {buffer = buf, noremap = true, silent = true}
    
    -- Navigation
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #menu_items then
            vim.api.nvim_win_set_cursor(win, {cursor[1] + 1, cursor[2]})
        end
    end, opts)
    
    vim.keymap.set('n', 'k', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] > 1 then
            vim.api.nvim_win_set_cursor(win, {cursor[1] - 1, cursor[2]})
        end
    end, opts)
    
    -- Sélection
    vim.keymap.set('n', '<CR>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local selection = cursor[1]
        
        -- Fermer la fenêtre
        vim.api.nvim_win_close(win, true)
        
        -- Exécuter l'action correspondante
        if menu_items[selection] and menu_items[selection].action then
            menu_items[selection].action()
        end
    end, opts)
    
    -- Fermeture
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
end

-- Affichage de l'aide
M.show_help = function()
    local help_content = {
        i18n.t("help.general"),
        "",
        i18n.t("help.keys.navigation"),
        i18n.t("help.keys.select"),
        i18n.t("help.keys.cancel"),
        i18n.t("help.keys.help")
    }
    
    M.create_floating_window(
        "Help",
        help_content,
        {
            width = 50,
            height = #help_content + 2,
            row = 5,
            col = 15
        }
    )
end

-- Confirmation dialog
M.confirm = function(message, callback)
    if not config.ui.confirm_actions then
        callback(true)
        return
    end
    
    local content = {
        message,
        "",
        i18n.t("confirm") .. " (y/n)"
    }
    
    local buf, win = M.create_floating_window(
        i18n.t("warning"),
        content,
        {
            width = 50,
            height = #content + 2
        }
    )
    
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('n', 'y', function()
        vim.api.nvim_win_close(win, true)
        callback(true)
    end, opts)
    
    vim.keymap.set('n', 'n', function()
        vim.api.nvim_win_close(win, true)
        callback(false)
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
        callback(false)
    end, opts)
end

-- Notification
M.notify = function(message, level)
    level = level or "info"
    vim.notify(message, vim.log.levels[string.upper(level)])
end

return M
