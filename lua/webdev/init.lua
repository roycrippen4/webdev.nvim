local M = {}
-- local pm = require('webdev.pm')
local util = require('webdev.util')
local script = require('webdev.script')

-- function M.setup()
-- M.scripts = get_script_table()
-- vim.keymap.set('n', '<leader>nr', M.run_script, { desc = 'Run script' })
-- vim.api.nvim_set_hl(0, 'RunScript', { fg = '#08F000' })
-- set_virtual_text()
-- end

-- vim.api.nvim_create_autocmd('BufEnter', {
--   pattern = 'package.json',
--   group =
--   callback = function()
--     parse_json()
--     -- M.setup()
--   end,
-- })

-- vim.keymap.set('n', '<leader>nr', function()
--   local pm = pm.get_pm(util.parse_json())
--   if not pm then
--     log('no pm found')
--   end

--   pm.outdated()

-- local json = parse_json()
-- if not json or not json.scripts then
--   return
-- end

-- log(get_script(json.scripts))
-- end)

function M.setup()
  script:setup()
  -- vim.keymap.set('n', '<leader>nr', script.run, { desc = 'Run script' })
  -- vim.api.nvim_create_autocmd('BufEnter', {
  --   pattern = 'package.json',
  --   once = true,
  --   callback = function()
  --     Snacks.debug.inspect(script.get_script_table())
  --   end,
  -- })
end

-- local group = vim.api.nvim_create_augroup('PackageCheck', { clear = true })
-- vim.api.nvim_create_autocmd({ 'BufEnter', 'TextChanged', 'TextChangedI' }, {
--   pattern = 'package.json',
--   group = group,
--   callback = function()
--     parse_json()
--   end,
-- })

return M
