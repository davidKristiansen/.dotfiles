-- SPDX-License-Identifier: MIT
-- mini.surround + which-key integration (shows `sa/sd/sr/...` under the `s` prefix)
-- Fits your module pattern and stays no-op if plugins aren’t available.
local M = {}

function M.setup()
  -- 1) mini.surround (from nvim-mini/mini.nvim)
  local ok_surround, surround = pcall(require, "mini.surround")
  if ok_surround then
    surround.setup({
      -- Explicit mappings (close to defaults)
      mappings = {
        add            = "sa", -- Add surrounding (Normal/Visual)
        delete         = "sd", -- Delete surrounding
        find           = "sf", -- Find to the right
        find_left      = "sF", -- Find to the left
        highlight      = "sh", -- Highlight surrounding
        replace        = "sr", -- Replace surrounding
        update_n_lines = "sn", -- Update n_lines
      },
      n_lines = 20,
      respect_selection_type = true,
      search_method = "cover",
    })
  end

  -- 2) which-key: show `s`-prefix hints (sa/sd/sr/...)
  local ok_wk, wk = pcall(require, "which-key")
  if not ok_wk then return end

  -- Detect which-key version by API shape
  local is_v2 = type(wk.add) == "function"

  if is_v2 then
    -- v2 API
    -- Ensure popup also triggers on bare 's' in Normal/Visual (alongside <leader>)
    -- NOTE: If you already call wk.setup() elsewhere, you can keep only the wk.add() block below.
    wk.setup({
      triggers = {
        { "<leader>", mode = { "n", "v" } },
        { "s",        mode = { "n", "v" } }, -- <- important: show hints after pressing `s`
      },
    })

    -- Register nice labels for the `s` prefix (Normal + Visual)
    wk.add({
      { "s",  group = "surround" },
      { "sa", desc  = "Add surrounding",       mode = { "n", "v" } },
      { "sd", desc  = "Delete surrounding" },
      { "sr", desc  = "Replace surrounding" },
      { "sf", desc  = "Find right" },
      { "sF", desc  = "Find left" },
      { "sh", desc  = "Highlight surrounding" },
      { "sn", desc  = "Update n-lines" },
    })
  else
    -- v1 API
    wk.setup({}) -- keep defaults; relies on `timeoutlen` for popup
    wk.register({
      s = {
        name = "surround",
        a = "Add surrounding",
        d = "Delete surrounding",
        r = "Replace surrounding",
        f = "Find right",
        F = "Find left",
        h = "Highlight",
        n = "Update n-lines",
      },
    }, { mode = "n" })

    wk.register({
      s = {
        name = "surround",
        a = "Add surrounding",
      },
    }, { mode = "v" })
  end
end

return M

