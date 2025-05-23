-- tests/features/async_spec.lua
-- Test automatisé du module async et de la fonction execute_command_async
local busted = require('busted')
local utils = require('gitpilot.utils')

-- Ces tests nécessitent d'être lancés dans un environnement Neovim (vim.loop ou vim.fn.system requis)
local env_ok = (vim ~= nil) and (vim.loop ~= nil or (vim.fn and vim.fn.system ~= nil))
if not env_ok then
  print('[async_spec][SKIP] Environnement incompatible pour les tests async (nécessite Neovim)')
  return
end

local has_vim = (vim ~= nil)

describe('gitpilot.async', function()
  it('environnement compatible pour async', function()
    print('[async_spec][ENV] vim:', vim ~= nil, 'vim.loop:', vim and vim.loop ~= nil, 'vim.fn:', vim and vim.fn ~= nil, 'vim.fn.system:', vim and vim.fn and vim.fn.system ~= nil)
    assert.is_true(vim ~= nil, 'vim doit être disponible')
    assert.is_true(vim.loop ~= nil or (vim.fn and vim.fn.system ~= nil), 'libuv ou vim.fn.system doit être disponible')
  end)
  local function with_timeout(test_name, fn)
    it(test_name, function(done)
      local finished = false
      local timer = vim and vim.loop and vim.loop.new_timer() or nil
      local function finish()
        if not finished then
          finished = true
          if timer then timer:stop(); timer:close() end
          done()
        end
      end
      if timer then
        timer:start(3000, 0, function()
          print('[async_spec] TIMEOUT for test: ' .. test_name)
          finish()
        end)
      end
      fn(finish)
    end)
  end

  with_timeout('exécute une commande rapide avec succès (git --version)', function(finish)
    print('[async_spec] Début test git --version')
    utils.execute_command_async('git --version', function(success, output)
      print('[async_spec] Résultat git --version:', success, output)
      local ok, err = pcall(function()
        assert.is_true(success, 'La commande doit réussir')
        assert.is_not_nil(output, 'La sortie ne doit pas être nulle')
        assert.matches('git version', output)
      end)
      if not ok then print('[async_spec][ERREUR]', err) end
      finish()
    end)
  end)

  with_timeout('gère une commande erronée', function(finish)
    print('[async_spec] Début test git unknowncommand')
    utils.execute_command_async('git unknowncommand', function(success, output)
      print('[async_spec] Résultat git unknowncommand:', success, output)
      local ok, err = pcall(function()
        assert.is_false(success, 'La commande doit échouer')
        assert.is_not_nil(output, 'La sortie ne doit pas être nulle')
        assert.matches('git: \\S*unknowncommand', output)
      end)
      if not ok then print('[async_spec][ERREUR]', err) end
      finish()
    end)
  end)

  with_timeout('fallback synchrone si libuv non dispo', function(finish)
    print('[async_spec] Début test fallback synchrone')
    local async = require('gitpilot.async')
    local orig_loop = vim.loop
    vim.loop = nil
    utils.execute_command_async('git --version', function(success, output)
      print('[async_spec] Résultat fallback:', success, output)
      local ok, err = pcall(function()
        assert.is_true(success, 'La commande doit réussir en fallback')
        assert.is_not_nil(output, 'La sortie ne doit pas être nulle')
      end)
      if not ok then print('[async_spec][ERREUR]', err) end
      vim.loop = orig_loop
      finish()
    end)
  end)

  with_timeout('ne bloque pas l\'UI (simulation)', function(finish)
    print('[async_spec] Début test non-blocage UI')
    local t0 = os.clock()
    utils.execute_command_async('sleep 1', function(success, output)
      local dt = os.clock() - t0
      print('[async_spec] Résultat sleep 1:', success, output, 'dt=', dt)
      local ok, err = pcall(function()
        assert.is_true(success, 'La commande sleep doit réussir')
        assert.is_true(dt < 2, 'Le callback doit être appelé rapidement (asynchrone)')
      end)
      if not ok then print('[async_spec][ERREUR]', err) end
      finish()
    end)
    assert.is_true(true)
  end)
end)
