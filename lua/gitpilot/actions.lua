-- lua/gitpilot/actions.lua

local M = {}
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')
local utils = require('gitpilot.utils')

-- Configuration locale
local config = {
    confirm_actions = true,
    auto_refresh = true
}

function M.setup(opts)
    if opts then
        config = vim.tbl_deep_extend('force', config, opts)
    end
end

-- Gestionnaires d'actions par menu
local handlers = {
    branch = {
        create = function(context)
            ui.input({
                prompt = i18n.t("branch.enter_name")
            }, function(name)
                if name then
                    local branch = require('gitpilot.features.branch')
                    if branch.create_branch(name) and config.auto_refresh then
                        require('gitpilot.menu').show_menu("branch")
                    end
                end
            end)
        end,
        
        checkout = function(context)
            local branch = require('gitpilot.features.branch')
            local branches, current = branch.list_branches()
            if not branches then return end
            
            -- Filtre la branche courante et les branches de backup
            local choices = {}
            for _, b in ipairs(branches) do
                if b ~= current and not b:match("^backup_%d+$") then
                    table.insert(choices, b)
                end
            end
            
            -- Vérifie s'il y a des branches disponibles
            if #choices == 0 then
                ui.show_info(i18n.t("branch.info.no_other_branches"))
                return
            end
            
            ui.select(choices, {
                prompt = i18n.t("branch.select_checkout")
            }, function(choice)
                if choice then
                    if branch.checkout_branch(choice) and config.auto_refresh then
                        require('gitpilot.menu').show_menu("branch")
                    end
                end
            end)
        end,

        merge = function(context)
            local branch = require('gitpilot.features.branch')
            local branches, current = branch.list_branches()
            if not branches then return end
            
            -- Filtre la branche courante
            local choices = {}
            for _, b in ipairs(branches) do
                if b ~= current then
                    table.insert(choices, b)
                end
            end
            
            ui.select(choices, {
                prompt = i18n.t("branch.select_merge")
            }, function(choice)
                if choice then
                    if branch.merge_branch(choice) and config.auto_refresh then
                        require('gitpilot.menu').show_menu("branch")
                    end
                end
            end)
        end,

        delete = function(context)
            local branch = require('gitpilot.features.branch')
            local branches, current = branch.list_branches()
            if not branches then return end
            
            -- Filtre la branche courante
            local choices = {}
            for _, b in ipairs(branches) do
                if b ~= current then
                    table.insert(choices, b)
                end
            end
            
            ui.select(choices, {
                prompt = i18n.t("branch.select_delete")
            }, function(choice)
                if choice then
                    ui.confirm(i18n.t("branch.confirm_delete", {branch = choice}), function(confirmed)
                        if confirmed then
                            if branch.delete_branch(choice) and config.auto_refresh then
                                require('gitpilot.menu').show_menu("branch")
                            end
                        end
                    end)
                end
            end)
        end,

        push = function(context)
            local branch = require('gitpilot.features.branch')
            local current = branch.current_branch()
            if not current then return end

            ui.confirm(i18n.t("branch.confirm_push", {branch = current}), function(confirmed)
                if confirmed then
                    if branch.push_branch(current) and config.auto_refresh then
                        require('gitpilot.menu').show_menu("branch")
                    end
                end
            end)
        end,

        pull = function(context)
            local branch = require('gitpilot.features.branch')
            local current = branch.current_branch()
            if not current then return end

            ui.confirm(i18n.t("branch.confirm_pull", {branch = current}), function(confirmed)
                if confirmed then
                    if branch.pull_branch(current) and config.auto_refresh then
                        require('gitpilot.menu').show_menu("branch")
                    end
                end
            end)
        end,

        rebase = function(context)
            local branch = require('gitpilot.features.branch')
            local branches, current = branch.list_branches()
            if not branches then return end
            
            -- Filtre la branche courante
            local choices = {}
            for _, b in ipairs(branches) do
                if b ~= current then
                    table.insert(choices, b)
                end
            end
            
            ui.select(choices, {
                prompt = i18n.t("branch.select_rebase")
            }, function(choice)
                if choice then
                    ui.confirm(i18n.t("branch.confirm_rebase", {branch = choice}), function(confirmed)
                        if confirmed then
                            if branch.rebase_branch(choice) and config.auto_refresh then
                                require('gitpilot.menu').show_menu("branch")
                            end
                        end
                    end)
                end
            end)
        end,

        refresh = function(context)
            require('gitpilot.menu').show_menu("branch")
        end
    },

    commit = {
        create = function(context)
            local commit = require('gitpilot.features.commit')
            commit.create_commit()
        end,

        amend = function(context)
            local commit = require('gitpilot.features.commit')
            ui.confirm(i18n.t("commit.confirm_amend"), function(confirmed)
                if confirmed then
                    commit.amend_commit()
                end
            end)
        end,

        fixup = function(context)
            local commit = require('gitpilot.features.commit')
            commit.show_commit_log(function(hash)
                if hash then
                    ui.confirm(i18n.t("commit.confirm_fixup", {hash = hash:sub(1,7)}), function(confirmed)
                        if confirmed then
                            commit.fixup_commit(hash)
                        end
                    end)
                end
            end)
        end,

        revert = function(context)
            local commit = require('gitpilot.features.commit')
            commit.show_commit_log(function(hash)
                if hash then
                    ui.confirm(i18n.t("commit.confirm_revert", {hash = hash:sub(1,7)}), function(confirmed)
                        if confirmed then
                            commit.revert_commit(hash)
                        end
                    end)
                end
            end)
        end,

        cherry_pick = function(context)
            local commit = require('gitpilot.features.commit')
            commit.show_commit_log(function(hash)
                if hash then
                    ui.confirm(i18n.t("commit.confirm_cherry_pick", {hash = hash:sub(1,7)}), function(confirmed)
                        if confirmed then
                            commit.cherry_pick_commit(hash)
                        end
                    end)
                end
            end)
        end,

        show = function(context)
            local commit = require('gitpilot.features.commit')
            commit.show_commit_log(function(hash)
                if hash then
                    commit.show_commit(hash)
                end
            end)
        end
    },

    stash = {
        save = function(context)
            local stash = require('gitpilot.features.stash')
            ui.input({
                prompt = i18n.t("stash.enter_message")
            }, function(message)
                if message then
                    stash.save(message)
                end
            end)
        end,

        pop = function(context)
            local stash = require('gitpilot.features.stash')
            stash.list(function(stash_id)
                if stash_id then
                    ui.confirm(i18n.t("stash.confirm_pop"), function(confirmed)
                        if confirmed then
                            stash.pop(stash_id)
                        end
                    end)
                end
            end)
        end,

        apply = function(context)
            local stash = require('gitpilot.features.stash')
            stash.list(function(stash_id)
                if stash_id then
                    stash.apply(stash_id)
                end
            end)
        end,

        drop = function(context)
            local stash = require('gitpilot.features.stash')
            stash.list(function(stash_id)
                if stash_id then
                    ui.confirm(i18n.t("stash.confirm_drop"), function(confirmed)
                        if confirmed then
                            stash.drop(stash_id)
                        end
                    end)
                end
            end)
        end,

        show = function(context)
            local stash = require('gitpilot.features.stash')
            stash.list(function(stash_id)
                if stash_id then
                    stash.show(stash_id)
                end
            end)
        end,

        clear = function(context)
            local stash = require('gitpilot.features.stash')
            ui.confirm(i18n.t("stash.confirm_clear"), function(confirmed)
                if confirmed then
                    stash.clear()
                end
            end)
        end
    },

    tag = {
        create = function(context)
            local tag = require('gitpilot.features.tag')
            ui.input({
                prompt = i18n.t("tag.enter_name")
            }, function(name)
                if name then
                    tag.create(name)
                end
            end)
        end,

        delete = function(context)
            local tag = require('gitpilot.features.tag')
            tag.list(function(tag_name)
                if tag_name then
                    ui.confirm(i18n.t("tag.confirm_delete", {tag = tag_name}), function(confirmed)
                        if confirmed then
                            tag.delete(tag_name)
                        end
                    end)
                end
            end)
        end,

        push = function(context)
            local tag = require('gitpilot.features.tag')
            tag.list(function(tag_name)
                if tag_name then
                    ui.confirm(i18n.t("tag.confirm_push", {tag = tag_name}), function(confirmed)
                        if confirmed then
                            tag.push(tag_name)
                        end
                    end)
                end
            end)
        end,

        show = function(context)
            local tag = require('gitpilot.features.tag')
            tag.list(function(tag_name)
                if tag_name then
                    tag.show(tag_name)
                end
            end)
        end
    },

    remote = {
        add = function(context)
            local remote = require('gitpilot.features.remote')
            ui.input({
                prompt = i18n.t("remote.enter_name")
            }, function(name)
                if name then
                    ui.input({
                        prompt = i18n.t("remote.enter_url")
                    }, function(url)
                        if url then
                            remote.add(name, url)
                        end
                    end)
                end
            end)
        end,

        remove = function(context)
            local remote = require('gitpilot.features.remote')
            remote.list(function(remote_name)
                if remote_name then
                    ui.confirm(i18n.t("remote.confirm_remove", {remote = remote_name}), function(confirmed)
                        if confirmed then
                            remote.remove(remote_name)
                        end
                    end)
                end
            end)
        end,

        fetch = function(context)
            local remote = require('gitpilot.features.remote')
            remote.list(function(remote_name)
                if remote_name then
                    remote.fetch(remote_name)
                end
            end)
        end,

        pull = function(context)
            local remote = require('gitpilot.features.remote')
            remote.list(function(remote_name)
                if remote_name then
                    remote.pull(remote_name)
                end
            end)
        end,

        push = function(context)
            local remote = require('gitpilot.features.remote')
            remote.list(function(remote_name)
                if remote_name then
                    remote.push(remote_name)
                end
            end)
        end,

        prune = function(context)
            local remote = require('gitpilot.features.remote')
            remote.list(function(remote_name)
                if remote_name then
                    ui.confirm(i18n.t("remote.confirm_prune", {remote = remote_name}), function(confirmed)
                        if confirmed then
                            remote.prune(remote_name)
                        end
                    end)
                end
            end)
        end
    },

    rebase = {
        start = function(context)
            local rebase = require('gitpilot.features.rebase')
            rebase.start()
        end,

        continue = function(context)
            local rebase = require('gitpilot.features.rebase')
            rebase.continue()
        end,

        skip = function(context)
            local rebase = require('gitpilot.features.rebase')
            rebase.skip()
        end,

        abort = function(context)
            local rebase = require('gitpilot.features.rebase')
            ui.confirm(i18n.t("rebase.confirm_abort"), function(confirmed)
                if confirmed then
                    rebase.abort()
                end
            end)
        end,

        interactive = function(context)
            local rebase = require('gitpilot.features.rebase')
            rebase.interactive()
        end
    },

    search = {
        commits = function(context)
            local search = require('gitpilot.features.search')
            ui.input({
                prompt = i18n.t("search.enter_commit_query")
            }, function(query)
                if query then
                    search.commits(query)
                end
            end)
        end,

        files = function(context)
            local search = require('gitpilot.features.search')
            ui.input({
                prompt = i18n.t("search.enter_file_query")
            }, function(query)
                if query then
                    search.files(query)
                end
            end)
        end,

        branches = function(context)
            local search = require('gitpilot.features.search')
            ui.input({
                prompt = i18n.t("search.enter_branch_query")
            }, function(query)
                if query then
                    search.branches(query)
                end
            end)
        end,

        tags = function(context)
            local search = require('gitpilot.features.search')
            ui.input({
                prompt = i18n.t("search.enter_tag_query")
            }, function(query)
                if query then
                    search.tags(query)
                end
            end)
        end
    }
}

function M.handle_action(menu_id, action_id, context)
    local menu_handlers = handlers[menu_id]
    if not menu_handlers then
        ui.show_error(i18n.t("error.invalid_menu_handler", {menu = menu_id}))
        return false
    end

    local handler = menu_handlers[action_id]
    if not handler then
        ui.show_error(i18n.t("error.invalid_action_handler", {action = action_id}))
        return false
    end

    handler(context)
    return true
end

return M
