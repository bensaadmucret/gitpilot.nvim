-- Mock de l'objet vim pour les tests
local M = {}

-- Fonction deepcopy simplifiée pour les tests
function M.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[M.deepcopy(orig_key)] = M.deepcopy(orig_value)
        end
        setmetatable(copy, M.deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- Fonction tbl_deep_extend simplifiée pour les tests
function M.tbl_deep_extend(behavior, ...)
    if behavior ~= "force" and behavior ~= "keep" then
        error("invalid 'behavior': " .. tostring(behavior))
    end

    local result = {}
    for i = 1, select('#', ...) do
        local tbl = select(i, ...)
        if tbl then
            for k, v in pairs(tbl) do
                if type(v) == 'table' and type(result[k]) == 'table' then
                    result[k] = M.tbl_deep_extend(behavior, result[k], v)
                else
                    if behavior == "force" or result[k] == nil then
                        result[k] = v
                    end
                end
            end
        end
    end
    return result
end

-- Mock de la fonction vim.schedule
M.schedule = function(fn)
    fn()
end

-- Mock de la fonction vim.fn
M.fn = {
    getcwd = function()
        return '/path/to/cwd'
    end,
    expand = function(path)
        return path:gsub('%$HOME', '/home/user')
    end,
    tempname = function()
        return '/tmp/gitpilot_temp'
    end,
    delete = function(path)
        -- Mock delete file
    end,
    writefile = function(lines, path)
        -- Mock write file
    end,
    readfile = function(path)
        return {'line1', 'line2'}
    end,
    mkdir = function(path, mode)
        -- Mock mkdir
        return 1 -- Success
    end,
    stdpath = function(what)
        if what == 'data' then
            return '/tmp'
        end
        return '/tmp'
    end
}

-- Mock de vim.tbl_extend
M.tbl_extend = function(behavior, ...)
    local result = {}
    for i = 1, select('#', ...) do
        local t = select(i, ...)
        if t then
            for k, v in pairs(t) do
                if behavior == 'force' or result[k] == nil then
                    result[k] = v
                end
            end
        end
    end
    return result
end

-- Mock de vim.notify
M.notify = function(msg, level)
    -- Mock notification
end

-- Mock de vim.log.levels
M.log = {
    levels = {
        ERROR = 1,
        WARN = 2,
        INFO = 3,
        DEBUG = 4
    }
}

return M
