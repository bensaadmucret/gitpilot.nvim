-- Mock des fonctions Neovim
local mock = {
    fn = {
        system = function(cmd) return "mock output" end,
        getcwd = function() return "/mock/path" end
    },
    v = { shell_error = 0 },
    api = {
        nvim_err_writeln = function(msg) end,
        nvim_command = function(cmd) end,
        nvim_echo = function(chunks, history, opts) end
    },
    notify = function(msg, level, opts) end,
    log = {
        levels = {
            ERROR = 1,
            WARN = 2,
            INFO = 3,
            DEBUG = 4
        }
    }
}

-- Initialiser le mock vim avant de charger les modules
_G.vim = mock

describe("I18n Module", function()
    local i18n = require("gitpilot.i18n")
    
    before_each(function()
        -- Reset to default language
        i18n.set_language("en")
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
        
        it("should detect French from system language", function()
            os.getenv = function(var) return "fr_FR.UTF-8" end
            i18n.setup({})
            assert.equals("fr", i18n.get_language())
        end)
        
        it("should use English as default when no system language", function()
            os.getenv = function(var) return nil end
            i18n.setup({})
            assert.equals("en", i18n.get_language())
        end)
    end)
    
    describe("translation", function()
        it("should translate simple keys", function()
            local result = i18n.t("welcome")
            assert.is_not.equals("welcome", result)
        end)
        
        it("should handle nested keys", function()
            local result = i18n.t("menu.main")
            assert.is_not.equals("menu.main", result)
        end)
        
        it("should substitute variables", function()
            local result = i18n.t("branch.success.created", { name = "test" })
            assert.matches("test", result)
        end)
        
        it("should fallback to key for missing translations", function()
            local result = i18n.t("nonexistent.key")
            assert.equals("nonexistent.key", result)
        end)
        
        it("should handle empty variables", function()
            local result = i18n.t("branch.success.created", {})
            assert.not_matches("%%{name}", result)
        end)
        
        it("should handle nil variables", function()
            local result = i18n.t("branch.success.created", nil)
            assert.matches("%%{name}", result)
        end)
    end)
    
    describe("language management", function()
        it("should list available languages", function()
            local langs = i18n.get_available_languages()
            local has_en = false
            local has_fr = false
            for _, lang in ipairs(langs) do
                if lang == "en" then has_en = true end
                if lang == "fr" then has_fr = true end
            end
            assert.is_true(has_en, "English language should be available")
            assert.is_true(has_fr, "French language should be available")
        end)
        
        it("should change language successfully", function()
            assert.is_true(i18n.set_language("fr"))
            assert.equals("fr", i18n.get_language())
        end)
        
        it("should fail to change to unsupported language", function()
            assert.is_false(i18n.set_language("es"))
            assert.equals("en", i18n.get_language())
        end)
    end)
end)
