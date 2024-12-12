local M = {}

-- Mock de la fonction execute_command
M.execute_command = function(cmd)
    if cmd == 'git branch --show-current' then
        return true, 'main'
    end
    return false, 'Not a git repository'
end

-- Mock de la fonction system
M.system = function(cmd, args)
    if cmd == 'git' and args[1] == 'format-patch' then
        return true, 'Created patch file'
    elseif cmd == 'git' and args[1] == 'apply' then
        return true, 'Applied patch successfully'
    elseif cmd == 'git' and args[1] == '!ls' then
        return true, 'patch1.patch\npatch2.patch'
    elseif cmd == 'git' and args[1] == '!cat' then
        return true, 'Patch content'
    end
    return false, 'Git command failed'
end

-- Mock de la fonction git_sync
M.git_sync = function(args)
    if args[1] == 'format-patch' then
        return true, 'Created patch file'
    elseif args[1] == 'apply' then
        return true, 'Applied patch successfully'
    elseif args[1] == '!ls' then
        return true, 'patch1.patch\npatch2.patch'
    elseif args[1] == '!cat' then
        return true, 'Patch content'
    end
    return false, 'Git command failed'
end

return M
