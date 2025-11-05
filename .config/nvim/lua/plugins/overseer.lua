-- SPDX-License-Identifier: MIT
vim.pack.add({
  { src = "https://github.com/stevearc/overseer.nvim" },
  { src = "https://github.com/Joakker/lua-json5" },
}, { confirm = false })


-- Override overseer.parser.extract_json to use json5
-- This must happen BEFORE overseer.setup() if extract_json is loaded early
package.loaded["overseer.parser.extract_json"] = require("utils.overseer_json5_parser")
require("overseer").setup()
