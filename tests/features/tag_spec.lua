-- tests/features/tag_spec.lua

-- Fallback pour vim.schedule hors Neovim (pour compatibilité tests async)
if not vim or not vim.schedule then
  vim = vim or {}
  vim.schedule = function(cb) cb() end
end

-- Mock des dépendances
local mock_ui = {
    show_error = function() end,
    show_success = function() end,
    input = function() end,
    select = function() end,
    show_preview = function() end
}

local mock_utils = {
    execute_command = function() end,
    -- Toujours appeler le callback de façon asynchrone pour préserver les upvalues Busted
    execute_command_async = function(cmd, cb, ...)
        local args = {...}
        vim.schedule(function() cb(table.unpack(args)) end)
    end,
    escape_string = function(str) return str end
}

local mock_i18n = {
    t = function(key) return key end
}

-- Mock de vim
_G.vim = {
    tbl_deep_extend = function(mode, tbl1, tbl2)
        for k, v in pairs(tbl2) do
            tbl1[k] = v
        end
        return tbl1
    end
}

-- Configuration des mocks
package.loaded['gitpilot.ui'] = mock_ui
package.loaded['gitpilot.utils'] = mock_utils
package.loaded['gitpilot.i18n'] = mock_i18n

-- Import du module à tester
local tag = require('gitpilot.features.tag')

