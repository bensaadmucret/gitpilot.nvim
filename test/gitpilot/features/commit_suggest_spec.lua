local assert = require("luassert")
local commit_suggest = require("gitpilot.features.commit_suggest")

describe("commit_suggest", function()
    before_each(function()
        commit_suggest.setup()
    end)

    it("should suggest commit message in test mode", function()
        vim.env.GITPILOT_TEST = "1"
        local result = commit_suggest.suggest_commit_message()
        
        assert.is_true(result.success)
        assert.is_table(result.output)
        assert.equals("feat", result.output.type)
        assert.equals("core", result.output.scope)
        assert.equals("✨", result.output.emoji)
    end)

    it("should format commit message correctly", function()
        local suggestion = {
            success = true,
            output = {
                type = "feat",
                scope = "core",
                emoji = "✨",
                message = "add new feature"
            }
        }
        
        local formatted = commit_suggest.format_commit_message(suggestion)
        assert.equals("✨ feat(core): add new feature", formatted)
    end)

    it("should handle breaking changes", function()
        local suggestion = {
            success = true,
            output = {
                type = "feat",
                scope = "core",
                emoji = "✨",
                message = "BREAKING CHANGE: major api update"
            }
        }
        
        local formatted = commit_suggest.format_commit_message(suggestion)
        assert.equals("✨ feat(core): BREAKING CHANGE: major api update", formatted)
    end)

    it("should return empty string for invalid suggestion", function()
        local formatted = commit_suggest.format_commit_message(nil)
        assert.equals("", formatted)
        
        formatted = commit_suggest.format_commit_message({ success = false })
        assert.equals("", formatted)
    end)
end)
