local util = require('webdev.util')
local ns = vim.api.nvim_create_namespace('package_json_runner')

local M = { is_setup = false }

---@param lines string[]
---@return integer, integer
local function find_script_range(lines)
  local start_line = 0
  local end_line = 0

  for i, line in ipairs(lines) do
    if line:find('scripts') then
      start_line = i
      break
    end
  end

  for i = start_line + 1, #lines do
    if lines[i]:find('}') then
      end_line = i
      break
    end
  end

  return start_line, end_line
end

---@param scripts { line: integer, script_key: string }[]
---@return string?
local function match_script(scripts)
  local cursor = vim.fn.line('.')

  for _, script in ipairs(scripts) do
    if cursor == script.line then
      return script.script_key
    end
  end
end

---@param scripts { line: integer, script_key: string }[]
---@return boolean
local function cursor_on_script(scripts)
  local cursor = vim.fn.line('.')

  for _, script in ipairs(scripts) do
    if cursor == script.line then
      return true
    end
  end

  return false
end

---@param scripts { line: integer, script_key: string }[]
local function can_run_script(scripts)
  if not util.is_valid_package_json() then
    return false
  end

  if not cursor_on_script(scripts) then
    vim.notify('Cursor not on a script', vim.log.levels.ERROR)
    return false
  end

  return true
end

---@return { line: integer, script_key: string }[]
local function get_script_table()
  local scripts = {}
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false) ---@type string[]
  local start_line, end_line = find_script_range(lines)

  if start_line == 0 or end_line == 0 then
    return {}
  end

  for i = start_line + 1, end_line do
    local script_key = lines[i]:match('"[%s]*(.-)[%s]*":')
    if script_key then
      script_key = script_key:gsub('%-', '%%-')
      table.insert(scripts, { line = i, script_key = script_key })
    end
  end

  return scripts
end

local function update_virtual_text()
  if not util.is_valid_package_json() then
    return
  end
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  vim.iter(get_script_table()):each(function(script)
    vim.api.nvim_buf_set_extmark(0, ns, script.line - 1, 0, {
      virt_text = { { '  ', 'RunScript' } },
      hl_mode = 'combine',
      virt_text_win_col = 1,
    })
  end)
end

function M:setup()
  vim.api.nvim_set_hl(0, 'RunScript', { fg = '#08F000' })

  vim.api.nvim_create_autocmd('BufEnter', {
    pattern = 'package.json',
    callback = function()
      update_virtual_text()
    end,
  })

  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    pattern = 'package.json',
    callback = function()
      update_virtual_text()
    end,
  })
  self.is_setup = true
end

function M:run()
  if not self.is_setup then
    self:setup()
  end
  local scripts = get_script_table()
  if not can_run_script(scripts) then
    return
  end

  local runner = (vim.fn.filereadable('bun.lockb') == 1 and 'bun run ') or 'npm run '
  local matched = match_script(scripts)

  if not matched then
    return
  end

  vim.cmd.TermExec('cmd="' .. runner .. matched .. '"')
end

return M
