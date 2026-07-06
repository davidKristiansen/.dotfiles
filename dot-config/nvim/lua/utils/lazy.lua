-- SPDX-License-Identifier: MIT
-- utils.lazy: declarative lazy-loading over vim.pack.
--
-- One entry point, `require('utils.lazy').add(spec)`, owns the whole lazy
-- lifecycle: a single load guard, the `vim.pack.add` call, trigger wiring
-- (keys / ft / event / cmd), the stub→real keymap swap, and error handling.
-- Adding a lazily-loaded plugin is a single declarative call.
--
-- Spec fields (all optional unless noted):
--   src   string|table     primary plugin source (url string or { src=, version= })
--   deps  list             extra sources loaded *before* src (url strings or tables).
--                          Deps are RAW vim.pack sources: they are installed and
--                          packadd'ed, nothing more. If a dep also has its own
--                          add() spec elsewhere, that spec's opts/config/keys are
--                          NOT run here — they still wait for their own trigger
--                          (duplicate vim.pack.add is idempotent, so this is safe).
--                          Pin a version only in a plugin's own spec, never in a
--                          deps entry: vim.pack silently adopts the last version
--                          it is handed, so divergent pins depend on load order.
--
--   -- choose a load tier (omit all triggers + `lazy` => vim.schedule, "later"):
--   lazy  false            load eagerly, now, during plugin/ sourcing
--   event string|list      load once on these autocmd events (e.g. 'InsertEnter')
--   ft    string|list|table FileType trigger. Table form: { pattern=, cond=fn(ev) }.
--                          On load the helper re-fires FileType so the plugin
--                          attaches to the already-open buffer.
--   cmd   string|list      stub user-command(s); first invocation loads then re-runs
--   keys  list             each entry: { lhs, rhs, desc=, mode=, silent=, expr= }.
--                          A stub is registered now (desc for which-key); the real
--                          keymap is installed from the same entry on load.
--
--   cond  fn():bool        gate: if it returns false the plugin is never loaded
--   init  fn()             runs eagerly at add() time (globals/options needed pre-load);
--                          wrapped in pcall — failures are reported, not fatal
--   opts  table|fn():table sugar: after load, calls require(main).setup(opts).
--                          `main` is inferred from the src repo name (strips a
--                          .nvim/.lua/-nvim suffix); set `main` to override.
--                          For anything beyond a plain setup(opts), use `config`.
--   main  string           module name for `opts` (only needed when inference fails)
--   config fn()            runs after vim.pack.add and after `opts` setup (extra
--                          keymaps, signs, autocmds, user cmds); wrapped in pcall
--   on_pack_changed fn(ev) PackChanged handler, registered before vim.pack.add

local M = {}

local function listify(v)
  if v == nil then
    return {}
  end
  if type(v) == 'table' then
    return v
  end
  return { v }
end

