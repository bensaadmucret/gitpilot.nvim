-- Plugin entry point for gitpilot.nvim
if vim.g.loaded_gitpilot then
  return
end
vim.g.loaded_gitpilot = true

-- Create user commands
vim.api.nvim_create_user_command('GitPilot', function()
  local gitpilot = require('gitpilot')
  gitpilot.show_menu()
end, {})

-- Create autocommands
local group = vim.api.nvim_create_augroup('GitPilot', { clear = true })

vim.api.nvim_create_autocmd('VimEnter', {
  group = group,
  callback = function()
    if vim.g.gitpilot_auto_setup then
      require('gitpilot').setup()
    end
  end,
})
