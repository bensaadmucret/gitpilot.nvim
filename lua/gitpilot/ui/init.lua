-- lua/gitpilot/ui/init.lua

local M = {}
local api = vim.api
local fn = vim.fn

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

-- Affiche un message d'erreur dans une fenêtre modale
function M.show_error(title, message)
    local lines = {}
    -- Ajoute une ligne vide au début
    table.insert(lines, "")
    -- Ajoute le message d'erreur
    for line in message:gmatch("[^\r\n]+") do
        table.insert(lines, " " .. line)
    end
    -- Ajoute une ligne vide à la fin
    table.insert(lines, "")
    -- Ajoute une instruction pour fermer
    table.insert(lines, " Appuyez sur 'q' ou <Esc> pour fermer")
    
    M.create_floating_window(lines, {
        title = " " .. title .. " ",
        border = 'rounded',
    })
end

-- Affiche un message d'information dans une fenêtre modale
function M.show_info(title, message)
    local lines = {}
    -- Ajoute une ligne vide au début
    table.insert(lines, "")
    -- Ajoute le message
    for line in message:gmatch("[^\r\n]+") do
        table.insert(lines, " " .. line)
    end
    -- Ajoute une ligne vide à la fin
    table.insert(lines, "")
    -- Ajoute une instruction pour fermer
    table.insert(lines, " Appuyez sur 'q' ou <Esc> pour fermer")
    
    M.create_floating_window(lines, {
        title = " " .. title .. " ",
        border = 'single',
    })
end

return M
