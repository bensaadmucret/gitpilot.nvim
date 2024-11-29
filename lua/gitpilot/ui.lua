local M = {}
local config = {}
local i18n = require('gitpilot.i18n')

M.setup = function(opts)
    config = opts
end

-- Création d'une fenêtre flottante
local function create_float_window(title)
    local width = config.ui.window.width
    local height = config.ui.window.height
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    local opts = {
        relative = 'editor',
        row = row,
        col = col,
        width = width,
        height = height,
        style = 'minimal',
        border = config.ui.window.border
    }
    
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, opts)
    
    -- Configuration de la fenêtre
    vim.api.nvim_win_set_option(win, 'winhl', 'Normal:GitSimpleNormal,FloatBorder:GitSimpleBorder')
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    
    -- Ajout du titre
    if title then
        vim.api.nvim_buf_set_option(buf, 'modifiable', true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {title, string.rep('-', width - 2)})
        vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    end
    
    return buf, win
end

-- Affichage d'un menu
local function show_menu(title, items)
    local buf, win = create_float_window(title)
    
    -- Préparation des lignes du menu
    local lines = {}
    for i, item in ipairs(items) do
        table.insert(lines, string.format("%d. %s", i, item.label))
    end
    
    -- Affichage des lignes
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_lines(buf, 2, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    
    -- Mappings
    local opts = {buffer = buf, noremap = true, silent = true}
    
    -- Navigation
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #items + 2 then
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
        local selection = cursor[1] - 2 -- Ajustement pour le titre et la ligne de séparation
        
        if selection > 0 and selection <= #items then
            vim.api.nvim_win_close(win, true)
            if items[selection].action then
                items[selection].action()
            end
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

-- Menu principal
M.show_main_menu = function()
    show_menu("GitPilot - " .. i18n.t("menu.main"), {
        {
            label = i18n.t("menu.commits"),
            action = function() M.show_commits_menu() end
        },
        {
            label = i18n.t("menu.branches"),
            action = function() M.show_branches_menu() end
        },
        {
            label = i18n.t("menu.remotes"),
            action = function() M.show_remotes_menu() end
        },
        {
            label = i18n.t("menu.tags"),
            action = function() M.show_tags_menu() end
        },
        {
            label = i18n.t("menu.stash"),
            action = function() M.show_stash_menu() end
        },
        {
            label = i18n.t("menu.search"),
            action = function() require('gitpilot.features.search').show_menu() end
        },
        {
            label = i18n.t("menu.rebase"),
            action = function() require('gitpilot.features.rebase').start_rebase() end
        }
    })
end

-- Menu des commits
M.show_commits_menu = function()
    show_menu(i18n.t("menu.commits"), {
        {
            label = i18n.t("menu.create_commit"),
            action = function() require('gitpilot.features.commit').create_commit() end
        },
        {
            label = i18n.t("menu.amend_commit"),
            action = function() require('gitpilot.features.commit').amend_commit() end
        },
        {
            label = i18n.t("menu.history"),
            action = function() require('gitpilot.features.commit').show_history() end
        }
    })
end

-- Menu des branches
M.show_branches_menu = function()
    show_menu(i18n.t("menu.branches"), {
        {
            label = i18n.t("menu.create_branch"),
            action = function() require('gitpilot.features.branch').create_branch() end
        },
        {
            label = i18n.t("menu.switch_branch"),
            action = function() require('gitpilot.features.branch').switch_branch() end
        },
        {
            label = i18n.t("menu.merge_branch"),
            action = function() require('gitpilot.features.branch').merge_branch() end
        },
        {
            label = i18n.t("menu.delete_branch"),
            action = function() require('gitpilot.features.branch').delete_branch() end
        }
    })
end

-- Menu des remotes
M.show_remotes_menu = function()
    show_menu(i18n.t("menu.remotes"), {
        {
            label = i18n.t("menu.add_remote"),
            action = function() require('gitpilot.features.remote').add_remote() end
        },
        {
            label = i18n.t("menu.remove_remote"),
            action = function() require('gitpilot.features.remote').remove_remote() end
        },
        {
            label = i18n.t("menu.fetch"),
            action = function() require('gitpilot.features.remote').fetch_remote() end
        },
        {
            label = i18n.t("menu.push"),
            action = function() require('gitpilot.features.remote').push_remote() end
        }
    })
end

-- Menu des tags
M.show_tags_menu = function()
    show_menu(i18n.t("menu.tags"), {
        {
            label = i18n.t("menu.create_tag"),
            action = function() require('gitpilot.features.tags').create_tag() end
        },
        {
            label = i18n.t("menu.delete_tag"),
            action = function() require('gitpilot.features.tags').delete_tag() end
        },
        {
            label = i18n.t("menu.push_tag"),
            action = function() require('gitpilot.features.tags').push_tag() end
        }
    })
end

-- Menu du stash
M.show_stash_menu = function()
    show_menu(i18n.t("menu.stash"), {
        {
            label = i18n.t("menu.create_stash"),
            action = function() require('gitpilot.features.stash').create_stash() end
        },
        {
            label = i18n.t("menu.apply_stash"),
            action = function() require('gitpilot.features.stash').apply_stash() end
        },
        {
            label = i18n.t("menu.delete_stash"),
            action = function() require('gitpilot.features.stash').delete_stash() end
        }
    })
end

return M