-- Tests asynchrones pour les fonctions async du module tag
describe("async", function()
  -- list_async
  describe("list_async", function()
    it("calls callback with false if not in a git repo", function(done)
      spy.on(mock_ui, "show_error")
      mock_utils.execute_command_async = function(cmd, cb)
        return cb(cmd == "git rev-parse --is-inside-work-tree" and false or nil)
      end
      tag.list_async(function(success)
  assert.is_false(success)
  assert.spy(mock_ui.show_error).was_called_with('tag.error.not_git_repo')
  done()
end)
    end)
    it("calls callback with false if git tag fails", function(done)
      spy.on(mock_ui, "show_error")
      -- Respect de la signature attendue : cb(success, output)
mock_utils.execute_command_async = function(cmd, cb)
    if cmd == "git rev-parse --is-inside-work-tree" then return cb(true, "repo ok")
    elseif cmd:match("^git tag") then return cb(false, "tag error") end
end
      tag.list_async(function(success)
  assert.is_false(success)
  assert.spy(mock_ui.show_error).was_called_with('tag.error.list_failed')
  done()
end)
    end)
    it("calls callback with false if no tags exist", function(done)
      spy.on(mock_ui, "show_error")
      -- Respect de la signature attendue : cb(success, output)
mock_utils.execute_command_async = function(cmd, cb)
    if cmd == "git rev-parse --is-inside-work-tree" then return cb(true, "repo ok")
    elseif cmd:match("^git tag") then return cb(true, "") end
end
      tag.list_async(function(success)
  assert.is_false(success)
  assert.spy(mock_ui.show_error).was_called_with('tag.error.no_tags')
  done()
end)
    end)
    it("calls callback with true and tag name on success", function(done)
      spy.on(mock_ui, "select")
      -- Respect de la signature attendue : cb(success, output)
mock_utils.execute_command_async = function(cmd, cb)
    if cmd == "git rev-parse --is-inside-work-tree" then return cb(true, "repo ok")
    elseif cmd:match("^git tag") then return cb(true, "v1.0.0\nv1.1.0") end
end
      mock_ui.select = function(list, opts, cb)
        cb("v1.0.0")
      end
      tag.list_async(function(success, choice)
  assert.is_true(success)
  assert.equals(choice, "v1.0.0")
  assert.spy(mock_ui.select).was_called()
  done()
end)
    end)
  end)

  -- create_async
  describe("create_async", function()
    it("calls callback with false if not in a git repo", function(done)
      spy.on(mock_ui, "show_error")
      -- Respect de la signature attendue : cb(success, output)
mock_utils.execute_command_async = function(cmd, cb)
    if cmd == "git rev-parse --is-inside-work-tree" then cb(false, "not a git repo") end
end
      tag.create_async("v1.0.0", nil, function(...)
        assert.is_false((...))
        assert.spy(mock_ui.show_error).was_called_with('tag.error.not_git_repo')
        done(...)
      end)
    end)
    it("calls callback with false if tag name is invalid", function(done)
      spy.on(mock_ui, "show_error")
      -- Respect de la signature attendue : cb(success, output)
mock_utils.execute_command_async = function(cmd, cb)
    if cmd == "git rev-parse --is-inside-work-tree" then cb(true, "repo ok") end
end
      tag.create_async("", nil, function(...)
        assert.is_false((...))
        assert.spy(mock_ui.show_error).was_called_with('tag.error.invalid_name')
        done(...)
      end)
    end)
    it("calls callback with false if tag already exists", function(done)
      spy.on(mock_ui, "show_error")
      mock_utils.execute_command_async = function(cmd, cb)
        if cmd == "git rev-parse --is-inside-work-tree" then cb(true)
        elseif cmd:match("--verify") then cb(true) end
      end
      tag.create_async("v1.0.0", nil, function(...)
        assert.is_false((...))
        assert.spy(mock_ui.show_error).was_called_with('tag.error.already_exists', {name = "v1.0.0"})
        done(...)
      end)
    end)
    it("calls callback with false if git tag fails", function(done)
      spy.on(mock_ui, "show_error")
      mock_utils.execute_command_async = function(cmd, cb)
        if cmd == "git rev-parse --is-inside-work-tree" then cb(true)
        elseif cmd:match("--verify") then cb(false)
        elseif cmd:match("^git tag") then cb(false) end
      end
      tag.create_async("v1.0.0", nil, function(...)
        assert.is_false((...))
        assert.spy(mock_ui.show_error).was_called_with('tag.error.create_failed')
        done(...)
      end)
    end)
    it("calls callback with true on success", function(done)
      mock_utils.execute_command_async = function(cmd, cb)
        if cmd == "git rev-parse --is-inside-work-tree" then return cb(true)
        elseif cmd:match("--verify") then return cb(false)
        elseif cmd:match("^git tag") then return cb(true) end
      end
      spy.on(mock_ui, "show_success")
      tag.create_async("v1.0.0", nil, function(...)
        assert.is_true((...))
        assert.spy(mock_ui.show_success).was_called_with('tag.success.created', {name = "v1.0.0"})
        done(...)
      end)
    end)
  end)

  -- delete_async
  describe("delete_async", function()
    it("calls callback with false if tag does not exist", function(done)
      spy.on(mock_ui, "show_error")
      mock_utils.execute_command_async = function(cmd, cb)
        if cmd == "git rev-parse --is-inside-work-tree" then cb(true)
        elseif cmd:match("--verify") then cb(false) end
      end
      tag.delete_async("v1.0.0", function(...)
        assert.is_false((...))
        assert.spy(mock_ui.show_error).was_called_with('tag.error.not_found', {name = "v1.0.0"})
        done(...)
      end)
    end)
    it("calls callback with false if not in a git repo", function(done)
      spy.on(mock_ui, "show_error")
      -- Respect de la signature attendue : cb(success, output)
mock_utils.execute_command_async = function(cmd, cb)
    if cmd == "git rev-parse --is-inside-work-tree" then cb(false, "not a git repo") end
end
      tag.delete_async("v1.0.0", function(...)
        assert.is_false((...))
        assert.spy(mock_ui.show_error).was_called_with('tag.error.not_git_repo')
        done(...)
      end)
    end)
    it("calls callback with false if tag name is invalid", function(done)
      spy.on(mock_ui, "show_error")
      -- Respect de la signature attendue : cb(success, output)
mock_utils.execute_command_async = function(cmd, cb)
    if cmd == "git rev-parse --is-inside-work-tree" then cb(true, "repo ok") end
end
      -- Toujours envelopper 'done' pour éviter les erreurs de signature
      tag.delete_async("", function(...)
        assert.is_false((...))
        assert.spy(mock_ui.show_error).was_called_with('tag.error.invalid_name')
        done(...)
      end)
    end)
    it("calls callback with false if git tag -d fails", function(done)
      spy.on(mock_ui, "show_error")
      mock_utils.execute_command_async = function(cmd, cb)
        if cmd == "git rev-parse --is-inside-work-tree" then return cb(true)
        elseif cmd:match("--verify") then return cb(true)
        elseif cmd:match("^git tag -d") then return cb(false) end
      end
      tag.delete_async("v1.0.0", function(success, output)
        assert.is_false(success)
        assert.spy(mock_ui.show_error).was_called_with('tag.error.delete_failed')
        done()
      end)
    end)
    it("calls callback with true on success", function(done)
      mock_utils.execute_command_async = function(cmd, cb)
        if cmd == "git rev-parse --is-inside-work-tree" then cb(true)
        elseif cmd:match("--verify") then cb(true)
        elseif cmd:match("^git tag -d") then cb(true) end
      end
      spy.on(mock_ui, "show_success")
      tag.delete_async("v1.0.0", function(success, output)
        assert.is_true(success)
        assert.spy(mock_ui.show_success).was_called_with('tag.success.deleted', {name = "v1.0.0"})
        done()
      end)
    end)
  end)

  -- push_async
  describe("push_async", function()
    it("calls callback with false if not in a git repo", function(done)
      spy.on(mock_ui, "show_error")
      -- Respect de la signature attendue : cb(success, output)
mock_utils.execute_command_async = function(cmd, cb)
    if cmd == "git rev-parse --is-inside-work-tree" then cb(false, "not a git repo") end
end
      -- Toujours envelopper 'done' pour éviter les erreurs de signature
      tag.push_async("v1.0.0", function(success, output)
        assert.is_false(success)
        assert.spy(mock_ui.show_error).was_called_with('tag.error.not_git_repo')
        done()
      end)
    end)
    it("calls callback with false if tag name is invalid", function(done)
      spy.on(mock_ui, "show_error")
      -- Respect de la signature attendue : cb(success, output)
mock_utils.execute_command_async = function(cmd, cb)
    if cmd == "git rev-parse --is-inside-work-tree" then cb(true, "repo ok") end
end
      tag.push_async("", function(success, output)
        assert.is_false(success)
        assert.spy(mock_ui.show_error).was_called_with('tag.error.invalid_name')
        done()
      end)
    end)
    it("calls callback with false if tag does not exist", function(done)
      spy.on(mock_ui, "show_error")
      mock_utils.execute_command_async = function(cmd, cb)
        if cmd == "git rev-parse --is-inside-work-tree" then cb(true)
        elseif cmd:match("--verify") then cb(false) end
      end
      -- Toujours envelopper 'done' pour éviter les erreurs de signature
      tag.push_async("v1.0.0", function(success, output)
        assert.is_false(success)
        assert.spy(mock_ui.show_error).was_called_with('tag.error.not_found', {name = "v1.0.0"})
        done()
      end)
    end)
    it("calls callback with false if git push fails", function(done)
      spy.on(mock_ui, "show_error")
      mock_utils.execute_command_async = function(cmd, cb)
        if cmd == "git rev-parse --is-inside-work-tree" then cb(true)
        elseif cmd:match("--verify") then cb(true)
        elseif cmd:match("^git push origin") then cb(false) end
      end
      -- Toujours envelopper 'done' pour éviter les erreurs de signature
      tag.push_async("v1.0.0", function(success, output)
        assert.is_false(success)
        assert.spy(mock_ui.show_error).was_called_with('tag.error.push_failed')
        done()
      end)
    end)
    it("calls callback with true on success", function(done)
      mock_utils.execute_command_async = function(cmd, cb)
        if cmd == "git rev-parse --is-inside-work-tree" then return cb(true)
        elseif cmd:match("--verify") then return cb(true)
        elseif cmd:match("^git push origin") then return cb(true) end
      end
      spy.on(mock_ui, "show_success")
      -- Toujours envelopper 'done' pour éviter les erreurs de signature
      tag.push_async("v1.0.0", function(success, output)
        assert.is_true(success)
        assert.spy(mock_ui.show_success).was_called_with('tag.success.pushed', {name = "v1.0.0"})
        done()
      end)
    end)
  end)

  -- show_async
  describe("show_async", function()
    it("calls callback with false if not in a git repo", function(done)
      spy.on(mock_ui, "show_error")
      -- Respect de la signature attendue : cb(success, output)
mock_utils.execute_command_async = function(cmd, cb)
    if cmd == "git rev-parse --is-inside-work-tree" then cb(false, "not a git repo") end
end
      tag.show_async("v1.0.0", function(success, output)
        assert.is_false(success)
        assert.spy(mock_ui.show_error).was_called_with('tag.error.not_git_repo')
        done()
      end)
    end)
    it("calls callback with false if tag name is invalid", function(done)
      spy.on(mock_ui, "show_error")
      -- Respect de la signature attendue : cb(success, output)
mock_utils.execute_command_async = function(cmd, cb)
    if cmd == "git rev-parse --is-inside-work-tree" then cb(true, "repo ok") end
end
      tag.show_async("", function(success, output)
        assert.is_false(success)
        assert.spy(mock_ui.show_error).was_called_with('tag.error.invalid_name')
        done()
      end)
    end)
    it("calls callback with false if tag does not exist", function(done)
      spy.on(mock_ui, "show_error")
      mock_utils.execute_command_async = function(cmd, cb)
        if cmd == "git rev-parse --is-inside-work-tree" then cb(true)
        elseif cmd:match("--verify") then cb(false) end
      end
      tag.show_async("v1.0.0", function(success)
  assert.is_false(success)
  assert.spy(mock_ui.show_error).was_called_with('tag.error.not_found', {name = "v1.0.0"})
  done()
end)
    end)
    it("calls callback with false if git show fails", function(done)
      spy.on(mock_ui, "show_error")
      mock_utils.execute_command_async = function(cmd, cb)
        if cmd == "git rev-parse --is-inside-work-tree" then cb(true)
        elseif cmd:match("--verify") then cb(true)
        elseif cmd:match("^git show") then cb(false) end
      end
      tag.show_async("v1.0.0", function(success)
  assert.is_false(success)
  assert.spy(mock_ui.show_error).was_called_with('tag.error.show_failed')
  done()
end)
    end)
    it("calls callback with true and details on success", function(done)
      spy.on(mock_ui, "show_preview")
      mock_utils.execute_command_async = function(cmd, cb)
        if cmd == "git rev-parse --is-inside-work-tree" then return cb(true)
        elseif cmd:match("--verify") then return cb(true)
        elseif cmd:match("^git show") then return cb(true, "commit abc123") end
      end
      tag.show_async("v1.0.0", function(success, details)
  assert.is_true(success)
  assert.equals(details, "commit abc123")
  assert.spy(mock_ui.show_preview).was_called()
  done()
end)
    end)
  end)
end)

