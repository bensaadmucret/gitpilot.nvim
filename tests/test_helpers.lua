-- Mock de l'environnement Neovim pour les tests
local M = {}

-- Configuration globale pour les tests
M.config = {
    test_mode = true,
    input_response = nil,
    select_response = nil,
    last_notification = nil
}

-- Mock de l'objet vim global
_G.vim = {
    g = {},
    b = {},
    w = {},
    o = {
        lines = 24,
        columns = 80
    },
    fn = {
        expand = function(path)
            return path:gsub('%$HOME', os.getenv('HOME'))
        end,
        getcwd = function()
            return os.getenv('PWD') or '.'
        end,
        system = function(cmd)
            local handle = io.popen(cmd)
            if not handle then return '' end
            local result = handle:read('*a')
            handle:close()
            return result
        end,
        input = function(prompt, default)
            return M.config.input_response or default or ""
        end
    },
    api = {
        nvim_create_buf = function(listed, scratch)
            return 1
        end,
        nvim_buf_set_lines = function(bufnr, start, end_, strict, lines)
            -- No-op pour les tests
        end,
        nvim_win_get_cursor = function(win)
            return {1, 0}
        end,
        nvim_win_set_cursor = function(win, pos)
            -- No-op pour les tests
        end,
        nvim_command = function(cmd)
            -- No-op pour les tests
        end,
        nvim_create_autocmd = function(event, opts)
            -- No-op pour les tests
        end,
        nvim_win_close = function(win, force)
            -- No-op pour les tests
        end,
        nvim_buf_delete = function(bufnr, opts)
            -- No-op pour les tests
        end,
        nvim_open_win = function(bufnr, enter, config)
            return 1
        end,
        nvim_win_set_config = function(win, config)
            -- No-op pour les tests
        end,
        nvim_buf_set_option = function(bufnr, name, value)
            -- No-op pour les tests
        end,
        nvim_win_set_option = function(win, name, value)
            -- No-op pour les tests
        end,
        nvim_buf_get_lines = function(bufnr, start, end_, strict)
            return {}
        end
    },
    log = {
        levels = {
            ERROR = "error",
            WARN = "warn",
            INFO = "info",
            DEBUG = "debug"
        }
    },
    notify = function(msg, level)
        M.config.last_notification = {
            message = msg,
            level = level
        }
    end,
    ui = {
        select = function(items, opts, on_choice)
            if M.config.select_response then
                on_choice(M.config.select_response, 1)
            else
                on_choice(nil, -1)
            end
        end,
        input = function(opts, on_confirm)
            if M.config.input_response then
                on_confirm(M.config.input_response)
            else
                on_confirm(nil)
            end
        end
    },
    keymap = {
        set = function(mode, lhs, rhs, opts)
            -- No-op pour les tests
        end
    },
    schedule = function(fn)
        fn()
    end
}

-- Initialisation des modules
local ui = require('gitpilot.ui')
ui.setup({
    ui = {
        window = {
            width = 60,
            height = 20,
            border = 'rounded'
        }
    }
})

-- Fonctions utilitaires pour les tests
M.set_input_response = function(response)
    M.config.input_response = response
end

M.set_select_response = function(response)
    M.config.select_response = response
end

M.reset = function()
    M.config.input_response = nil
    M.config.select_response = nil
    M.config.last_notification = nil
end

-- Configuration de l'environnement de test
M.setup_test_environment = function()
    -- Réinitialiser les mocks et les configurations
    M.config.input_response = nil
    M.config.select_response = nil
    M.config.last_notification = nil
    
    -- Créer un dépôt git temporaire pour les tests
    local temp_dir = os.tmpname()
    os.remove(temp_dir)  -- tmpname crée le fichier, nous voulons un répertoire
    os.execute("mkdir -p " .. temp_dir)
    os.execute("cd " .. temp_dir .. " && git init")
    
    -- Stocker le répertoire temporaire pour le nettoyage
    M.config.temp_dir = temp_dir
    
    return temp_dir
end

-- Nettoyage de l'environnement de test
M.teardown_test_environment = function()
    -- Supprimer le dépôt git temporaire
    if M.config.temp_dir then
        os.execute("rm -rf " .. M.config.temp_dir)
        M.config.temp_dir = nil
    end
    
    -- Réinitialiser les mocks
    M.config.input_response = nil
    M.config.select_response = nil
    M.config.last_notification = nil
end

-- Fonction d'assertion personnalisée pour les notifications
M.assert_notification = function(expected_level, expected_message_pattern)
    assert(M.config.last_notification, "No notification was sent")
    assert(M.config.last_notification.level == vim.log.levels[string.upper(expected_level)],
        string.format("Expected notification level '%s', got '%s'",
            expected_level, M.config.last_notification.level))
    
    if expected_message_pattern then
        assert(M.config.last_notification.message:match(expected_message_pattern),
            string.format("Expected message matching '%s', got '%s'",
                expected_message_pattern, M.config.last_notification.message))
    end
end

-- Mock de la fenêtre flottante
M.mock_floating_window = function(opts)
    opts = opts or {}
    M.mock_floating_window.files_selected = false

    -- Sauvegarder les fonctions originales
    local original_create_buf = vim.api.nvim_create_buf
    local original_create_win = vim.api.nvim_open_win
    local original_set_keymap = vim.keymap.set
    
    -- Mock de création de buffer
    vim.api.nvim_create_buf = function(listed, scratch)
        return 1
    end
    
    -- Mock de création de fenêtre
    vim.api.nvim_open_win = function(bufnr, enter, config)
        local buf, win
        if opts.on_create then
            buf, win = opts.on_create(bufnr, M.mock_floating_window.lines or {})
        end
        return win or 1
    end
    
    -- Mock de définition des raccourcis
    vim.keymap.set = function(mode, key, callback, options)
        if opts.on_keymap then
            local result = opts.on_keymap(mode, key)
            if result then
                if type(callback) == "function" then
                    return callback(result)
                end
                return result
            end
        end
    end
    
    -- Fonction de restauration
    return function()
        vim.api.nvim_create_buf = original_create_buf
        vim.api.nvim_open_win = original_create_win
        vim.keymap.set = original_set_keymap
    end
end

return M
