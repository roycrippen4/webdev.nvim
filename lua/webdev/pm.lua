---@class OutdatedDep
---@field current string
---@field dependent string
---@field latest string
---@field location string
---@field wanted string

---@class PackageManager
---@field verify fun(json: table): boolean
---@field name "bun"|"npm"|"pnpm"|"yarn"
---@field run? fun(script: string): nil
---@field outdated? fun(): nil

local M = {}

local function readable(lockfile)
  local file = vim.fn.getcwd(0) .. '/' .. lockfile
  return vim.fn.filereadable(file) == 1
end

local function outdated()
  ---@param obj { code: number, signal: number, stderr: string, stdout: string }
  local function on_exit(obj)
    if obj.code ~= 1 then
      return
    end

    if obj.stdout == '' then
      return
    end

    if obj.stderr ~= '' then
      return
    end

    ---@type OutdatedDep[]?
    local outdated_deps = vim.fn.json_decode(obj.stdout)
    if not outdated_deps then
      return
    end

    local json = require('webdev.util').parse_json()
    local deps = {}

    if json and json.dependencies then
    end
  end

  vim.system({ 'npm', 'outdated', '--json' }, { text = true }, vim.schedule_wrap(on_exit))
end

---@type PackageManager
local pnpm = {
  name = 'pnpm',
  outdated = outdated,
  verify = function(json)
    return readable('pnpm-lock.yaml')
      or (json.packageManager and json.packageManager:match('pnpm') == 'pnpm')
      or (json.engines and json.engines.pnpm)
  end,
}

---@type PackageManager
local bun = {
  name = 'bun',
  outdated = outdated,
  verify = function(json)
    return readable('bun.lockb')
      or (json.packageManager and json.packageManager:match('bun') == 'bun')
      or (json.engines and json.engines.bun)
  end,
}

---@type PackageManager
local npm = {
  name = 'npm',
  outdated = outdated,
  verify = function(json)
    return readable('package-lock.json')
      or (json.packageManager and json.packageManager:match('npm') == 'npm')
      or (json.engines and json.engines.npm)
  end,
}

---@type PackageManager
local yarn = {
  name = 'yarn',
  outdated = outdated,
  verify = function(json)
    return readable('yarn.lock')
      or (json.packageManager and json.packageManager:match('yarn') == 'yarn')
      or (json.engines and json.engines.yarn)
  end,
}

--- Defaults to npm if no package manager can be verified
function M.get_pm(json)
  if pnpm.verify(json) then
    return pnpm
  end
  if npm.verify(json) then
    return npm
  end
  if bun.verify(json) then
    return bun
  end
  if yarn.verify(json) then
    return yarn
  end

  return npm
end

return M