local function build_pack(spec)
  local pkgs = {}
  for _, d in ipairs(listify(spec.deps)) do
    pkgs[#pkgs + 1] = d
  end
  if spec.src then
    pkgs[#pkgs + 1] = spec.src
  end
  return pkgs
end

local function map_opts(k)
  return {
    desc = k.desc,
    silent = k.silent,
    noremap = k.noremap,
    expr = k.expr,
  }
end

-- Infer the module to `require()` for the `opts` sugar from the src repo
-- name: 'render-markdown.nvim' -> 'render-markdown', 'blink.pairs' -> 'blink.pairs'.
local function infer_main(spec)
  if spec.main then
    return spec.main
  end
  local src = type(spec.src) == 'table' and spec.src.src or spec.src
  if type(src) ~= 'string' then
    return nil
  end
  local name = src:gsub('/+$', ''):match('[^/]+$')
  return name and name:gsub('%.git$', ''):gsub('%.nvim$', ''):gsub('%.lua$', ''):gsub('%-nvim$', '')
end

local function report(spec, what, err)
  vim.notify(
    ('utils.lazy: %s failed for %s\n%s'):format(what, spec.src or '<anon>', err),
    vim.log.levels.ERROR
  )
end

function M.add(spec)
  -- Environment gate: never load (or set state) when the condition fails.
  if spec.cond and not spec.cond() then
    return
  end

  -- Eagerly-needed globals/options (e.g. conceal flags, laststatus).
  if spec.init then
    local ok, err = pcall(spec.init)
    if not ok then
      report(spec, 'init', err)
    end
  end

  local has_cmd = spec.cmd ~= nil
  local cmd_names = listify(spec.cmd)
  local loaded = false

  local function do_load()
    if loaded then
      return
    end
    loaded = true

    if spec.on_pack_changed then
      vim.api.nvim_create_autocmd('PackChanged', {
        callback = function(ev)
          spec.on_pack_changed(ev)
        end,
      })
    end

    local pkgs = build_pack(spec)
    if #pkgs > 0 then
      vim.pack.add(pkgs, { confirm = false })
    end

    -- Drop command stubs so the plugin can register its real commands.
    for _, name in ipairs(cmd_names) do
      pcall(vim.api.nvim_del_user_command, name)
    end

    -- `opts` sugar: plain require(main).setup(opts).
    if spec.opts then
      local ok, err = pcall(function()
        local main = assert(infer_main(spec), 'cannot infer main module; set `main`')
        local opts = type(spec.opts) == 'function' and spec.opts() or spec.opts
        require(main).setup(opts)
      end)
      if not ok then
        report(spec, 'opts setup', err)
      end
    end

    if spec.config then
      local ok, err = pcall(spec.config)
      if not ok then
        report(spec, 'config', err)
      end
    end

    -- Install real keymaps (overwrites the stubs registered below).
    for _, k in ipairs(listify(spec.keys)) do
      vim.keymap.set(k.mode or 'n', k[1], k[2], map_opts(k))
    end

    -- Re-fire FileType so a freshly-loaded ft plugin attaches to the current
    -- buffer. Guarded by `loaded`, so the recursive FileType is a no-op.
    if spec.ft then
      vim.cmd('doautocmd FileType')
    end
  end

  -- Eager.
  if spec.lazy == false then
    do_load()
    return
  end

  local has_trigger = spec.keys or spec.ft or spec.event or has_cmd

  -- keys: stub now (with desc), invoke the action on first press.
  for _, k in ipairs(listify(spec.keys)) do
    local rhs = k[2]
    vim.keymap.set(k.mode or 'n', k[1], function()
      do_load()
      if type(rhs) == 'function' then
        return rhs()
      end
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(rhs, true, false, true), 'm', false)
    end, map_opts(k))
  end

  -- ft: FileType autocmd, optional per-buffer predicate. The `loaded` guard
  -- (not `once`) keeps a predicate-gated trigger listening until it matches.
  if spec.ft then
    local pattern, ftcond = spec.ft, nil
    if type(spec.ft) == 'table' and spec.ft.pattern then
      pattern, ftcond = spec.ft.pattern, spec.ft.cond
    end
    vim.api.nvim_create_autocmd('FileType', {
      pattern = pattern,
      callback = function(ev)
        if ftcond and not ftcond(ev) then
          return
        end
        do_load()
      end,
    })
  end

  -- event: generic autocmd trigger.
  if spec.event then
    vim.api.nvim_create_autocmd(listify(spec.event), {
      once = true,
      callback = function()
        do_load()
      end,
    })
  end

  -- cmd: stub user-command that loads then re-runs with the original args.
  for _, name in ipairs(cmd_names) do
    vim.api.nvim_create_user_command(name, function(opts)
      do_load()
      vim.cmd(vim.trim(('%s %s'):format(name, opts.args or '')))
    end, { nargs = '*', desc = 'Lazy-load ' .. name })
  end

  -- No trigger and not eager => load on the next tick.
  if not has_trigger then
    vim.schedule(do_load)
  end

  -- Handle for external triggers (e.g. buffer-local maps) that must share this
  -- plugin's single load guard.
  return { load = do_load }
end

return M
