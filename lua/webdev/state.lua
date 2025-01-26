local M = {}

M.dependencies = {}
M.dev_dependencies = {}

--- Updates state for the dependencies and devDependencies tables
---@param outdated OutdatedDep
function M.update(outdated)
  local json = require('webdev.util').parse_json()
  if not json then
    return
  end

  M.dependencies = json.dependencies or {}
  M.dev_dependencies = json.devDependencies or {}
end

return M
