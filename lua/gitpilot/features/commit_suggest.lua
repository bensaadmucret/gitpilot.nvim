local M = {}
local utils = require('gitpilot.utils')
local i18n = require('gitpilot.i18n')
local ui = require('gitpilot.ui')

-- Configuration par défaut
function M.setup(opts)
    opts = opts or {}
    M.config = vim.tbl_deep_extend('force', {
        git_cmd = 'git',
        timeout = 5000,
        test_mode = false,
        -- Patterns pour détecter le type de changement
        patterns = {
            feature = {
                "feat:",
                "feature:",
                "add:",
                "new file:",
            },
            fix = {
                "fix:",
                "bugfix:",
                "hotfix:",
            },
            refactor = {
                "refactor:",
                "style:",
                "rename:",
            },
            docs = {
                "docs:",
                "README",
                ".md$",
            },
            test = {
                "test:",
                "_spec",
                "spec/",
                "test/",
            },
            i18n = {
                "i18n/",
                "translations",
                "locale",
            }
        },
        -- Emojis pour les types de commit
        emojis = {
            feature = "✨",
            fix = "🐛",
            refactor = "♻️",
            docs = "📝",
            test = "🧪",
            i18n = "🌐",
            style = "💄",
            perf = "⚡️",
            chore = "🔧"
        }
    }, opts)
end

-- Analyse le diff pour détecter le type de changement
local function analyze_diff(diff_content)
    local changes = {
        files_changed = {},
        additions = 0,
        deletions = 0,
        type = "chore", -- type par défaut
        component = nil,
        is_breaking = false
    }

    -- Analyse ligne par ligne
    for line in diff_content:gmatch("[^\r\n]+") do
        -- Détecte les fichiers modifiés
        local file = line:match("^%+%+%+ b/(.+)$")
        if file then
            table.insert(changes.files_changed, file)
        end

        -- Compte les additions et suppressions
        if line:match("^%+") then
            changes.additions = changes.additions + 1
        elseif line:match("^%-") then
            changes.deletions = changes.deletions + 1
        end

        -- Détecte les breaking changes
        if line:match("BREAKING CHANGE") then
            changes.is_breaking = true
        end
    end

    return changes
end

-- Détermine le type de commit basé sur les fichiers modifiés
local function determine_commit_type(files)
    for file in ipairs(files) do
        -- Vérifie les patterns pour chaque type
        for type, patterns in pairs(M.config.patterns) do
            for _, pattern in ipairs(patterns) do
                if file:match(pattern) then
                    return type
                end
            end
        end
    end
    return "chore"
end

-- Génère une suggestion de message de commit
function M.suggest_commit_message()
    if vim.env.GITPILOT_TEST == "1" then
        return {
            success = true,
            output = {
                type = "feat",
                scope = "core",
                message = "add new feature",
                emoji = "✨"
            }
        }
    end

    -- Récupère le diff
    local diff = utils.git_command("diff --staged")
    if not diff then
        return {
            success = false,
            error = i18n.t("commit.error.no_staged_changes")
        }
    end

    -- Analyse les changements
    local changes = analyze_diff(diff)
    local commit_type = determine_commit_type(changes.files_changed)
    
    -- Détermine le scope basé sur les composants modifiés
    local scope = changes.component or "core"
    
    -- Construit le message
    local message = {
        type = commit_type,
        scope = scope,
        emoji = M.config.emojis[commit_type],
        message = string.format("%s (%d+/%d-)", 
            i18n.t("commit.suggest." .. commit_type),
            changes.additions,
            changes.deletions
        )
    }

    -- Ajoute le préfixe BREAKING CHANGE si nécessaire
    if changes.is_breaking then
        message.message = "BREAKING CHANGE: " .. message.message
    end

    return {
        success = true,
        output = message
    }
end

-- Formate le message de commit suggéré
function M.format_commit_message(suggestion)
    if not suggestion or not suggestion.success then
        return ""
    end

    local msg = suggestion.output
    return string.format("%s %s(%s): %s",
        msg.emoji,
        msg.type,
        msg.scope,
        msg.message
    )
end

-- Crée une fenêtre d'édition pour le message de commit
function M.show_commit_editor(initial_suggestion, callback)
    -- Récupère les dimensions de la fenêtre Neovim
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")

    -- Calcule les dimensions de la fenêtre flottante
    local win_height = math.ceil(height * 0.4)
    local win_width = math.ceil(width * 0.6)
    local row = math.ceil((height - win_height) / 2)
    local col = math.ceil((width - win_width) / 2)

    -- Crée un buffer pour l'édition
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'filetype', 'gitcommit')

    -- Configuration de la fenêtre
    local win_opts = {
        style = "minimal",
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        border = "rounded",
        title = i18n.t("commit.editor.title"),
        title_pos = "center",
    }

    -- Crée la fenêtre
    local win = vim.api.nvim_open_win(buf, true, win_opts)
    vim.api.nvim_win_set_option(win, 'wrap', true)
    vim.api.nvim_win_set_option(win, 'cursorline', true)

    -- Prépare le contenu initial
    local formatted_msg = M.format_commit_message(initial_suggestion)
    local content = {
        formatted_msg,
        "",
        "# " .. i18n.t("commit.editor.help.type"),
        "# " .. i18n.t("commit.editor.help.scope"),
        "# " .. i18n.t("commit.editor.help.description"),
        "# " .. i18n.t("commit.editor.help.breaking"),
        "#",
        "# " .. i18n.t("commit.editor.help.save"),
        "# " .. i18n.t("commit.editor.help.cancel"),
    }

    -- Ajoute le contenu au buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    vim.api.nvim_win_set_cursor(win, {1, 0})

    -- Configure les mappings
    local opts = { noremap = true, silent = true, buffer = buf }
    vim.keymap.set('n', '<CR>', function()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local message = ""
        for _, line in ipairs(lines) do
            if not line:match("^#") then
                message = message .. line .. "\n"
            end
        end
        message = message:gsub("^%s*(.-)%s*$", "%1") -- Trim
        vim.api.nvim_win_close(win, true)
        if callback then
            callback(message)
        end
    end, opts)

    vim.keymap.set('n', '<Esc>', function()
        vim.api.nvim_win_close(win, true)
        if callback then
            callback(nil)
        end
    end, opts)

    -- Active le mode insertion automatiquement
    vim.cmd('startinsert')
end

-- Fonction principale pour suggérer et éditer un message de commit
function M.suggest_and_edit(callback)
    local suggestion = M.suggest_commit_message()
    if not suggestion.success then
        vim.notify(suggestion.error, vim.log.levels.ERROR)
        return
    end

    M.show_commit_editor(suggestion, function(final_message)
        if final_message then
            if callback then
                callback(final_message)
            end
        end
    end)
end

return M
