-- Mock de l'API Neovim pour les tests
local M = {}

-- Table pour stocker les mocks
local mocks = {
    api = {},
    fn = {},
    cmd = {},
    g = {},
    env = {},
    o = {},
    log = {},
    levels = {},
    notify = {},
    schedule = {}
}

-- Mock de base de l'API Neovim
local api = {
    nvim_create_buf = function(listed, scratch)
        return 1
    end,
    nvim_buf_set_lines = function(bufnr, start, end_, strict, lines)
        return true
    end,
    nvim_win_get_cursor = function(win)
        return {1, 0}
    end,
    nvim_win_set_cursor = function(win, pos)
        return true
    end,
    nvim_buf_get_lines = function(bufnr, start, end_, strict)
        return {}
    end,
    nvim_command = function(cmd)
        return true
    end,
    nvim_get_current_buf = function()
        return 1
    end,
    nvim_get_current_win = function()
        return 1
    end,
    nvim_win_get_buf = function(win)
        return 1
    end,
    nvim_buf_get_name = function(bufnr)
        return ""
    end,
    nvim_create_namespace = function(name)
        return 1
    end,
    nvim_buf_set_extmark = function(bufnr, ns_id, line, col, opts)
        return 1
    end,
    nvim_echo = function(chunks, history, opts)
        return true
    end,
    nvim_err_writeln = function(msg)
        return true
    end,
    nvim_open_win = function(buf, enter, config)
        return 1
    end,
    nvim_win_set_config = function(win, config)
        return true
    end,
    nvim_win_close = function(win, force)
        return true
    end,
    nvim_buf_set_option = function(buf, name, value)
        return true
    end,
    nvim_win_set_option = function(win, name, value)
        return true
    end,
    nvim_create_augroup = function(name, opts)
        return 1
    end,
    nvim_create_autocmd = function(events, opts)
        return 1
    end,
    nvim_win_get_height = function(win)
        return 24
    end,
    nvim_win_get_width = function(win)
        return 80
    end
}

-- Mock des fonctions Vim
local fn = {
    bufwinnr = function(buf)
        return 1
    end,
    expand = function(expr)
        return ""
    end,
    fnamemodify = function(fname, mods)
        return fname
    end,
    getcwd = function()
        return "/test/path"
    end,
    systemlist = function(cmd)
        return {}
    end,
    system = function(cmd)
        return ""
    end
}

-- Mock des options Vim
local o = {
    columns = 80,
    lines = 24,
    cmdheight = 1
}

-- Mock du système de log
local log = {
    info = function(msg) end,
    warn = function(msg) end,
    error = function(msg) end,
    debug = function(msg) end,
    levels = {
        DEBUG = 0,
        INFO = 1,
        WARN = 2,
        ERROR = 3
    }
}

-- Mock de la fonction notify
local notify = function(msg, level, opts)
    return 1
end

-- Mock de la fonction schedule
local schedule = function(fn)
    fn()
end

-- Utilitaires pour la manipulation des tables
local function tbl_extend(behavior, ...)
    local result = {}
    for i = 1, select('#', ...) do
        local t = select(i, ...)
        for k, v in pairs(t) do
            result[k] = v
        end
    end
    return result
end

local function tbl_deep_extend(behavior, ...)
    local result = {}
    for i = 1, select('#', ...) do
        local t = select(i, ...)
        if type(t) == 'table' then
            for k, v in pairs(t) do
                if type(v) == 'table' and type(result[k]) == 'table' then
                    result[k] = tbl_deep_extend(behavior, result[k], v)
                else
                    result[k] = v
                end
            end
        end
    end
    return result
end

-- Configuration initiale de l'environnement de test
function M.setup()
    -- Initialise _G.vim s'il n'existe pas
    if not _G.vim then
        _G.vim = {}
    end

    -- Mock des fonctions de base
    _G.vim.tbl_extend = tbl_extend
    _G.vim.tbl_deep_extend = tbl_deep_extend
    _G.vim.split = function(s, sep, opts)
        local result = {}
        local pattern = string.format("[^%s]+", sep)
        for word in string.gmatch(s, pattern) do
            table.insert(result, word)
        end
        return result
    end
    _G.vim.stdpath = function(what)
        return "/test/path/" .. what
    end
    _G.vim.notify = notify
    _G.vim.schedule = schedule

    -- Mock des composants principaux
    _G.vim.api = tbl_extend("force", api, mocks.api)
    _G.vim.fn = tbl_extend("force", fn, mocks.fn)
    _G.vim.cmd = function(cmd) return true end
    _G.vim.g = mocks.g
    _G.vim.env = mocks.env
    _G.vim.o = tbl_extend("force", o, mocks.o)
    _G.vim.log = tbl_extend("force", log, mocks.log)
    _G.vim.levels = log.levels
end

-- Réinitialise tous les mocks
function M.reset()
    mocks.api = {}
    mocks.fn = {}
    mocks.cmd = {}
    mocks.g = {}
    mocks.env = {}
    mocks.o = {}
    mocks.log = {}
    mocks.levels = {}
    mocks.notify = {}
    mocks.schedule = {}
    M.setup()
end

-- Configure un mock spécifique
function M.mock(category, name, implementation)
    if category == "api" then
        mocks.api[name] = implementation
    elseif category == "fn" then
        mocks.fn[name] = implementation
    elseif category == "cmd" then
        mocks.cmd[name] = implementation
    elseif category == "g" then
        mocks.g[name] = implementation
    elseif category == "env" then
        mocks.env[name] = implementation
    elseif category == "o" then
        mocks.o[name] = implementation
    elseif category == "log" then
        mocks.log[name] = implementation
    elseif category == "notify" then
        mocks.notify[name] = implementation
    elseif category == "schedule" then
        mocks.schedule[name] = implementation
    end
    M.setup()
end

-- Initialise l'environnement de test
M.setup()

return M
