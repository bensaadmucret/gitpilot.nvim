local M = {}
local config = {}
local i18n = require('gitpilot.i18n')

M.setup = function(opts)
    config = opts
end

-- Fonction de notification
M.notify = function(msg, level)
    level = level or vim.log.levels.INFO
    vim.notify(msg, level, {
        title = "GitPilot",
        icon = "🚀"
    })
end

-- Création d'une fenêtre flottante
M.create_floating_window = function(title, lines, opts)
    opts = opts or {}
    local width = opts.width or config.ui.window.width or 60
    local height = opts.height or config.ui.window.height or 20
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    local win_opts = {
        relative = 'editor',
        row = row,
        col = col,
        width = width,
        height = height,
        style = 'minimal',
        border = opts.border or config.ui.window.border or 'rounded'
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
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    
    return buf, win
end

-- Affichage d'un menu
local function show_menu(title, items)
    local buf, win = M.create_floating_window(title)
    
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
    
    -- Sélection par numéro
    for i = 1, #items do
        vim.keymap.set('n', tostring(i), function()
            if items[i] and items[i].action then
                vim.api.nvim_win_close(win, true)
                items[i].action()
            end
        end, opts)
    end

    -- Sélection avec Enter
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
M.show_main_menu = function(items, title)
    show_menu(title or ("GitPilot - " .. i18n.t("menu.main")), items)
end

-- Menu des commits
M.show_commits_menu = function()
    local menu_title = i18n.t("menu.commits_title")
    M.show_main_menu({
        {
            label = i18n.t("commit.create"),
            action = function() require('gitpilot.features.commit').create_commit() end
        },
        {
            label = i18n.t("commit.amend"),
            action = function() require('gitpilot.features.commit').amend_commit() end
        },
        {
            label = i18n.t("commit.history"),
            action = function() require('gitpilot.features.commit').show_history() end
        },
        {
            label = i18n.t("commit.discard"),
            action = function() require('gitpilot.features.commit').discard_changes() end
        }
    }, menu_title)
end

-- Menu des branches
M.show_branches_menu = function()
    -- Obtenir la branche courante
    local current_branch = vim.fn.system('git branch --show-current'):gsub('\n', '')
    local menu_title = string.format("%s (%s: %s)", i18n.t("menu.branches_title"), i18n.t("branch.current"), current_branch)
    
    M.show_main_menu({
        {
            label = i18n.t("branch.create"),
            action = function()
                require('gitpilot.features.branch').create_branch()
            end
        },
        {
            label = i18n.t("branch.switch"),
            action = function()
                require('gitpilot.features.branch').switch_branch()
            end
        },
        {
            label = i18n.t("branch.merge"),
            action = function()
                require('gitpilot.features.branch').merge_branch()
            end
        },
        {
            label = i18n.t("branch.delete"),
            action = function()
                require('gitpilot.features.branch').delete_branch()
            end
        }
    }, menu_title)  -- Passer le titre personnalisé
end

-- Menu des remotes
M.show_remotes_menu = function()
    M.show_main_menu({
        {
            label = i18n.t("remote.add"),
            action = function() require('gitpilot.features.remote').add_remote() end
        },
        {
            label = i18n.t("remote.remove"),
            action = function() require('gitpilot.features.remote').remove_remote() end
        },
        {
            label = i18n.t("remote.push"),
            action = function() require('gitpilot.features.remote').push_remote() end
        },
        {
            label = i18n.t("remote.fetch"),
            action = function() require('gitpilot.features.remote').fetch_remote() end
        }
    }, i18n.t("remote.title"))
end

-- Menu des tags
M.show_tags_menu = function()
    M.show_main_menu({
        {
            label = i18n.t("tag.create"),
            action = function() require('gitpilot.features.tags').create_tag() end
        },
        {
            label = i18n.t("tag.delete"),
            action = function() require('gitpilot.features.tags').delete_tag() end
        },
        {
            label = i18n.t("tag.push"),
            action = function() require('gitpilot.features.tags').push_tag() end
        }
    }, i18n.t("tag.title"))
end

-- Menu du stash
M.show_stash_menu = function()
    M.show_main_menu({
        {
            label = i18n.t("stash.create"),
            action = function() require('gitpilot.features.stash').create_stash() end
        },
        {
            label = i18n.t("stash.apply"),
            action = function() require('gitpilot.features.stash').apply_stash() end
        },
        {
            label = i18n.t("stash.delete"),
            action = function() require('gitpilot.features.stash').delete_stash() end
        }
    }, i18n.t("stash.title"))
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
