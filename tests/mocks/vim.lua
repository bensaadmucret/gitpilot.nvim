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

return M
