-- tests/features/history_spec.lua
-- Tests de couverture complète pour les fonctions asynchrones de l’historique du module gitpilot

local busted = require('busted')
local history = require('gitpilot.features.history')
local async = require('gitpilot.async')

-- Utilitaire pour attendre un callback asynchrone avec timeout
local function wait_async(test_fn, timeout)
  local done = false
  local result = nil
  test_fn(function(...) result = {...}; done = true end)
  local start = os.time()
  while not done and os.difftime(os.time(), start) < (timeout or 5) do
    vim.wait(50)
  end
  return table.unpack(result or {})
end

-- Skip si pas d'environnement Neovim compatible async
if not vim or not vim.loop or not async then
  describe('gitpilot.history (async)', function()
    it('skip: environnement asynchrone non compatible', function()
      assert.is_true(true)
    end)
  end)
  return
end

describe('gitpilot.history (fonctions asynchrones)', function()
  it('get_commits_async: retourne une liste de commits', function()
    local ok, commits = wait_async(function(cb)
      history.get_commits_async({}, cb)
    end, 5)
    assert.is_true(ok)
    assert.is_table(commits)
    assert.is_not_nil(commits[1])
    assert.is_not_nil(commits[1].hash)
  end)

  it('get_commit_details_async: retourne les détails d\'un commit', function()
    local ok, commits = wait_async(function(cb)
      history.get_commits_async({}, cb)
    end, 5)
    assert.is_true(ok)
    local hash = commits[1] and commits[1].hash
    assert.is_not_nil(hash)
    local ok2, details = wait_async(function(cb)
      history.get_commit_details_async(hash, cb)
    end, 5)
    assert.is_true(ok2)
    assert.is_not_nil(details)
    assert.is_not_nil(details.hash)
    assert.is_table(details.files)
  end)

  it('get_graph_async: retourne un graphe', function()
    local ok, graph = wait_async(function(cb)
      history.get_graph_async({}, cb)
    end, 5)
    assert.is_true(ok)
    assert.is_table(graph)
  end)

  it('search_commits_async: retourne une liste de commits filtrés', function()
    local ok, commits = wait_async(function(cb)
      history.search_commits_async('fix', {}, cb)
    end, 5)
    assert.is_boolean(ok)
    assert.is_table(commits)
  end)

  it('get_commit_stats_async: retourne les stats d\'un commit', function()
    local ok, commits = wait_async(function(cb)
      history.get_commits_async({}, cb)
    end, 5)
    assert.is_true(ok)
    local hash = commits[1] and commits[1].hash
    assert.is_not_nil(hash)
    local ok2, stats = wait_async(function(cb)
      history.get_commit_stats_async(hash, cb)
    end, 5)
    assert.is_boolean(ok2)
    assert.is_table(stats)
  end)
end)
