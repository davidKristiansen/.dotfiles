-- SPDX-License-Identifier: MIT
-- lua/plugins/avante.lua
-- Avante intelligent assistant integration with dynamic provider switching
-- Added: provider cycling + inline '@' file reference picker in avante input buffer.
local M = {}

-- ---------------------------------------------------------------------------
-- Helpers / utilities
-- ---------------------------------------------------------------------------

-- Lock Avante related window sizes so layout doesn’t jump when content changes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "avante", "avante-input", "avante-sidebar" },
  callback = function(ev)
    local win = vim.fn.bufwinid(ev.buf)
    if win ~= -1 then
      vim.api.nvim_set_option_value("winfixwidth", true, { win = win })
      vim.api.nvim_set_option_value("winfixheight", true, { win = win })
    end
  end,
})

local function env(k)
  local v = vim.fn.getenv(k)
  return (v == vim.NIL or v == "") and nil or v
end

local function copilot_headers()
  local ok, auth = pcall(require, "copilot.auth")
  if not ok then return {} end
  local token = auth.get_auth_token and auth.get_auth_token() or nil
  if not token then return {} end
  return { Authorization = ("Bearer %s"):format(token) }
end

-- ---------------------------------------------------------------------------
-- Provider templates (header fields may be functions for dynamic refresh)
-- ---------------------------------------------------------------------------
local PROVIDERS = {
  openai = {
    endpoint = "https://api.openai.com/v1",
    model = "gpt-5", -- placeholder model name; adjust to actual upstream naming
    timeout = 30000,
    headers = function()
      return { Authorization = ("Bearer %s"):format(env("OPENAI_API_KEY") or "") }
    end,
    extra_request_body = { temperature = 0, max_completion_tokens = 8192 },
  },
  copilot = {
    endpoint = "https://api.githubcopilot.com",
    model = "gpt-5",           -- placeholder; Copilot internally routes
    timeout = 30000,
    headers = copilot_headers, -- dynamic token retrieval
  },
  gemini = {
    endpoint = "https://generativelanguage.googleapis.com/v1beta",
    model = "gemini-2.5-pro", -- placeholder / example
    timeout = 30000,
    headers = function()
      return { Authorization = ("Bearer %s"):format(env("GEMINI_API_KEY") or "") }
    end,
    extra_request_body = { temperature = 0 },
  },
}

-- ---------------------------------------------------------------------------
-- ACP providers (local agents speaking ACP over stdio)
-- Example: Google Gemini CLI
-- ---------------------------------------------------------------------------
local ACP_PROVIDERS = {
  ["gemini-cli"] = {
    -- the CLI executable name in your $PATH
    command = "gemini",
    -- run in ACP server mode (required)
    args = { "--experimental-acp" },
    -- pass env; Avante will spawn the process with these
    env = {
      GEMINI_API_KEY = env("GEMINI_API_KEY") or env("AVANTE_GEMINI_API_KEY") or "",
      NODE_NO_WARNINGS = "1", -- optional: quiets node stderr noise
    },
    -- optional: working dir (defaults to cwd)
    -- cwd = vim.loop.cwd(),
  },
  -- add more CLI agents here if you like
  ["gemini-cli-flash"] = {
    command = "gemini",
    -- if your CLI supports --model, great; otherwise set via env
    args    = { "--experimental-acp", "--model", "gemini-1.5-flash" },
    env     = {
      GEMINI_API_KEY = env("GEMINI_API_KEY") or env("AVANTE_GEMINI_API_KEY") or "",
      GEMINI_MODEL   = "gemini-2.5-flash", -- belt & braces if CLI reads env
    },
  },
}


-- ---------------------------------------------------------------------------
-- Mutable runtime opts for avante.setup
-- (A future Avante version may expose a real 'mentions' feature; placeholder)
-- ---------------------------------------------------------------------------
local opts = {
  override_prompt_dir = vim.fn.expand("~/.config/nvim/avante_prompts"),
  provider = "copilot", -- default provider at startup
  providers = vim.deepcopy(PROVIDERS),
  acp_providers = vim.deepcopy(ACP_PROVIDERS),
  window = {
    layout = "vertical", -- or "horizontal"
    width  = 50,         -- fixed columns
    height = 15,         -- rows if horizontal layout chosen later
  },
  selector = {
    provider = "mini_pick",
    provider_opts = {},
  }
}

