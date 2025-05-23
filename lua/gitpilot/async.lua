-- lua/gitpilot/async.lua
-- Module d'exécution asynchrone de commandes shell/Git pour gitpilot.nvim
-- Utilise vim.loop.spawn (libuv) pour ne pas bloquer l'UI Neovim
-- Fallback automatique sur l'exécution synchrone si libuv indisponible
-- Logs internes pour debug

local M = {}

local function log(msg)
  if vim and vim.notify then
    vim.notify('[gitpilot.async] ' .. tostring(msg), vim.log.levels.DEBUG)
  end
end

--- Exécute une commande shell de façon asynchrone
-- @param cmd string (ex: 'git status')
-- @param callback function(success, output)
function M.run_async(cmd, callback)
  local ok_vim, vim_mod = pcall(function() return vim end)
  if not ok_vim or not vim_mod then
    print('[gitpilot.async] vim non disponible')
    callback(false, 'vim non disponible')
    return
  end
  if not (vim.loop and vim.loop.spawn) then
    print('[gitpilot.async] libuv non dispo, fallback system')
    if vim.fn and vim.fn.system then
      local ok, output = pcall(vim.fn.system, cmd)
      local success = ok and vim.v.shell_error == 0
      callback(success, output)
    else
      print('[gitpilot.async] fallback impossible, ni vim.loop ni vim.fn.system')
      callback(false, 'Environnement incompatible (ni libuv ni vim.fn.system)')
    end
    return
  end
  if not (vim and vim.loop and vim.loop.spawn) then
    log('libuv non disponible, fallback sur exécution synchrone')
    -- Fallback synchrone
    local ok, output = pcall(vim.fn.system, cmd)
    local success = ok and vim.v.shell_error == 0
    callback(success, output)
    return
  end

  log('Exécution asynchrone: ' .. cmd)
  local stdout = vim.loop.new_pipe(false)
  local stderr = vim.loop.new_pipe(false)
  local output, errout = {}, {}

  local handle
  handle = vim.loop.spawn('sh', {
    args = {'-c', cmd},
    stdio = {nil, stdout, stderr},
  }, function(code, signal)
    stdout:close()
    stderr:close()
    if handle then handle:close() end
    local success = code == 0
    log('Commande terminée: code=' .. tostring(code) .. ' signal=' .. tostring(signal))
    callback(success, table.concat(output) .. table.concat(errout))
  end)

  stdout:read_start(function(err, data)
    if err then log('stdout err: ' .. tostring(err)) end
    if data then table.insert(output, data) end
  end)
  stderr:read_start(function(err, data)
    if err then log('stderr err: ' .. tostring(err)) end
    if data then table.insert(errout, data) end
  end)
end

return M
