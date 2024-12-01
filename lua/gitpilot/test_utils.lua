local M = {}

-- Mock responses for git commands
M.mock_responses = {
    ['remote add'] = {
        success = { output = '', error = '' },
        error = { output = '', error = 'Remote already exists' }
    },
    ['remote rm'] = {
        success = { output = '', error = '' },
        error = { output = '', error = 'Remote not found' }
    },
    ['remote'] = {
        success = { output = 'origin\nupstream', error = '' },
        error = { output = '', error = 'Not a git repository' }
    },
    ['push'] = {
        success = { output = 'Everything up-to-date', error = '' },
        error = { output = '', error = 'Could not push to remote' }
    },
    ['pull'] = {
        success = { output = 'Already up to date.', error = '' },
        error = { output = '', error = 'Could not pull from remote' }
    },
    ['log'] = {
        success = { output = 'commit abc123\nAuthor: Test User\nDate: Thu Jan 1 00:00:00 2023\n\n    Test commit', error = '' },
        error = { output = '', error = 'Not a git repository' }
    },
    ['ls-files'] = {
        success = { output = 'file1.txt\nfile2.txt', error = '' },
        error = { output = '', error = 'Not a git repository' }
    },
    ['branch'] = {
        success = { output = '* main\n  feature', error = '' },
        error = { output = '', error = 'Not a git repository' }
    },
    ['stash list'] = {
        success = { output = 'stash@{0}: WIP on main: Test stash\nstash@{1}: WIP on feature: Another stash', error = '' },
        error = { output = '', error = 'No stash entries found' }
    },
    ['stash push'] = {
        success = { output = 'Saved working directory and index state WIP on main: Test stash', error = '' },
        error = { output = '', error = 'No local changes to save' }
    },
    ['stash apply'] = {
        success = { output = 'On branch main\nChanges not staged for commit', error = '' },
        error = { output = '', error = 'Could not apply stash' }
    },
    ['stash drop'] = {
        success = { output = 'Dropped refs/stash@{0}', error = '' },
        error = { output = '', error = 'Could not drop stash' }
    },
    ['rebase'] = {
        success = { output = 'Successfully rebased', error = '' },
        error = { output = '', error = 'Cannot rebase: You have unstaged changes.' }
    },
    ['rebase --continue'] = {
        success = { output = 'Successfully rebased and updated', error = '' },
        error = { output = '', error = 'No rebase in progress?' }
    },
    ['rebase --abort'] = {
        success = { output = 'Rebase aborted', error = '' },
        error = { output = '', error = 'No rebase in progress?' }
    }
}

-- Mock git command execution
M.mock_git_command = function(cmd, args)
    if not cmd then
        return false, nil, "Command cannot be empty"
    end

    local full_cmd = cmd
    if args and #args > 0 then
        full_cmd = cmd .. ' ' .. table.concat(args, ' ')
    end

    -- Default response for unknown commands
    local default_response = { output = '', error = 'Unknown command' }

    -- Find matching mock response
    for pattern, response in pairs(M.mock_responses) do
        if full_cmd:match('^' .. pattern) then
            -- Return success response by default, error if specified in args
            if args and vim.tbl_contains(args, '--error') then
                return false, response.error.output, response.error.error
            else
                return true, response.success.output, response.success.error
            end
        end
    end

    return false, default_response.output, default_response.error
end

return M
