
-- local function set_virtual_text()
--   if not is_package_json() then
--     return
--   end

--   if not M.ns_id then
--     M.ns_id = vim.api.nvim_create_namespace('package_json_runner')
--   end

--   for _, script in ipairs(M.scripts) do
--     vim.api.nvim_buf_set_extmark(0, M.ns_id, script.line - 1, 0, {
--       virt_text = { { '  ', 'RunScript' } },
--       hl_mode = 'combine',
--       virt_text_win_col = 1,
--     })
--   end
-- end
