local M = {}
local config = {
    ui = {
        window = {
            width = 60,
            height = 20,
            border = 'rounded'
        }
    }
}
local i18n = require('gitpilot.i18n')

M.setup = function(opts)
    if opts then
        if opts.ui then
            if opts.ui.window then
                config.ui.window.width = opts.ui.window.width or config.ui.window.width
                config.ui.window.height = opts.ui.window.height or config.ui.window.height
                config.ui.window.border = opts.ui.window.border or config.ui.window.border
            end
        end
    end
end

-- Fonction de notification
M.notify = function(msg, level)
    level = level or "info"
    -- Map string levels to vim.log.levels
    local level_map = {
        ["error"] = vim.log.levels.ERROR,
        ["warn"] = vim.log.levels.WARN,
        ["info"] = vim.log.levels.INFO,
    }

    -- Store the original string level for testing
    M.last_notification = {
        message = msg,
        level = type(level) == "string" and level or "info"
    }

    -- Convert level to numeric if it's a string
    local numeric_level = type(level) == "string" and level_map[level] or level
    
    vim.notify(msg, numeric_level, {
        title = "GitPilot",
        icon = "🚀"
    })
end

-- Création d'une fenêtre flottante
M.create_floating_window = function(title, lines, opts)
    opts = opts or {}
    local width = opts.width or config.ui.window.width
    local height = opts.height or config.ui.window.height
    local border = opts.border or config.ui.window.border

    -- For testing purposes, return window configuration instead of creating real window
    if vim.env.GITPILOT_TEST then
        return {
            title = title,
            lines = lines,
            width = width,
            height = height,
            border = border
        }
    end

    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    local win_opts = {
        relative = 'editor',
        row = row,
        col = col,
        width = width,
        height = height,
        style = 'minimal',
        border = border
    }
    
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, win_opts)
    
    -- Configuration de la fenêtre
    vim.api.nvim_win_set_option(win, 'winhl', 'Normal:GitSimpleNormal,FloatBorder:GitSimpleBorder')
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    
    -- Ajout du titre et des lignes
    local content = {}
    if title then
        table.insert(content, title)
        table.insert(content, string.rep('-', width - 2))
    end
    
    if lines then
        for _, line in ipairs(lines) do
            table.insert(content, line)
        end
    end
    
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    
    return buf, win
end

-- Show menu in floating window
M.show_menu = function(title, items)
    -- For testing purposes, return menu configuration instead of creating real menu
    if vim.env.GITPILOT_TEST then
        return {
            title = title,
            items = items
        }
    end

    local buf, win = M.create_floating_window(title)
    
    -- Préparation des lignes du menu
    local lines = {}
    for i, item in ipairs(items) do
        table.insert(lines, string.format("%d. %s", i, item.text))
    end
    
    -- Affichage des lignes
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    
    -- Configuration des mappings
    local opts = { noremap = true, silent = true }
    for i, item in ipairs(items) do
        local key = tostring(i)
        vim.api.nvim_buf_set_keymap(buf, 'n', key, '', {
            callback = function()
                vim.api.nvim_win_close(win, true)
                item.handler()
            end,
            noremap = true,
            silent = true
        })
    end
    
    -- Mapping pour fermer le menu
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
        callback = function()
            vim.api.nvim_win_close(win, true)
        end,
        noremap = true,
        silent = true
    })
    
    return buf, win
end

-- Affichage du menu principal
M.show_main_menu = function(items)
    local menu_title = i18n.t("menu.main_title")
    M.show_menu(menu_title, items)
end

-- Affichage du menu des commits
M.show_commits_menu = function()
    local menu_title = i18n.t("menu.commits_title")
    local commit = require('gitpilot.features.commit')
    M.show_menu(menu_title, {
        {
            text = i18n.t("commit.create"),
            handler = function()
                commit.smart_commit()
            end
        },
        {
            text = i18n.t("commit.amend"),
            handler = function()
                commit.amend_commit()
            end
        }
    })
end

-- Affichage du menu des branches
M.show_branches_menu = function()
    local menu_title = i18n.t("menu.branches_title")
    local branch = require('gitpilot.features.branch')
    M.show_menu(menu_title, {
        {
            text = i18n.t("branch.create"),
            handler = function()
                branch.create_branch()
            end
        },
        {
            text = i18n.t("branch.switch"),
            handler = function()
                branch.switch_branch()
            end
        },
        {
            text = i18n.t("branch.delete"),
            handler = function()
                branch.delete_branch()
            end
        },
        {
            text = i18n.t("branch.merge"),
            handler = function()
                branch.merge_branch()
            end
        }
    })
end

-- Affichage du menu des remotes
M.show_remotes_menu = function()
    local menu_title = i18n.t("menu.remotes_title")
    local remote = require('gitpilot.features.remote')
    M.show_menu(menu_title, {
        {
            text = i18n.t("remote.add"),
            handler = function()
                remote.add_remote()
            end
        },
        {
            text = i18n.t("remote.remove"),
            handler = function()
                remote.remove_remote()
            end
        },
        {
            text = i18n.t("remote.push"),
            handler = function()
                remote.push()
            end
        },
        {
            text = i18n.t("remote.pull"),
            handler = function()
                remote.pull()
            end
        }
    })
end

-- Affichage du menu des tags
M.show_tags_menu = function()
    local menu_title = i18n.t("menu.tags_title")
    local tags = require('gitpilot.features.tags')
    M.show_menu(menu_title, {
        {
            text = i18n.t("tag.create"),
            handler = function()
                tags.create_tag()
            end
        },
        {
            text = i18n.t("tag.delete"),
            handler = function()
                tags.delete_tag()
            end
        },
        {
            text = i18n.t("tag.push"),
            handler = function()
                tags.push_tag()
            end
        }
    })
end

-- Affichage du menu du stash
M.show_stash_menu = function()
    local menu_title = i18n.t("menu.stash_title")
    local stash = require('gitpilot.features.stash')
    M.show_menu(menu_title, {
        {
            text = i18n.t("stash.create"),
            handler = function()
                stash.create_stash()
            end
        },
        {
            text = i18n.t("stash.apply"),
            handler = function()
                stash.apply_stash()
            end
        },
        {
            text = i18n.t("stash.delete"),
            handler = function()
                stash.delete_stash()
            end
        }
    })
end

-- Fonction de confirmation
M.confirm = function(message, callback)
    if not config.ui.confirm_actions then
        callback(true)
        return
    end

    local buf, win = M.create_floating_window(i18n.t("confirm"), {
        message,
        "",
        i18n.t("confirm.yes") .. " (y)",
        i18n.t("confirm.no") .. " (n)"
    })

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

-- Fonction d'input
M.input = function(prompt, callback)
    local buf, win = M.create_floating_window(prompt)
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    
    -- Activer le mode insertion
    vim.cmd('startinsert')
    
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('i', '<CR>', function()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local input = table.concat(lines, '\n')
        vim.api.nvim_win_close(win, true)
        callback(input)
    end, opts)
    
    vim.keymap.set('i', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
        callback(nil)
    end, opts)
end

return M
