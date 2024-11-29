local M = {}
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')
local utils = require('gitpilot.utils')

-- Configuration locale
local config = {}

-- Setup function
M.setup = function(opts)
    config = opts
end

-- Liste des branches
M.list_branches = function()
    local branches = utils.git_command('branch --all --format="%(refname:short)|%(upstream:short)|%(objectname:short)|%(contents:subject)"')
    if not branches then return {} end

    local branch_list = {}
    for line in branches:gmatch("[^\r\n]+") do
        local name, upstream, hash, message = line:match("([^|]+)|([^|]*)|([^|]+)|([^|]+)")
        if name then
            table.insert(branch_list, {
                name = name,
                upstream = upstream ~= "" and upstream or nil,
                hash = hash,
                message = message or "",
                current = name:match("^%*%s+(.+)") ~= nil
            })
        end
    end
    return branch_list
end

-- Créer une nouvelle branche
M.create_branch = function()
    vim.ui.input({prompt = i18n.t("branch.create.prompt")}, function(name)
        if not name or name == "" then return end
        
        -- Vérifier si la branche existe déjà
        local existing = utils.git_command('show-ref --verify --quiet refs/heads/' .. name)
        if existing then
            ui.notify(i18n.t("branch.exists"), "warn")
            return
        end

        local result = utils.git_command('checkout -b ' .. name)
        if result then
            ui.notify(i18n.t("branch.created") .. ": " .. name, "info")
        end
    end)
end

-- Changer de branche
M.switch_branch = function()
    local branches = M.list_branches()
    if #branches == 0 then
        ui.notify(i18n.t("branch.none"), "warn")
        return
    end

    local branch_display = {}
    for _, branch in ipairs(branches) do
        local display = branch.name
        if branch.upstream then
            display = display .. " → " .. branch.upstream
        end
        if branch.current then
            display = "* " .. display
        end
        table.insert(branch_display, display)
    end

    local buf, win = ui.create_floating_window(
        i18n.t("branch.select_switch"),
        branch_display,
        {
            width = 80
        }
    )

    -- Navigation
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #branch_display then
            vim.api.nvim_win_set_cursor(win, {cursor[1] + 1, cursor[2]})
        end
    end, opts)
    
    vim.keymap.set('n', 'k', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] > 1 then
            vim.api.nvim_win_set_cursor(win, {cursor[1] - 1, cursor[2]})
        end
    end, opts)

    -- Fermeture
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
    end, opts)

    -- Sélection et changement
    vim.keymap.set('n', '<CR>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local branch = branches[cursor[1]]
        
        vim.api.nvim_win_close(win, true)
        
        if branch.current then
            ui.notify(i18n.t("branch.already_on"), "warn")
            return
        end

        local result = utils.git_command('checkout ' .. branch.name)
        if result then
            ui.notify(i18n.t("branch.switched") .. ": " .. branch.name, "info")
        end
    end, opts)
end

-- Fusionner une branche
M.merge_branch = function()
    local branches = M.list_branches()
    if #branches == 0 then
        ui.notify(i18n.t("branch.none"), "warn")
        return
    end

    local branch_display = {}
    local merge_candidates = {}
    for _, branch in ipairs(branches) do
        if not branch.current then
            table.insert(merge_candidates, branch)
            local display = branch.name
            if branch.upstream then
                display = display .. " → " .. branch.upstream
            end
            table.insert(branch_display, display)
        end
    end

    if #merge_candidates == 0 then
        ui.notify(i18n.t("branch.no_merge_candidates"), "warn")
        return
    end

    local buf, win = ui.create_floating_window(
        i18n.t("branch.select_merge"),
        branch_display,
        {
            width = 80
        }
    )

    -- Navigation
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #branch_display then
            vim.api.nvim_win_set_cursor(win, {cursor[1] + 1, cursor[2]})
        end
    end, opts)
    
    vim.keymap.set('n', 'k', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] > 1 then
            vim.api.nvim_win_set_cursor(win, {cursor[1] - 1, cursor[2]})
        end
    end, opts)

    -- Fermeture
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
    end, opts)

    -- Sélection et fusion
    vim.keymap.set('n', '<CR>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local branch = merge_candidates[cursor[1]]
        
        vim.api.nvim_win_close(win, true)
        
        ui.confirm(i18n.t("branch.confirm_merge") .. " " .. branch.name .. "?", function(confirmed)
            if confirmed then
                local result = utils.git_command('merge ' .. branch.name)
                if result then
                    ui.notify(i18n.t("branch.merged") .. ": " .. branch.name, "info")
                end
            end
        end)
    end, opts)
end

-- Supprimer une branche
M.delete_branch = function()
    local branches = M.list_branches()
    if #branches == 0 then
        ui.notify(i18n.t("branch.none"), "warn")
        return
    end

    local branch_display = {}
    local delete_candidates = {}
    for _, branch in ipairs(branches) do
        if not branch.current then
            table.insert(delete_candidates, branch)
            local display = branch.name
            if branch.upstream then
                display = display .. " → " .. branch.upstream
            end
            table.insert(branch_display, display)
        end
    end

    if #delete_candidates == 0 then
        ui.notify(i18n.t("branch.no_delete_candidates"), "warn")
        return
    end

    local buf, win = ui.create_floating_window(
        i18n.t("branch.select_delete"),
        branch_display,
        {
            width = 80
        }
    )

    -- Navigation
    local opts = {buffer = buf, noremap = true, silent = true}
    
    vim.keymap.set('n', 'j', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] < #branch_display then
            vim.api.nvim_win_set_cursor(win, {cursor[1] + 1, cursor[2]})
        end
    end, opts)
    
    vim.keymap.set('n', 'k', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        if cursor[1] > 1 then
            vim.api.nvim_win_set_cursor(win, {cursor[1] - 1, cursor[2]})
        end
    end, opts)

    -- Fermeture
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, true)
    end, opts)
    
    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
    end, opts)

    -- Sélection et suppression
    vim.keymap.set('n', '<CR>', function()
        local cursor = vim.api.nvim_win_get_cursor(win)
        local branch = delete_candidates[cursor[1]]
        
        vim.api.nvim_win_close(win, true)
        
        ui.confirm(i18n.t("branch.confirm_delete") .. " " .. branch.name .. "?", function(confirmed)
            if confirmed then
                local result = utils.git_command('branch -D ' .. branch.name)
                if result then
                    ui.notify(i18n.t("branch.deleted") .. ": " .. branch.name, "info")
                end
            end
        end)
    end, opts)
end

return M
