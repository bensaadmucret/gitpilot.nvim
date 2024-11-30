-- Configure le chemin pour trouver nos modules
package.path = package.path .. ";/Users/ben/CascadeProjects/gitpilot.nvim/lua/?.lua;/Users/ben/CascadeProjects/gitpilot.nvim/lua/?/init.lua"

-- Charge les helpers de test qui définissent l'environnement mock de Neovim
require('tests.test_helpers')

local function run_tests()
    local test_modules = {
        'tests.features.branch_test',
        'tests.features.stash_test',
        'tests.features.tags_test',
        'tests.features.commit_test'
    }

    local total_tests = 0
    local passed_tests = 0
    local failed_tests = {}

    print("\n=== Running GitPilot Tests ===\n")

    for _, module_name in ipairs(test_modules) do
        local success, test_module = pcall(require, module_name)
        if not success then
            print(string.format("Error loading test module '%s': %s", module_name, test_module))
            goto continue
        end

        print(string.format("Running tests from '%s':", module_name))
        
        for test_name, test_func in pairs(test_module) do
            if type(test_func) == 'function' and test_name:match('^test_') then
                total_tests = total_tests + 1
                local success, error_msg = pcall(test_func)
                
                if success then
                    passed_tests = passed_tests + 1
                    print(string.format("  ✓ %s", test_name))
                else
                    table.insert(failed_tests, {
                        module = module_name,
                        test = test_name,
                        error = error_msg
                    })
                    print(string.format("  ✗ %s", test_name))
                    print(string.format("    Error: %s", error_msg))
                end
            end
        end
        
        print("") -- Empty line between modules
        ::continue::
    end

    print("\n=== Test Results ===")
    print(string.format("Total tests: %d", total_tests))
    print(string.format("Passed: %d", passed_tests))
    print(string.format("Failed: %d", #failed_tests))
    
    if #failed_tests > 0 then
        print("\nFailed tests:")
        for _, failure in ipairs(failed_tests) do
            print(string.format("\n%s.%s", failure.module, failure.test))
            print("Error: " .. failure.error)
        end
        os.exit(1)
    end
end

run_tests()
