-- tests/init.lua

-- Add the project root to package.path
local project_root = vim.fn.getcwd()
package.path = project_root .. "/?.lua;" .. package.path
package.path = project_root .. "/?/init.lua;" .. package.path

-- Add the tests directory to package.path
package.path = project_root .. "/tests/?.lua;" .. package.path
package.path = project_root .. "/tests/?/init.lua;" .. package.path