-- Expand header function fields into concrete tables
local function normalize_headers(tbl)
  for _, p in pairs(tbl) do
    if type(p.headers) == "function" then
      local okh, hdrs = pcall(p.headers)
      p.headers = (okh and hdrs) or {}
    end
  end
end

-- Reconfigure Avante with a chosen provider (refresh tokens each switch)
local function reconfigure(provider_name)
  local is_cloud = opts.providers[provider_name] ~= nil
  local is_acp   = opts.acp_providers and opts.acp_providers[provider_name] ~= nil

  if not is_cloud and not is_acp then
    vim.notify(("Avante: unknown provider '%s'"):format(provider_name), vim.log.levels.ERROR)
    return
  end

  -- rebuild tables so header funcs & env refresh each switch
  opts.providers = vim.deepcopy(PROVIDERS)
  if opts.acp_providers then
    opts.acp_providers = vim.deepcopy(ACP_PROVIDERS)
  end
  normalize_headers(opts.providers)

  -- selecting: for ACP, we set provider to the ACP key as well
  opts.provider = provider_name

  local ok, avante = pcall(require, "avante")
  if not ok then return end
  avante.setup(opts)
  vim.notify(("Avante → %s"):format(provider_name), vim.log.levels.INFO)
end


-- Cycle provider helper (ordered list)
local provider_order = { "copilot", "openai", "gemini", "gemini-cli", "gemini-cli-flash" }
local function cycle_provider()
  local current = opts.provider
  local index = 1
  for i, name in ipairs(provider_order) do
    if name == current then
      index = i
      break
    end
  end
  local next_name = provider_order[(index % #provider_order) + 1]
  reconfigure(next_name)
end

-- Attach convenience mappings in Avante main / sidebar windows
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "avante", "avante-sidebar" },
  callback = function(ev)
    local buf = ev.buf
    vim.keymap.set("n", "<leader>ap", cycle_provider, { buffer = buf, silent = true, desc = "Avante: cycle provider" })
  end,
})

-- Inline '@' file reference insertion inside Avante input buffer
-- We hook the literal '@' key. If user cancels the picker we still insert '@'.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "avante-input",
  callback = function(ev)
    local buf = ev.buf

    local function pick_and_insert()
      local ok_pick, pick = pcall(require, "mini.pick")
      if not ok_pick then
        -- Fallback: just insert '@'
        vim.api.nvim_feedkeys("@", "i", false)
        return
      end
      pick.builtin.files({
        on_accept = function(filepath)
          -- mini.pick returns a string path
          local rel = vim.fn.fnamemodify(filepath, ":.")
          local text = "@" .. rel .. " "
          vim.api.nvim_put({ text }, "c", true, true)
        end,
        on_cancel = function()
          vim.api.nvim_feedkeys("@", "i", false)
        end,
      })
    end

    -- Primary trigger: literal '@'
    vim.keymap.set("i", "@", pick_and_insert, { buffer = buf, silent = true, desc = "Insert @file reference" })
    -- Alternate manual trigger (if user wants plain '@', they can type @@ quickly to produce '@@ref')
    vim.keymap.set("i", "<C-f>", pick_and_insert, { buffer = buf, silent = true, desc = "Pick file + insert @ref" })
  end,
})

-- ---------------------------------------------------------------------------
-- Public setup
-- ---------------------------------------------------------------------------
function M.setup()
  normalize_headers(opts.providers)
  local ok, avante = pcall(require, "avante")
  if ok then avante.setup(opts) end

  -- User commands for explicit provider jump
  vim.api.nvim_create_user_command("AvanteUseOpenAI", function() reconfigure("openai") end, {})
  vim.api.nvim_create_user_command("AvanteUseCopilot", function() reconfigure("copilot") end, {})
  vim.api.nvim_create_user_command("AvanteUseGemini", function() reconfigure("gemini") end, {})
  vim.api.nvim_create_user_command("AvanteUseGeminiCLI", function() reconfigure("gemini-cli") end, {})
  vim.api.nvim_create_user_command("AvanteUseGeminiFlash", function() reconfigure("gemini-cli-flash") end, {})
end

return M
