-- SPDX-License-Identifier: MIT
local M = {}

function M.setup()
  local ok, overseer = pcall(require, "overseer")
  if not ok then
    return
  end

  -- Override overseer.parser.extract_json to use json5
  -- This must happen BEFORE overseer.setup() if extract_json is loaded early
  package.loaded["overseer.parser.extract_json"] = require("utils.overseer_json5_parser")
  overseer.setup()
end

return M
