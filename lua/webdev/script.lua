---@class webdev.Config.scripts.virtual_text
---@field enabled? boolean Whether to show virtual text or not. Default = true.
---@field hl_group? string The highlight group to use for the virtual text. Default = 'WebDevRunScript'.
---@field text? string The text to render. Default = '  '.

---@class webdev.Config.scripts
---@field virtual_text? webdev.Config.scripts.virtual_text

local usercmd = vim.api.nvim_create_user_command
local util = require('webdev.util')
local ns = vim.api.nvim_create_namespace('package_json_runner')

---@type webdev.Config.scripts
local default_config = {
  virtual_text = {
    enabled = true,
    hl_group = 'WebDevRunScript',
    text = '  ',
  },
}

local M = {
  config = default_config,
}

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

---Updates the virtual text in the package.json
local function update_virtual_text()
  if not util.is_valid_package_json() then
    return
  end

  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  if not M.config.virtual_text.enabled then
    vim.notify('return true')
    return true
  end

  vim.iter(get_script_table()):each(function(script)
    vim.api.nvim_buf_set_extmark(0, ns, script.line - 1, 0, {
      virt_text = { { M.config.virtual_text.text, M.config.virtual_text.hl_group } },
      hl_mode = 'combine',
      virt_text_win_col = 1,
    })
  end)
end

local function set_autocmd()
  vim.api.nvim_create_autocmd({ 'BufEnter', 'TextChanged', 'TextChangedI' }, {
    group = vim.api.nvim_create_augroup('PackageJsonRunner', { clear = true }),
    pattern = 'package.json',
    callback = function()
      return update_virtual_text()
    end,
  })
end

function M.disable_virtual_text()
  M.config.virtual_text.enabled = false
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

function M.enable_virtual_text()
  M.config.virtual_text.enabled = true
  update_virtual_text()
  set_autocmd()
end

---Sets up autocmds for handling virtual text inside the package.json
---@param config? webdev.Config.scripts
function M.setup(config)
  M.config = vim.tbl_deep_extend('force', default_config, config or {})
  vim.api.nvim_set_hl(0, 'WebDevRunScript', { fg = '#08F000' })

  if M.config.virtual_text.enabled then
    set_autocmd()
  end

  usercmd('WebDevToggleScriptVirtualText', M.toggle_virtual_text, { desc = "Toggles the script runner's virtual text" })
  usercmd('WebDevDisableScriptVirtualText', M.disable_virtual_text, { desc = "Disables the script runner's virtual text" })
  usercmd('WebDevEnableScriptVirtualText', M.enable_virtual_text, { desc = "Enables the script runner's virtual text" })
  usercmd('WebDevRunScript', M.run, { desc = 'Runs the script under the cursor' })
end

---Toggles the virtual text for the script runner
function M.toggle_virtual_text()
  if M.config.virtual_text.enabled then
    M.disable_virtual_text()
  else
    M.enable_virtual_text()
  end
end

---Runs the script under the cursor
function M.run()
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
