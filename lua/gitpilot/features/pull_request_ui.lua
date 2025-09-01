local M = {}
local ui = require('gitpilot.ui')
local i18n = require('gitpilot.i18n')
local pull_request = require('gitpilot.features.pull_request')

function M.show_pull_requests()
    pull_request.get_pull_requests(function(prs)
        if #prs == 0 then
            ui.show_info(i18n.t("pull_request.no_open_prs"))
            return
        end

        local items = {}
        for _, pr in ipairs(prs) do
            table.insert(items, string.format("#%d: %s", pr.number, pr.title))
        end

        ui.float_window(items, {
            title = i18n.t("pull_request.title")
        })
    end)
end

function M.setup(opts)
    -- TODO: Add setup logic
end

return M