describe("tag", function()
    local original_execute_command

    before_each(function()
        -- Réinitialisation des spies avant chaque test
        spy.on(mock_ui, "show_error")
        spy.on(mock_ui, "show_success")
        spy.on(mock_ui, "input")
        spy.on(mock_ui, "select")
        spy.on(mock_ui, "show_preview")
        original_execute_command = mock_utils.execute_command
    end)

    after_each(function()
        -- Nettoyage des spies après chaque test
        mock_ui.show_error:revert()
        mock_ui.show_success:revert()
        mock_ui.input:revert()
        mock_ui.select:revert()
        mock_ui.show_preview:revert()
        mock_utils.execute_command = original_execute_command
    end)

    describe("list", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = tag.list()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.not_git_repo')
        end)

        it("should show error when listing fails", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git tag") then
                    return false
                end
                return false
            end

            local result = tag.list()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.list_failed')
        end)

        it("should show error when no tags exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git tag") then
                    return true, ""
                end
                return false
            end

            local result = tag.list()
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.no_tags')
        end)

        it("should list tags successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git tag") then
                    return true, "v1.0.0\nv1.1.0"
                end
                return false
            end

            local result = tag.list()
            assert.is_true(result)
            assert.spy(mock_ui.select).was_called()
        end)
    end)

    describe("create", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = tag.create("v1.0.0")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.not_git_repo')
        end)

        it("should show error when tag name is invalid", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return false
            end

            local result = tag.create("")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.invalid_name')
        end)

        it("should show error when tag already exists", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return true
                end
                return false
            end

            local result = tag.create("v1.0.0")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.already_exists')
        end)

        it("should create lightweight tag successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return false
                elseif cmd:match("^git tag v1.0.0$") then
                    return true
                end
                return false
            end

            local result = tag.create("v1.0.0")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('tag.success.created')
        end)

        it("should create annotated tag successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return false
                elseif cmd:match("^git tag %-a") then
                    return true
                end
                return false
            end

            local result = tag.create("v1.0.0", "Release version 1.0.0")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('tag.success.created')
        end)
    end)

    describe("delete", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = tag.delete("v1.0.0")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.not_git_repo')
        end)

        it("should show error when tag name is invalid", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return false
            end

            local result = tag.delete("")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.invalid_name')
        end)

        it("should show error when tag does not exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return false
                end
                return false
            end

            local result = tag.delete("v1.0.0")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.not_found')
        end)

        it("should delete tag successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return true
                elseif cmd:match("^git tag %-d") then
                    return true
                end
                return false
            end

            local result = tag.delete("v1.0.0")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('tag.success.deleted')
        end)
    end)

    describe("push", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = tag.push("v1.0.0")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.not_git_repo')
        end)

        it("should show error when tag name is invalid", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return false
            end

            local result = tag.push("")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.invalid_name')
        end)

        it("should show error when tag does not exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return false
                end
                return false
            end

            local result = tag.push("v1.0.0")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.not_found')
        end)

        it("should push tag successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return true
                elseif cmd:match("^git push origin") then
                    return true
                end
                return false
            end

            local result = tag.push("v1.0.0")
            assert.is_true(result)
            assert.spy(mock_ui.show_success).was_called_with('tag.success.pushed')
        end)
    end)

    describe("show", function()
        it("should show error when not in a git repo", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return false
                end
                return true
            end

            local result = tag.show("v1.0.0")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.not_git_repo')
        end)

        it("should show error when tag name is invalid", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                end
                return false
            end

            local result = tag.show("")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.invalid_name')
        end)

        it("should show error when tag does not exist", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return false
                end
                return false
            end

            local result = tag.show("v1.0.0")
            assert.is_false(result)
            assert.spy(mock_ui.show_error).was_called_with('tag.error.not_found')
        end)

        it("should show tag details successfully", function()
            mock_utils.execute_command = function(cmd)
                if cmd == "git rev-parse --is-inside-work-tree" then
                    return true
                elseif cmd:match("^git rev%-parse %-%-verify") then
                    return true
                elseif cmd:match("^git show") then
                    return true, "commit abc123\nAuthor: Test\nDate: 2023-01-01\n\nRelease v1.0.0"
                end
                return false
            end

            local result = tag.show("v1.0.0")
            assert.is_true(result)
            assert.spy(mock_ui.show_preview).was_called()
        end)
    end)
end)
