local M = {}
local config = {
    ui = {
        window = {
            width = 60,
            height = 20,
            border = 'rounded'
        },
        test_mode = false
    }
}
local i18n = require('gitpilot.i18n')

M.setup = function(opts)
    if opts then
        config = vim.tbl_deep_extend('force', config, opts or {})
    end
end

-- Fonction de notification
M.notify = function(msg, level, opts)
    level = level or "info"
    opts = opts or {}

    -- Map string levels to vim.log.levels
    local level_map = {
        ["error"] = vim.log.levels.ERROR,
        ["warn"] = vim.log.levels.WARN,
        ["info"] = vim.log.levels.INFO,
        ["debug"] = vim.log.levels.DEBUG,
        ["trace"] = vim.log.levels.TRACE
    }

    -- Store notification for testing
    M.last_notification = {
        message = msg,
        level = level,
        opts = opts
    }

    -- In test mode, only store notification
    if config.test_mode then
        return
    end

    -- Convert level to numeric if it's a string
    local numeric_level = type(level) == "string" and level_map[level] or level

    -- Add default options
    opts = vim.tbl_extend('keep', opts, {
        title = "GitPilot",
        icon = "🚀"
    })

    vim.notify(msg, numeric_level, opts)
end

-- Input dialog with test mode support
M.input = function(opts, callback)
    opts = opts or {}
    
    -- In test mode, use environment variables
    if config.test_mode then
        local response = vim.env.UI_INPUT_RESPONSE or ""
        if callback then
            callback(response)
        end
        return response
    end

    -- Add default options
    opts = vim.tbl_extend('keep', opts, {
        prompt = "Input: ",
        default = "",
        completion = "file"
    })

    return vim.ui.input(opts, callback)
end

-- Select dialog with test mode support
M.select = function(items, opts, callback)
    opts = opts or {}
    
    -- In test mode, use environment variables
    if config.test_mode then
        local index = tonumber(vim.env.UI_SELECT_INDEX) or 1
        local selected = items[index]
        if callback then
            callback(selected, index)
        end
        return selected, index
    end

    -- Add default options
    opts = vim.tbl_extend('keep', opts, {
        prompt = "Select: ",
        format_item = function(item)
            return tostring(item)
        end
    })

    return vim.ui.select(items, opts, callback)
end

-- Create floating window
M.create_floating_window = function(title, content, opts)
    opts = opts or {}
    
    -- In test mode, just store window content
    if config.test_mode then
        M.last_window = {
            title = title,
            content = content,
            opts = opts
        }
        return 0, 0
    end

    -- Calculate window size
    local width = opts.width or config.ui.window.width
    local height = opts.height or config.ui.window.height

    -- Create buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

    -- Set content
    if type(content) == "string" then
        content = vim.split(content, "\n")
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

    -- Calculate position
    local ui = vim.api.nvim_list_uis()[1]
    local win_opts = {
        relative = 'editor',
        width = width,
        height = height,
        col = (ui.width - width) / 2,
        row = (ui.height - height) / 2,
        style = 'minimal',
        border = config.ui.window.border
    }

    -- Create window
    local win = vim.api.nvim_open_win(buf, true, win_opts)

    -- Set window options
    vim.api.nvim_win_set_option(win, 'wrap', false)
    vim.api.nvim_win_set_option(win, 'cursorline', true)

    -- Set buffer options
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'gitpilot')

    -- Set title
    if title then
        vim.api.nvim_buf_set_name(buf, title)
    end

    return buf, win
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

-- Show menu in floating window
M.show_menu = function(title, items)
    -- For testing purposes, return menu configuration instead of creating real menu
    if config.test_mode then
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

return M
