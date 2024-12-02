-- test_helpers.lua

local M = {}

function M.setup_vim_mock()
    -- Mock vim global
    _G.vim = {
        notify = function() end,
        log = {
            levels = {
                ERROR = 1,
                WARN = 2,
                INFO = 3
            }
        },
        ui = {
            select = function() end
        },
        api = {
            nvim_get_current_buf = function() return 1 end,
            nvim_buf_get_lines = function() return {} end,
            nvim_buf_set_lines = function() end,
            nvim_buf_line_count = function() return 0 end,
            nvim_command = function() end,
            nvim_create_buf = function() return 1 end,
            nvim_open_win = function() return 1 end,
            nvim_win_close = function() end,
            nvim_buf_delete = function() end,
            nvim_get_current_win = function() return 1 end,
            nvim_win_get_cursor = function() return {1, 0} end,
            nvim_win_set_cursor = function() end,
            nvim_buf_get_name = function() return "" end,
            nvim_set_current_win = function() end,
            nvim_buf_set_option = function() end,
            nvim_win_set_option = function() end,
            nvim_buf_get_option = function() return "" end,
            nvim_win_get_option = function() return "" end,
            nvim_get_current_tabpage = function() return 1 end,
            nvim_list_wins = function() return {1} end,
            nvim_win_get_buf = function() return 1 end,
            nvim_buf_get_var = function() return nil end,
            nvim_buf_set_var = function() end,
            nvim_buf_get_mark = function() return {1, 0} end,
            nvim_buf_add_highlight = function() end,
            nvim_buf_clear_namespace = function() end,
            nvim_create_namespace = function() return 1 end
        },
        fn = {
            bufwinnr = function() return 1 end,
            expand = function() return "" end,
            fnamemodify = function(path) return path end,
            glob = function() return "" end,
            has = function() return 1 end,
            input = function() return "" end,
            system = function() return "" end,
            systemlist = function() return {} end,
            winheight = function() return 10 end,
            winwidth = function() return 80 end
        }
    }
end

function M.setup_git_mock()
    -- Mock git commands
    package.loaded['gitpilot.utils'] = {
        execute_command = function(cmd)
            if cmd:match("^git rev%-parse") then
                return true, "/mock/git/root"
            elseif cmd:match("^git branch") then
                return true, "* main\n  feature"
            elseif cmd:match("^git status") then
                return true, " M modified.txt\n?? untracked.txt"
            else
                return true, ""
            end
        end,
        check_git = function() return true end,
        is_git_repo = function() return true end,
        get_git_root = function() return "/mock/git/root" end
    }
end

function M.teardown()
    _G.vim = nil
    package.loaded['gitpilot.utils'] = nil
end

return M
