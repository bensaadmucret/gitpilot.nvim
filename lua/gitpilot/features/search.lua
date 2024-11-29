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

-- Recherche dans l'historique des commits
M.search_commits = function()
    vim.ui.input({prompt = i18n.t("search.commits.prompt")}, function(query)
        if not query or query == "" then return end
        
        local commits = utils.git_command(string.format('log --all --grep="%s" --format="%%h|%%s|%%an|%%ar"', query))
        if not commits or commits == "" then
            ui.notify(i18n.t("search.commits.none"), "warn")
            return
        end

        local commit_list = {}
        local commit_data = {}
        for line in commits:gmatch("[^\r\n]+") do
            local hash, subject, author, date = line:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)")
            if hash then
                table.insert(commit_data, {
                    hash = hash,
                    subject = subject,
                    author = author,
                    date = date
                })
                table.insert(commit_list, string.format("%s - %s (%s, %s)", hash, subject, author, date))
            end
        end

        local buf, win = ui.create_floating_window(
            i18n.t("search.commits.results"),
            commit_list,
            {
                width = 100
            }
        )

        -- Navigation
        local opts = {buffer = buf, noremap = true, silent = true}
        
        vim.keymap.set('n', 'j', function()
            local cursor = vim.api.nvim_win_get_cursor(win)
            if cursor[1] < #commit_list then
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

        -- Voir les détails du commit
        vim.keymap.set('n', '<CR>', function()
            local cursor = vim.api.nvim_win_get_cursor(win)
            local commit = commit_data[cursor[1]]
            
            local details = utils.git_command('show ' .. commit.hash)
            if details then
                local detail_lines = vim.split(details, "\n")
                local detail_buf, detail_win = ui.create_floating_window(
                    i18n.t("search.commits.details"),
                    detail_lines,
                    {
                        width = 100,
                        height = 20
                    }
                )

                -- Navigation dans les détails
                local detail_opts = {buffer = detail_buf, noremap = true, silent = true}
                vim.keymap.set('n', 'q', function()
                    vim.api.nvim_win_close(detail_win, true)
                end, detail_opts)
                
                vim.keymap.set('n', '<Esc>', function()
                    vim.api.nvim_win_close(detail_win, true)
                end, detail_opts)
            end
        end, opts)
    end)
end

-- Recherche de fichiers modifiés
M.search_files = function()
    vim.ui.input({prompt = i18n.t("search.files.prompt")}, function(pattern)
        if not pattern or pattern == "" then return end
        
        local files = utils.git_command(string.format('ls-files "*%s*"', pattern))
        if not files or files == "" then
            ui.notify(i18n.t("search.files.none"), "warn")
            return
        end

        local file_list = vim.split(files, "\n")
        local buf, win = ui.create_floating_window(
            i18n.t("search.files.results"),
            file_list,
            {
                width = 80
            }
        )

        -- Navigation
        local opts = {buffer = buf, noremap = true, silent = true}
        
        vim.keymap.set('n', 'j', function()
            local cursor = vim.api.nvim_win_get_cursor(win)
            if cursor[1] < #file_list then
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

        -- Ouvrir le fichier
        vim.keymap.set('n', '<CR>', function()
            local cursor = vim.api.nvim_win_get_cursor(win)
            local file = file_list[cursor[1]]
            vim.api.nvim_win_close(win, true)
            vim.cmd('edit ' .. file)
        end, opts)
    end)
end

-- Recherche par auteur
M.search_by_author = function()
    vim.ui.input({prompt = i18n.t("search.author.prompt")}, function(author)
        if not author or author == "" then return end
        
        local commits = utils.git_command(string.format('log --author="%s" --format="%%h|%%s|%%ar"', author))
        if not commits or commits == "" then
            ui.notify(i18n.t("search.author.none"), "warn")
            return
        end

        local commit_list = {}
        local commit_data = {}
        for line in commits:gmatch("[^\r\n]+") do
            local hash, subject, date = line:match("([^|]+)|([^|]+)|([^|]+)")
            if hash then
                table.insert(commit_data, {
                    hash = hash,
                    subject = subject,
                    date = date
                })
                table.insert(commit_list, string.format("%s - %s (%s)", hash, subject, date))
            end
        end

        local buf, win = ui.create_floating_window(
            string.format(i18n.t("search.author.results"), author),
            commit_list,
            {
                width = 100
            }
        )

        -- Navigation
        local opts = {buffer = buf, noremap = true, silent = true}
        
        vim.keymap.set('n', 'j', function()
            local cursor = vim.api.nvim_win_get_cursor(win)
            if cursor[1] < #commit_list then
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

        -- Voir les détails du commit
        vim.keymap.set('n', '<CR>', function()
            local cursor = vim.api.nvim_win_get_cursor(win)
            local commit = commit_data[cursor[1]]
            
            local details = utils.git_command('show ' .. commit.hash)
            if details then
                local detail_lines = vim.split(details, "\n")
                local detail_buf, detail_win = ui.create_floating_window(
                    i18n.t("search.commits.details"),
                    detail_lines,
                    {
                        width = 100,
                        height = 20
                    }
                )

                -- Navigation dans les détails
                local detail_opts = {buffer = detail_buf, noremap = true, silent = true}
                vim.keymap.set('n', 'q', function()
                    vim.api.nvim_win_close(detail_win, true)
                end, detail_opts)
                
                vim.keymap.set('n', '<Esc>', function()
                    vim.api.nvim_win_close(detail_win, true)
                end, detail_opts)
            end
        end, opts)
    end)
end

-- Filtrage des branches
M.filter_branches = function()
    vim.ui.input({prompt = i18n.t("search.branches.prompt")}, function(pattern)
        if not pattern or pattern == "" then return end
        
        local branches = utils.git_command(string.format('branch --list "*%s*" --format="%(refname:short)|%(upstream:short)|%(committerdate:relative)"', pattern))
        if not branches or branches == "" then
            ui.notify(i18n.t("search.branches.none"), "warn")
            return
        end

        local branch_list = {}
        local branch_data = {}
        for line in branches:gmatch("[^\r\n]+") do
            local name, upstream, date = line:match("([^|]+)|([^|]*)|([^|]+)")
            if name then
                table.insert(branch_data, {
                    name = name,
                    upstream = upstream ~= "" and upstream or nil,
                    date = date
                })
                local display = name
                if upstream and upstream ~= "" then
                    display = display .. " → " .. upstream
                end
                display = display .. " (" .. date .. ")"
                table.insert(branch_list, display)
            end
        end

        local buf, win = ui.create_floating_window(
            i18n.t("search.branches.results"),
            branch_list,
            {
                width = 80
            }
        )

        -- Navigation
        local opts = {buffer = buf, noremap = true, silent = true}
        
        vim.keymap.set('n', 'j', function()
            local cursor = vim.api.nvim_win_get_cursor(win)
            if cursor[1] < #branch_list then
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

        -- Checkout de la branche
        vim.keymap.set('n', '<CR>', function()
            local cursor = vim.api.nvim_win_get_cursor(win)
            local branch = branch_data[cursor[1]]
            
            vim.api.nvim_win_close(win, true)
            
            local result = utils.git_command('checkout ' .. branch.name)
            if result then
                ui.notify(i18n.t("search.branches.switched") .. ": " .. branch.name, "info")
            end
        end, opts)
    end)
end

return M
