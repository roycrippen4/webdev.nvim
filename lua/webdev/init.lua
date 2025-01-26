local util = require('webdev.util')
local script = require('webdev.script')

local M = {}

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

---@class webdev.Config
---@field scripts? webdev.Config.scripts

function M.setup()
  script.setup()
end

function M.run_script()
  script.run()
end

return M
