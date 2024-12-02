-- lua/gitpilot/ui/init.lua

local M = {}

-- Check if we're in Neovim
local function check_neovim()
    local has_nvim, _ = pcall(function() return vim ~= nil and vim.api ~= nil end)
    if not has_nvim then
        error("GitPilot requires Neovim")
    end
end

-- Default notification levels
M.levels = {
    ERROR = 3,
    WARN = 2,
    INFO = 1,
    DEBUG = 0
}

-- Initialize the module with vim levels if available
local function init_levels()
    if vim and vim.log and vim.log.levels then
        M.levels = vim.log.levels
    end
end

-- Initialize the module
function M.setup()
    check_neovim()
    init_levels()
end

-- Configuration par défaut de la fenêtre
local default_opts = {
    relative = 'editor',
    style = 'minimal',
    border = 'rounded',
    title = ' GitPilot ',
    title_pos = 'center',
}

-- Crée une fenêtre flottante
function M.create_floating_window(content, opts)
    opts = vim.tbl_deep_extend('force', default_opts, opts or {})
    
    -- Calcule les dimensions de la fenêtre
    local width = 0
    local height = 0
    local lines = {}
    
    if type(content) == 'string' then
        lines = vim.split(content, '\n')
    else
        lines = content
    end
    
    -- Calcule la largeur maximale
    for _, line in ipairs(lines) do
        width = math.max(width, vim.fn.strdisplaywidth(line))
    end
    height = #lines
    
    -- Ajoute de la marge
    width = width + 4
    height = height + 2
    
    -- Calcule la position
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    -- Configure la fenêtre
    local win_opts = {
        relative = opts.relative,
        width = width,
        height = height,
        row = row,
        col = col,
        style = opts.style,
        border = opts.border,
        title = opts.title,
        title_pos = opts.title_pos,
    }
    
    -- Crée le buffer
    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    
    -- Insère le contenu
    api.nvim_buf_set_lines(buf, 0, -1, true, lines)
    
    -- Crée la fenêtre
    local win = api.nvim_open_win(buf, true, win_opts)
    
    -- Configure les options de la fenêtre
    api.nvim_win_set_option(win, 'wrap', false)
    api.nvim_win_set_option(win, 'cursorline', true)
    
    -- Ajoute une commande pour fermer la fenêtre avec q ou <Esc>
    api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', {noremap = true, silent = true})
    api.nvim_buf_set_keymap(buf, 'n', '<Esc>', ':close<CR>', {noremap = true, silent = true})
    
    return buf, win
end

-- Show notification with translation
local function show_notification(key, vars, level)
    if not level then level = M.levels.INFO end
    
    local i18n = require('gitpilot.i18n')
    local message = i18n.t(key, vars)
    
    if message then
        if vim and vim.notify then
            vim.notify(message, level)
        end
    end
end

-- Show error message
function M.show_error(key, vars)
    show_notification(key, vars, M.levels.ERROR)
end

-- Show info message
function M.show_info(key, vars)
    show_notification(key, vars, M.levels.INFO)
end

-- Show warning message
function M.show_warn(key, vars)
    show_notification(key, vars, M.levels.WARN)
end

-- Select from a list of items
function M.select(items, opts, on_choice)
    opts = opts or {}
    if not items or #items == 0 then
        M.show_warning("ui.no_items")
        return
    end

    vim.ui.select(items, {
        prompt = opts.prompt or "",
        format_item = opts.format_item or function(item) return item end
    }, function(choice)
        if choice and on_choice then
            on_choice(choice)
        end
    end)
end

-- Format message with variables
function M.format_message(message, vars)
    if not message then return "" end
    if not vars then return message end

    return message:gsub("%%{([^}]+)}", function(var)
        return vars[var] or ""
    end)
end

-- Notify wrapper for compatibility
function M.notify(message, level, opts)
    opts = opts or {}
    if type(message) == "string" then
        vim.notify(message, level, opts)
    end
end

-- Ensure module is initialized
M.setup()

return M
