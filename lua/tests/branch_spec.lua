-- lua/tests/branch_spec.lua

-- Ajout du chemin de recherche pour trouver nos modules
local root_dir = "/Users/ben/CascadeProjects/gitpilot.nvim"
package.path = root_dir .. "/lua/?.lua;" .. package.path

-- Mock de vim pour les tests
local mock = require('luassert.mock')
local stub = require('luassert.stub')

-- Mock de vim global avant de charger le module
_G.vim = {
    notify = function() end,
    inspect = function(v) return tostring(v) end,
    log = {
        levels = {
            INFO = 2,
            WARN = 3,
            ERROR = 1
        }
    },
    ui = {
        select = function() end,
        input = function() end
    }
}

-- Mock du module i18n
package.loaded['gitpilot.i18n'] = {
    t = function(key, vars)
        if vars then
            local msg = key
            for k, v in pairs(vars) do
                msg = msg:gsub("%%{" .. k .. "}", tostring(v))
            end
            return msg
        end
        return key
    end,
    setup = function() end
}

-- Module à tester
local branch = require('gitpilot.features.branch')

describe("GitPilot Branch Feature", function()
    local vim_mock
    local git_output = ""
    
    -- Configuration avant chaque test
    before_each(function()
        -- Mock vim global
        vim_mock = mock(vim, true)
        
        -- Mock io.popen pour simuler les commandes git
        stub(io, "popen", function(cmd)
            return {
                read = function()
                    return git_output
                end,
                close = function() return true end
            }
        end)
    end)
    
    -- Nettoyage après chaque test
    after_each(function()
        mock.revert(vim_mock)
        io.popen:revert()
    end)
    
    -- Test de list_branches()
    describe("list_branches()", function()
        it("should correctly parse branch list", function()
            git_output = [[
  develop
* main
  feature/test
  remotes/origin/main
  remotes/origin/develop
]]
            local branches, current = branch.list_branches()
            
            assert.are.same("main", current)
            assert.are.same({
                "develop",
                "main",
                "feature/test",
                "remotes/origin/main",
                "remotes/origin/develop"
            }, branches)
        end)
        
        it("should handle empty branch list", function()
            git_output = ""
            local branches, current = branch.list_branches()
            
            assert.are.same({}, branches)
            assert.are.same("", current)
        end)
    end)
    
    -- Test de create_branch()
    describe("create_branch()", function()
        it("should create branch successfully", function()
            git_output = ""  -- Succès si pas d'erreur
            branch.create_branch("test-branch")
            
            assert.stub(io.popen).was.called_with("git branch test-branch")
            assert.stub(vim_mock.notify).was.called_with(
                "branch.create_success",
                vim_mock.log.levels.INFO
            )
        end)
        
        it("should handle creation error", function()
            git_output = "error: branch already exists"
            branch.create_branch("test-branch")
            
            assert.stub(vim_mock.notify).was.called_with(
                "branch.create_error",
                vim_mock.log.levels.ERROR
            )
        end)
    end)
    
    -- Test de checkout_branch()
    describe("checkout_branch()", function()
        it("should checkout branch successfully", function()
            git_output = "Switched to branch 'test-branch'"
            branch.checkout_branch("test-branch")
            
            assert.stub(io.popen).was.called_with("git checkout test-branch")
            assert.stub(vim_mock.notify).was.called_with(
                "branch.checkout_success",
                vim_mock.log.levels.INFO
            )
        end)
        
        it("should handle checkout error", function()
            git_output = "error: pathspec 'test-branch' did not match"
            branch.checkout_branch("test-branch")
            
            assert.stub(vim_mock.notify).was.called_with(
                "branch.checkout_error",
                vim_mock.log.levels.ERROR
            )
        end)
    end)
    
    -- Test de merge_branch()
    describe("merge_branch()", function()
        it("should merge branch successfully", function()
            git_output = "Fast-forward"
            branch.merge_branch("test-branch")
            
            assert.stub(io.popen).was.called_with("git merge test-branch")
            assert.stub(vim_mock.notify).was.called_with(
                "branch.merge_success",
                vim_mock.log.levels.INFO
            )
        end)
        
        it("should handle merge conflict", function()
            git_output = "CONFLICT (content): Merge conflict in file.txt"
            branch.merge_branch("test-branch")
            
            assert.stub(vim_mock.notify).was.called_with(
                "branch.merge_conflict",
                vim_mock.log.levels.WARN
            )
        end)
        
        it("should handle merge error", function()
            git_output = "error: merge is not possible"
            branch.merge_branch("test-branch")
            
            assert.stub(vim_mock.notify).was.called_with(
                "branch.merge_error",
                vim_mock.log.levels.ERROR
            )
        end)
    end)
    
    -- Test de delete_branch()
    describe("delete_branch()", function()
        it("should delete branch successfully", function()
            git_output = "Deleted branch test-branch"
            branch.delete_branch("test-branch")
            
            assert.stub(io.popen).was.called_with("git branch -d test-branch")
            assert.stub(vim_mock.notify).was.called_with(
                "branch.delete_success",
                vim_mock.log.levels.INFO
            )
        end)
        
        it("should handle delete error", function()
            git_output = "error: branch 'test-branch' not found"
            branch.delete_branch("test-branch")
            
            assert.stub(vim_mock.notify).was.called_with(
                "branch.delete_error",
                vim_mock.log.levels.ERROR
            )
        end)
        
        it("should force delete when specified", function()
            git_output = "Deleted branch test-branch (was 1234567)"
            branch.delete_branch("test-branch", true)
            
            assert.stub(io.popen).was.called_with("git branch -D test-branch")
        end)
    end)
    
    -- Test de l'interface utilisateur
    describe("show()", function()
        it("should create UI elements", function()
            git_output = "* main\n  develop"
            
            -- Mock vim.ui.select
            vim_mock.ui = {
                select = function(items, opts, on_choice)
                    -- Simuler une sélection
                    on_choice(items[1])
                end,
                input = function(opts, on_input)
                    -- Simuler une entrée
                    on_input("test-input")
                end
            }
            
            branch.show()
            
            -- Vérifier que la liste des branches a été récupérée
            assert.stub(io.popen).was.called_with("git branch --all")
        end)
    end)
end)
