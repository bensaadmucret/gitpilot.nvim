-- lua/gitpilot/menu.lua

local M = {}
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')

-- Configuration locale
local config = {
    width = 60,
    height = 20,
    border = "rounded",
    title = true,
    footer = true
}

-- État des menus
local state = {
    current_menu = nil,
    history = {},
    context = {}
}

-- Définition des menus
local menus = {
    main = {
        title = "menu.main_title",
        items = {
            { id = "branch", text = "menu.branches", icon = "🌿" },
            { id = "commit", text = "menu.commits", icon = "📝" },
            { id = "remote", text = "menu.remotes", icon = "🔄" },
            { id = "tag", text = "menu.tags", icon = "🏷️" },
            { id = "stash", text = "menu.stash", icon = "📦" },
            { id = "search", text = "menu.search", icon = "🔍" },
            { id = "rebase", text = "menu.rebase", icon = "♻️" }
        }
    },
    branch = {
        title = "menu.branches_title",
        items = {
            { id = "create", text = "branch.create_new", icon = "➕" },
            { id = "checkout", text = "branch.checkout", icon = "✨" },
            { id = "merge", text = "branch.merge", icon = "🔗" },
            { id = "delete", text = "branch.delete", icon = "🗑️" },
            { id = "push", text = "branch.push", icon = "⬆️" },
            { id = "pull", text = "branch.pull", icon = "⬇️" },
            { id = "rebase", text = "branch.rebase", icon = "♻️" },
            { id = "refresh", text = "branch.refresh", icon = "🔄" },
            { id = "back", text = "menu.back", icon = "⬅️" }
        }
    },
    commit = {
        title = "menu.commits_title",
        items = {
            { id = "create", text = "commit.create", icon = "➕" },
            { id = "amend", text = "commit.amend", icon = "✏️" },
            { id = "fixup", text = "commit.fixup", icon = "🔧" },
            { id = "revert", text = "commit.revert", icon = "↩️" },
            { id = "cherry_pick", text = "commit.cherry_pick", icon = "🍒" },
            { id = "show", text = "commit.show", icon = "👁️" },
            { id = "back", text = "menu.back", icon = "⬅️" }
        }
    },
    stash = {
        title = "menu.stash_title",
        items = {
            { id = "save", text = "stash.save", icon = "💾" },
            { id = "pop", text = "stash.pop", icon = "📤" },
            { id = "apply", text = "stash.apply", icon = "📥" },
            { id = "drop", text = "stash.drop", icon = "🗑️" },
            { id = "show", text = "stash.show", icon = "👁️" },
            { id = "clear", text = "stash.clear", icon = "🧹" },
            { id = "back", text = "menu.back", icon = "⬅️" }
        }
    },
    tag = {
        title = "menu.tags_title",
        items = {
            { id = "create", text = "tag.create", icon = "➕" },
            { id = "delete", text = "tag.delete", icon = "🗑️" },
            { id = "push", text = "tag.push", icon = "⬆️" },
            { id = "show", text = "tag.show", icon = "👁️" },
            { id = "back", text = "menu.back", icon = "⬅️" }
        }
    },
    remote = {
        title = "menu.remotes_title",
        items = {
            { id = "add", text = "remote.add", icon = "➕" },
            { id = "remove", text = "remote.remove", icon = "🗑️" },
            { id = "fetch", text = "remote.fetch", icon = "🔄" },
            { id = "pull", text = "remote.pull", icon = "⬇️" },
            { id = "push", text = "remote.push", icon = "⬆️" },
            { id = "prune", text = "remote.prune", icon = "🧹" },
            { id = "back", text = "menu.back", icon = "⬅️" }
        }
    },
    rebase = {
        title = "menu.rebase_title",
        items = {
            { id = "start", text = "rebase.start", icon = "▶️" },
            { id = "continue", text = "rebase.continue", icon = "⏩" },
            { id = "skip", text = "rebase.skip", icon = "⏭️" },
            { id = "abort", text = "rebase.abort", icon = "⏹️" },
            { id = "interactive", text = "rebase.interactive", icon = "🔧" },
            { id = "back", text = "menu.back", icon = "⬅️" }
        }
    },
    search = {
        title = "menu.search_title",
        items = {
            { id = "commits", text = "search.commits", icon = "📝" },
            { id = "files", text = "search.files", icon = "📄" },
            { id = "branches", text = "search.branches", icon = "🌿" },
            { id = "tags", text = "search.tags", icon = "🏷️" },
            { id = "back", text = "menu.back", icon = "⬅️" }
        }
    }
}

-- Formate un élément de menu
local function format_menu_item(item)
    local text = i18n.t(item.text)
    if config.use_icons and item.icon then
        text = item.icon .. " " .. text
    end
    return text
end

-- Gère la navigation entre les menus
local function handle_menu_navigation(menu_id, item_id)
    if item_id == "back" then
        if #state.history > 0 then
            state.current_menu = table.remove(state.history)
            return true
        end
        return false
    end
    
    if item_id == "quit" then
        return false
    end

    local next_menu = menus[item_id]
    if next_menu then
        table.insert(state.history, menu_id)
        state.current_menu = item_id
        return true
    end
    return false
end

-- Affiche un menu
function M.show_menu(menu_id, context)
    menu_id = menu_id or state.current_menu or "main"
    local menu = menus[menu_id]
    if not menu then
        ui.show_error(i18n.t("error.invalid_menu"))
        return
    end

    state.context = context or {}
    local items = {}
    for _, item in ipairs(menu.items) do
        table.insert(items, format_menu_item(item))
    end

    ui.select(items, {
        prompt = i18n.t(menu.title),
        format_item = function(item)
            return item
        end
    }, function(choice)
        if not choice then return end
        
        -- Trouve l'item sélectionné
        local selected_item
        for i, item in ipairs(menu.items) do
            if format_menu_item(item) == choice then
                selected_item = item
                break
            end
        end
        
        if not selected_item then return end

        -- Gère la navigation
        if not handle_menu_navigation(menu_id, selected_item.id) then
            -- Émet un événement pour le gestionnaire d'actions
            vim.schedule(function()
                require('gitpilot.actions').handle_action(menu_id, selected_item.id, state.context)
            end)
        else
            -- Affiche le nouveau menu
            vim.schedule(function()
                M.show_menu(state.current_menu, state.context)
            end)
        end
    end)
end

-- Initialisation du module
function M.setup(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})
end

-- Réinitialise l'état
function M.reset()
    state.current_menu = nil
    state.history = {}
    state.context = {}
end

return M
