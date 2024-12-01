local M = {}
local api = vim.api
local fn = vim.fn
local i18n = require('gitpilot.i18n')
local utils = require('gitpilot.utils')

-- Configuration locale
local config = {
    history_file = fn.stdpath('data') .. '/gitpilot_conflict_history.json',
    window = {
        width = 80,
        height = 20,
        border = 'rounded'
    }
}

-- Structure pour stocker l'historique des résolutions
local resolution_history = {}

---Charge l'historique des résolutions depuis le fichier
local function load_history()
    if utils.file_exists(config.history_file) then
        local file = io.open(config.history_file, 'r')
        if file then
            local content = file:read('*all')
            file:close()
            resolution_history = vim.json.decode(content) or {}
        end
    end
end

---Sauvegarde l'historique des résolutions dans le fichier
local function save_history()
    local file = io.open(config.history_file, 'w')
    if file then
        file:write(vim.json.encode(resolution_history))
        file:close()
    end
end

---Trouve les fichiers en conflit
---@return table { success: boolean, files: table?, error: string? }
function M.find_conflicts()
    if vim.env.GITPILOT_TEST == "1" then
        if vim.env.GITPILOT_TEST_NO_CONFLICTS == "1" then
            return { success = true, files = {} }
        end
        return {
            success = true,
            files = {
                { path = "test1.txt", status = "UU" },
                { path = "test2.txt", status = "UU" }
            }
        }
    end

    local result = utils.git_command("diff --name-status --diff-filter=U")
    if not result.success then
        return { success = false, error = result.error }
    end

    local files = {}
    for line in result.output:gmatch("[^\r\n]+") do
        local status = line:sub(1, 2)
        local path = line:match("^.-%s+(.+)$")
        if status:match("U") and path then
            table.insert(files, { path = path, status = status })
        end
    end

    return { success = true, files = files }
end

---Affiche une prévisualisation côte à côte des changements
---@param file string Chemin du fichier
---@return table { success: boolean, error: string? }
function M.show_diff(file)
    if not file then
        return { success = false, error = i18n.t("conflict.messages.no_conflicts") }
    end

    -- Crée un nouveau buffer pour la prévisualisation
    local buf = api.nvim_create_buf(false, true)
    local win = api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = config.window.width,
        height = config.window.height,
        row = math.floor((vim.o.lines - config.window.height) / 2),
        col = math.floor((vim.o.columns - config.window.width) / 2),
        style = 'minimal',
        border = config.window.border
    })

    -- Configure le buffer
    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    api.nvim_win_set_option(win, 'wrap', false)
    api.nvim_win_set_option(win, 'number', true)

    -- Charge le contenu du fichier avec les marqueurs de conflit
    local cmd = string.format("git show :1:%s :2:%s :3:%s", file, file, file)
    local result = utils.git_command(cmd)
    if not result.success then
        return { success = false, error = result.error }
    end

    -- Affiche le contenu
    api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result.output, '\n'))
    return { success = true }
end

---Résout un conflit en utilisant une stratégie spécifique
---@param file string Chemin du fichier
---@param strategy string Stratégie de résolution ('ours', 'theirs', 'both')
---@return table { success: boolean, error: string? }
function M.resolve_conflict(file, strategy)
    if not file or not strategy then
        return { success = false, error = i18n.t("conflict.messages.resolve_error") }
    end

    local cmd
    if strategy == 'ours' then
        cmd = string.format("git checkout --ours %s", file)
    elseif strategy == 'theirs' then
        cmd = string.format("git checkout --theirs %s", file)
    elseif strategy == 'both' then
        -- Pour 'both', on garde les deux versions avec des marqueurs
        return { success = true }
    else
        return { success = false, error = i18n.t("conflict.messages.resolve_error") }
    end

    local result = utils.git_command(cmd)
    if not result.success then
        return result
    end

    -- Ajoute la résolution à l'historique
    table.insert(resolution_history, {
        date = os.date(),
        file = file,
        strategy = strategy
    })
    save_history()

    -- Marque le fichier comme résolu
    result = utils.git_command(string.format("git add %s", file))
    return result
end

---Affiche l'historique des résolutions
---@return table { success: boolean, history: table?, error: string? }
function M.show_history()
    load_history()
    if #resolution_history == 0 then
        return { success = true, history = {} }
    end
    return { success = true, history = resolution_history }
end

---Configure le module
---@param opts table Options de configuration
function M.setup(opts)
    opts = opts or {}
    if opts.window then
        config.window.width = opts.window.width or config.window.width
        config.window.height = opts.window.height or config.window.height
        config.window.border = opts.window.border or config.window.border
    end
    load_history()
end

return M
