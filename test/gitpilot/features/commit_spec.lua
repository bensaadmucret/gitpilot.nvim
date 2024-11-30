local assert = require('luassert')
local commit = require('gitpilot.features.commit')
local utils = require('gitpilot.utils')
local ui = require('gitpilot.ui')

describe('commit', function()
  before_each(function()
    -- Reset commit state before each test
    commit.setup({})
    -- Ensure we're in test mode
    vim.env.GITPILOT_TEST = "1"
  end)

  describe('select_files', function()
    it('should handle empty git status', function()
      -- Mock utils.git_command to return empty status
      local original_git_command = utils.git_command
      utils.git_command = function(cmd)
        if cmd == 'status --porcelain' then
          return {
            success = true,
            output = "",
            error = ""
          }
        end
        return original_git_command(cmd)
      end

      local files = commit.select_files()
      assert.same({}, files)

      -- Restore original function
      utils.git_command = original_git_command
    end)

    it('should parse git status output', function()
      -- Mock utils.git_command to return test status
      local original_git_command = utils.git_command
      utils.git_command = function(cmd)
        if cmd == 'status --porcelain' then
          return {
            success = true,
            output = " M file1.txt\n?? file2.txt\nA  file3.txt",
            error = ""
          }
        end
        return original_git_command(cmd)
      end

      local files = commit.select_files()
      assert.equals(3, #files)
      assert.same({
        status = " M",
        path = "file1.txt",
        selected = false
      }, files[1])

      -- Restore original function
      utils.git_command = original_git_command
    end)
  end)

  describe('select_commit_type', function()
    it('should provide valid commit types', function()
      local commit_type = commit.select_commit_type()
      assert.is_not_nil(commit_type)
      assert.is_table(commit_type)
      assert.is_not_nil(commit_type.type)
      assert.is_not_nil(commit_type.emoji)
      assert.is_not_nil(commit_type.desc)
    end)
  end)

  describe('smart_commit', function()
    it('should handle no files to commit', function()
      -- Mock utils.git_command to return empty status
      local original_git_command = utils.git_command
      utils.git_command = function(cmd)
        if cmd == 'status --porcelain' then
          return {
            success = true,
            output = "",
            error = ""
          }
        end
        return original_git_command(cmd)
      end

      local success = commit.smart_commit()
      assert.is_false(success)

      -- Restore original function
      utils.git_command = original_git_command
    end)

    it('should handle commit creation', function()
      -- Mock utils.git_command for test
      local original_git_command = utils.git_command
      local commands_executed = {}
      utils.git_command = function(cmd)
        table.insert(commands_executed, cmd)
        if cmd == 'status --porcelain' then
          return {
            success = true,
            output = " M file1.txt",
            error = ""
          }
        elseif cmd:match('^add') then
          return {
            success = true,
            output = "",
            error = ""
          }
        elseif cmd:match('^commit') then
          return {
            success = true,
            output = "Created commit abc123",
            error = ""
          }
        end
        return original_git_command(cmd)
      end

      local success = commit.smart_commit()
      assert.is_true(success)
      assert.is_true(#commands_executed >= 2) -- Should have at least status and commit commands

      -- Restore original function
      utils.git_command = original_git_command
    end)
  end)

  describe('amend_commit', function()
    it('should handle amend operation', function()
      -- Mock utils.git_command for test
      local original_git_command = utils.git_command
      local commands_executed = {}
      utils.git_command = function(cmd)
        table.insert(commands_executed, cmd)
        if cmd == 'status --porcelain' then
          return {
            success = true,
            output = " M file1.txt",
            error = ""
          }
        elseif cmd:match('^add') then
          return {
            success = true,
            output = "",
            error = ""
          }
        elseif cmd:match('commit --amend') then
          return {
            success = true,
            output = "Updated commit abc123",
            error = ""
          }
        elseif cmd:match('^commit') then
          return {
            success = true,
            output = "Created commit abc123",
            error = ""
          }
        end
        return original_git_command(cmd)
      end

      -- First create a commit to amend
      commit.smart_commit()
      
      -- Then try to amend it
      local success = commit.amend_commit()
      assert.is_true(success)
      assert.is_true(#commands_executed >= 2) -- Should have at least status and amend commands

      -- Restore original function
      utils.git_command = original_git_command
    end)
  end)

end)
