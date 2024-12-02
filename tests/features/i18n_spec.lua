-- i18n_spec.lua
local test_helpers = require("test_helpers")

describe("I18n Module", function()
    local i18n
    local original_getenv

    before_each(function()
        -- Configurer l'environnement de test
        test_helpers.setup_vim_mock()
        
        -- Sauvegarder l'original os.getenv
        original_getenv = os.getenv
        
        -- Charger le module i18n
        package.loaded['gitpilot.i18n'] = nil
        i18n = require("gitpilot.i18n")
    end)

    after_each(function()
        -- Restaurer l'original os.getenv
        os.getenv = original_getenv
        
        -- Nettoyer l'environnement
        test_helpers.teardown()
        package.loaded['gitpilot.i18n'] = nil
    end)
    
    describe("setup", function()
        it("should set language from options", function()
            i18n.setup({ language = "fr" })
            assert.equals("fr", i18n.get_language())
        end)
        
        it("should fallback to English for unsupported language", function()
            i18n.setup({ language = "es" })
            assert.equals("en", i18n.get_language())
        end)
        
        it("should detect system language", function()
            os.getenv = function(var)
                if var == "LANG" then
                    return "fr_FR.UTF-8"
                end
                return original_getenv(var)
            end
            i18n.setup()
            assert.equals("fr", i18n.get_language())
        end)
        
        it("should handle empty options", function()
            i18n.setup({})
            assert.equals("en", i18n.get_language())
        end)
        
        it("should handle nil options", function()
            i18n.setup()
            assert.equals("en", i18n.get_language())
        end)
    end)
    
    describe("translation", function()
        it("should translate simple key", function()
            i18n.setup({ language = "fr" })
            assert.equals("Branche", i18n.t("branch"))
        end)
        
        it("should handle missing key", function()
            i18n.setup({ language = "fr" })
            assert.equals("missing.key", i18n.t("missing.key"))
        end)
        
        it("should handle variable substitution", function()
            i18n.setup({ language = "fr" })
            assert.equals("Branche test créée", 
                i18n.t("branch.create_success", { name = "test" }))
        end)
        
        it("should handle missing variables", function()
            i18n.setup({ language = "fr" })
            assert.equals("Branche %{name} créée", 
                i18n.t("branch.create_success"))
        end)
        
        it("should fallback to English for missing translations", function()
            i18n.setup({ language = "fr" })
            assert.equals("Test Message", 
                i18n.t("test.message_only_in_english"))
        end)
    end)
    
    describe("language management", function()
        it("should list available languages", function()
            local languages = i18n.get_available_languages()
            assert.are.same({ "en", "fr" }, languages)
        end)
        
        it("should change language successfully", function()
            i18n.set_language("fr")
            assert.equals("fr", i18n.get_language())
        end)
        
        it("should fail to change to unsupported language", function()
            i18n.set_language("es")
            assert.equals("en", i18n.get_language())
        end)
        
        it("should handle nil language in set_language", function()
            i18n.set_language(nil)
            assert.equals("en", i18n.get_language())
        end)
    end)
end)
