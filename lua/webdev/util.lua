local M = {}

---Gets the absolute path to the included jq binary
---@return string?
local function get_jq_path()
  for _, str in ipairs(vim.api.nvim_list_runtime_paths()) do
    if str:match('.*webdev.nvim$') then
      return str .. '/bin/jq'
    end
  end

  vim.notify('Failed to find jq binary', vim.log.levels.ERROR)
end

M.jq_path = get_jq_path()

function M.current_file_as_string()
  return table.concat(vim.fn.readfile(vim.fn.expand('%')), '\n')
end

---@param str string
---@return string
local function trim(str)
  str = str:gsub('^%s+', ''):gsub('%s+$', '')
  return str
end

---@return table?
function M.parse_json()
  local path = vim.fn.expand('%:p')
  local json_str = trim(table.concat(vim.fn.readfile(path), ''))
  local ok, tbl = pcall(vim.json.decode, json_str)

  if not ok then
    return nil
  end

  return tbl
end

---Checks if a json formatted string is valid json
---@return boolean
function M.is_valid_package_json()
  if not vim.fn.expand('%:t') == 'package.json' then
    vim.notify('Not a package.json file', vim.log.levels.ERROR)
    return false
  end

  local json_str = M.current_file_as_string()
  local cmd = string.format("echo '%s' | " .. M.jq_path .. ' -e .', json_str)

  vim.fn.system(cmd)
  if vim.v.shell_error == 0 then
    return true
  else
    return false
  end
end

return M
