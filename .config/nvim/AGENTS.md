# Agents

This file explains the structure of this Neovim configuration and provides guidelines for LLM agents interacting with this project.

## Folder Structure

Top-level:
* `.luarc.json` – Lua language server configuration (diagnostics / runtime settings for this config).
* `init.lua` – Entry point loaded by Neovim; typically bootstraps plugin and core setups.
* `AGENTS.md` – This guidance and activity log file.

`lua/` – All Lua source for this configuration:

* `lua/core/` – Core editor behavior and UX glue.
  * `autocmds.lua` – Global autocommands (e.g. events, formatting triggers, highlight refresh, etc.).
  * `colorscheme.lua` – Colorscheme application or related highlight adjustments.
  * `keymaps.lua` – Global key mappings (non–buffer-local); LSP buffer-local maps live elsewhere.
  * `options.lua` – Vim options (UI, indentation, search, etc.).

* `lua/plugins/` – Plugin declarations and per‑plugin setup modules.
  * `init.lua` – Central plugin registration + ordered setup calls.
  * `avante.lua` – Configuration for Avante AI assistant (dynamic provider switching logic).
  * `blink.lua` – Blink completion engine setup (including integrated Copilot / snippets sources).
  * `copilot.lua` – GitHub Copilot core configuration (auth / suggestion behavior).
  * `lspconfig.lua` – (If present) supplementary glue or overrides related to `nvim-lspconfig` (may wrap/augment builtin behavior).
  * `mason.lua` – Mason package manager base setup.
  * `mason-lspconfig.lua` – Bridges Mason‑installed servers with `lspconfig` auto-setup.
  * `treesitter.lua` – Syntax tree parsing (languages, highlight, textobjects if configured).
  * `oil.lua` – File explorer (Oil.nvim) setup.
  * `mini_pick.lua` – mini.pick fuzzy finder configuration.
  * `luasnip.lua` – Snippet engine setup + snippet source loading.

* `lua/lsp/`
  * `init.lua` – LSP attach-time logic (buffer-local keymaps, capabilities, etc.). Per‑language files are not currently split out; consolidation keeps things minimal.

* `lua/utils/`
  * `once.lua` – Utility helper(s) (e.g., ensure one-time execution patterns).

Removed / Not Present Anymore (previous doc references):
* `lua/config/` directory – consolidated into `lua/core/`.
* Per‑language LSP config files (`basedpyright.lua`, `bashls.lua`, etc.) – not currently present; logic likely handled implicitly by mason-lspconfig auto-setup or deferred for future expansion.

## LLM Agent Behavior

As an LLM agent interacting with this project, you should adhere to the following guidelines:

### 1. Understand the Project

This is a Neovim configuration. Any changes you make can directly impact the user's development environment. Be mindful of this and prioritize making safe, incremental changes.

### 2. Convention Adherence

Follow the existing structure and coding style. For example:

* New plugin configurations belong in `lua/plugins/` (one file per logical plugin/config group).
* LSP buffer-local logic belongs in `lua/lsp/init.lua` (create per-language modules only when complexity justifies it).
* Core editor behavior (options, keymaps, autocmds) belongs in `lua/core/`.
* Utility helpers go in `lua/utils/`.
* When adding a new plugin, declare it in `lua/plugins/init.lua` and create a sibling module for its setup if non-trivial.

### 3. Verification

After making changes, verify them to the best of your ability. Since you cannot run Neovim directly here, you should at least:

* Check Lua syntax mentally or by loading small snippets if possible.
* Ensure required modules are properly required in `lua/plugins/init.lua`.
* Avoid introducing global namespace pollution.

### 4. Communication

* Explain your plan before making structural or behavioral changes.
* Be concise and explicit about side effects.
* Ask for clarification if a request could be interpreted multiple ways.

## Agent Activity Log

### 2025-09-13: Keymap consolidation and CopilotChat removal
Actions Performed:
- Removed `lua/plugins/copilot_chat.lua` plugin file.
- Cleaned plugin declaration: deleted commented CopilotChat spec line in `lua/plugins/init.lua`.
- Ensured no lingering `require("plugins.copilot_chat")` setup calls remained.
- Standardized formatting keymap: replaced old global `<leader>if` with `<leader>cf` in `lua/core/keymaps.lua`.
- Removed buffer-local `<leader>cf` mapping from LSP `LspAttach` autocmd in `lua/lsp/init.lua` to avoid duplicate / precedence ambiguity.
- Added Avante chat keybinding: `<leader>ac` mapped to `:AvanteChat` (global normal-mode mapping) in `lua/core/keymaps.lua`.
- Left existing LSP action mappings intact (`<leader>ca`, `<leader>cr`) for future potential namespacing work.

Rationale:
- Eliminated a conflicting `<leader>ca` overlap between CopilotChat and LSP by removing the plugin entirely per user decision.
- Unified formatting under a single mnemonic (`cf` = code format) and removed redundant buffer-local variant.
- Established an initial Avante prefix starter (`ac` = Avante Chat) to pave the way for possible future Avante-related mappings (e.g., `aa` for ask, `ar` for refactor, etc.).

Follow-up Suggestions (Not Implemented):
- Consider reserving `<leader>a` namespace exclusively for AI/Avante related actions.
- Optionally migrate LSP maps under a `<leader>l` namespace for clearer separation if collisions reappear.
- Add `desc` metadata to global mappings for improved which-key style discoverability.

Integrity Note:
All modifications were limited to keymap definitions and plugin declarations; no runtime logic of other plugins was altered.

### 2025-09-13: Added move line keymaps
Actions Performed:
- Added global Alt-j / Alt-k mappings in lua/core/keymaps.lua:
  - Normal mode: <A-j>/<A-k> move current line down/up.
  - Visual mode: <A-j>/<A-k> move selected block and preserve selection with reindent.
  - Insert mode: <A-j>/<A-k> move line then return to original insert position.
Rationale:
- Provides fast structural editing without leaving current mode.
- Consistent mnemonic across modes reduces cognitive load.
Notes:

### 2025-09-13: Added fzf-lua fuzzy finder
Actions Performed:
- Added `ibhagwan/fzf-lua` to plugin spec in `lua/plugins/init.lua`.
- Created `lua/plugins/fzf.lua` with basic `fzf-lua` setup (window sizing, files, grep opts).
- Required the new module in plugin setup sequence (`require("plugins.fzf").setup()`).
- Replaced `<leader>f` mapping logic in `lua/core/keymaps.lua` with a protected call: tries `fzf-lua` file picker (`fzf.files()`), falls back to `:Pick files` if plugin not loaded.

Rationale:
- Provide a powerful, fully-featured fuzzy finder while retaining graceful fallback to lightweight mini.pick.
- pcall wrapper avoids runtime errors during partial or first-time plugin installation.

Notes / Follow-up (Optional):
- Could add additional mappings: `<leader>fg` for live grep, `<leader>fb` for buffers, `<leader>fr` for oldfiles via fzf-lua.
- Consider centralizing picker mappings under a dedicated section if more are added.


### 2025-09-13: Removed fzf-lua and restored pure mini.pick keymaps

### 2025-09-13: Removed fzf-lua and expanded mini.pick keymaps
Actions Performed:
- Removed `ibhagwan/fzf-lua` from plugin spec in `lua/plugins/init.lua`.
- Deleted `lua/plugins/fzf.lua` configuration module.
- Dropped `require("plugins.fzf").setup()` from plugin initialization sequence.
- Reverted `<leader>f` mapping to a direct `:Pick files` invocation (removed fallback logic).
- Ensured expanded mini.pick keymaps remain: `<leader>ff` (files), `<leader>fg` (grep), `<leader>fb` (buffers), `<leader>fr` (oldfiles), `<leader>h` (help).

Rationale:
- Simplify dependency footprint and rely on the lighter built-in fuzzy finder approach via mini.pick.
- Reduce maintenance overhead (fzf native binary, window layout tuning) in favor of minimal configuration.

Notes / Follow-up:
- If performance becomes a concern with large repos, can reintroduce fzf-lua or telescope with lazy loading.
- Consider adding `<leader>fs` for document symbols (if mini.pick or an LSP-based picker is added later).
- Potential future grouping: dedicate `<leader>p` prefix specifically for project navigation if keyspace under `<leader>f` becomes crowded.

Actions Performed:
- Removed `ibhagwan/fzf-lua` from plugin specification in `lua/plugins/init.lua`.
- Deleted `lua/plugins/fzf.lua` configuration module.
- Removed `require("plugins.fzf").setup()` from plugin initialization sequence.
- Reverted `<leader>f` mapping to direct `:Pick files` command.
- Ensured supplemental mini.pick mappings present: `<leader>ff` (files), `<leader>fg` (grep), `<leader>fb` (buffers), `<leader>fr` (oldfiles), `<leader>h` (help).

Rationale:
- Simplified dependency footprint; mini.pick deemed sufficient for current workflow needs.
- Reduced maintenance surface (no need to sync fzf-lua specific tweaks / binaries).

Notes / Follow-up (Optional):
- If performance concerns arise in very large repos, reconsider reintroducing a more optimized picker.
- Could add custom mini.pick sources (e.g., recent git branches, commands) if needed.

Integrity Note:
All changes confined to plugin declarations, a deleted plugin config file, and keymap adjustments; no functional regressions expected beyond losing advanced fzf-lua UI features.


### 2025-09-13: Added which-key and lualine
Actions Performed:
- Added `folke/which-key.nvim` and `nvim-lualine/lualine.nvim` to plugin specs in `lua/plugins/init.lua`.
- Created `lua/plugins/which_key.lua` with guarded setup plus registration of high-level leader groups (`f`, `c`, `a`).
- Created `lua/plugins/lualine.lua` with statusline configuration (auto theme, globalstatus, diagnostics from LSP, path-aware filename, separators, inactive sections) and extensions list.
- Updated plugin init sequence to require both new modules after existing setups.

Rationale:
- which-key improves discoverability of existing and future keymaps, reducing cognitive load.
- lualine provides a concise, information-rich statusline integrated with diagnostics and Git metadata.

Notes / Follow-up (Optional):
- Consider adding more which-key subgroup registrations (e.g., `l` for LSP if namespacing later, `g` for Git when git integrations are added).
- Potential future lualine enhancements: custom component showing current AI provider (Avante), or recording format-on-save status.

Integrity Note:
Changes isolated to plugin declarations, two new config modules, and initialization ordering; no disruptive edits to existing core logic.


### 2025-09-13: Migrated which-key config to new API
Actions Performed:
- Replaced deprecated `window` option with `win` in which-key setup.
- Switched from legacy table registration to new `wk.add` spec-style group registration for leader groups (`<leader>a`, `<leader>c`, `<leader>f`).
- Verified removal of deprecation warnings in config output.
Rationale:
- Align with current which-key API to avoid future breakage and reduce noise from warnings.
Notes / Follow-up:
- Consider adding more granular group specs (e.g., `<leader>l` for LSP if namespacing later, `<leader>g` for Git when added).
Integrity Note:
- Only configuration adjustments; no functional keybind behavior changed.


### 2025-09-13: Added descriptions to global keymaps
Actions Performed:
- Ensured each mapping in `lua/core/keymaps.lua` includes a `desc` field for which-key and future discoverability tools.
- Standardized wording (imperative verbs, consistent capitalization).
Rationale:
- Improves on-demand keymap discovery and consistency in help popups.
Integrity Note:
- No functional behavior changed; purely metadata enhancements.


### 2025-09-13: Enhanced Avante configuration (@ file reference + provider cycling)
Actions Performed:
- Added provider cycling keymap `<leader>ap` (normal mode, Avante/Avante-sidebar buffers) to rotate between `copilot`, `openai`, and `gemini` providers.
- Implemented dynamic header regeneration on provider switch (retains fresh auth tokens) via `reconfigure()` helper.
- Added insert-mode '@' interception in `avante-input` buffer that opens a `mini.pick` file selector and inserts an `@relative/path ` reference on accept (falls back to literal '@' if picker unavailable or cancelled).
- Added alternate `<C-f>` trigger for manual invocation of the same file reference picker.
- Introduced fixed window sizing (winfixwidth / winfixheight) for all Avante UI buffers to reduce layout jitter.
- Documented a commented placeholder for a potential future native `mentions` API block (non-breaking, explanatory only).

Rationale:
- Streamlines multi-provider experimentation without manual commands.
- Provides ergonomic in-chat file referencing without leaving the Avante input context.
- Maintains resilience (graceful fallback when `mini.pick` not present or user cancels).

Safety / Integrity Notes:
- No changes made to external provider request semantics beyond header refresh logic already in place.
- '@' mapping is buffer-local to `avante-input`, avoiding interference with global insert-mode usage.
- Falls back safely, inserting a plain '@' if the picker fails so user intent is preserved.

Follow-up (Optional):
- If/when Avante exposes an official mentions system, replace the custom mapping with native configuration.
- Consider adding a statusline component showing the active provider (lualine custom component) for quick visual feedback.


### 2025-09-13: Lualine separators updated & removed obsolete fzf extension
Actions Performed:
- Changed `section_separators` from angled/Powerline style to solid block characters (`█`) in `lua/plugins/lualine.lua`.
- Left `component_separators` as thin vertical bars (`│`) for subtle intra‑segment division.
- Removed `'fzf'` from the lualine `extensions` list (now only `'quickfix'`) since `fzf-lua` plugin was previously removed.

Rationale:
- Block separators provide a stronger visual boundary between major statusline sections while remaining mono-font friendly.
- Eliminates a stale extension reference that could cause unnecessary extension load attempts or future warnings.

Integrity Note:
- Purely stylistic / declarative configuration change; no runtime behavior or dependencies altered.

Follow-up (Optional):
- Add a custom lualine component to surface current Avante provider (e.g., `copilot|openai|gemini`).
- Consider adding `nvim-web-devicons` for richer filename and which-key iconography if desired.
- Evaluate whether diagnostics component should display only errors/warnings (tunable via `diagnostics_color` or custom formatter) to reduce noise.


### 2025-09-13: Normalized dial.nvim configuration
Actions Performed:
- Ensured `lua/plugins/dial.lua` uses a clean module pattern (`local M` + `M.setup()`) consistent with other plugin configs.
- Registered comprehensive augend groups (default + example `mygroup`) including: hex colors, decimal & hex integers, dates, booleans, semver, logical operators (`and`/`or`, `&&`/`||`), on/off toggles, Python-style `True`/`False`, log levels, and Markdown heading levels.
- Added descriptive which-key friendly keymaps for normal/visual increment & decrement plus sequential variants (`<C-a>`, `<C-x>`, `g<C-a>`, `g<C-x>` in normal/visual modes).
- Wrapped a future‑proof conditional around a potential `dial.setup` call to avoid invoking a non-existent setup function (prevents runtime errors if upstream has not implemented it yet).
- Removed legacy malformed structure noted in earlier version (dangling `keys =` table outside a spec) by consolidating logic inside `setup()`.

Rationale:
- Brings dial.nvim config in line with project conventions for reliability and maintainability.
- Prevents silent failures or errors during startup by guarding optional API calls.
- Enhances discoverability and consistency via `desc` metadata on mappings.

Integrity Note:
- Changes are additive and safe; no external behavior altered beyond enabling reliable increment/decrement functionality.

Follow-up (Optional):
- Consider exposing a command or which-key subgroup for switching augend groups dynamically.
- Potential addition of custom augends (e.g., cycling through test names or environment labels) if workflow demands.

### 2025-09-13: Added tmux integration (nvim-tmux-navigation + vim-tpipeline)
Actions Performed:
- Added `alexghergh/nvim-tmux-navigation` and `vimpostor/vim-tpipeline` to plugin declarations in `lua/plugins/init.lua`.
- Created `lua/plugins/tmux_navigation.lua` with guarded `setup()` configuring `disable_when_zoomed = true`.
- Created `lua/plugins/tpipeline.lua` applying settings only when inside a tmux session (`$TMUX` present) and linking `StatusLine` to `WinSeparator` plus minimal `fillchars` augmentation.
- Appended setup calls (`require("plugins.tmux_navigation").setup()` and `require("plugins.tpipeline").setup()`) to the ordered plugin initialization sequence.
- Added pane navigation keymaps (`<C-h> <C-j> <C-k> <C-l> <C-\>` and `<C-Space>`) in `lua/core/keymaps.lua` with descriptive `desc` metadata.

Rationale:
- Provides seamless movement between Neovim splits and tmux panes using a familiar `<C-h/j/k/l>` mental model.
- Embeds the Neovim statusline cleanly into tmux without duplicating configuration already handled by lualine (kept logic minimal and conditional).

Safety / Integrity Notes:
- Tpipeline config is a no-op outside tmux sessions, avoiding unnecessary global side effects.
- Keymaps chosen do not override existing critical mappings in this config; they align with common tmux+Neovim workflows.

Follow-up (Optional):
- Consider adding conditional fallback to native window navigation if the plugin fails to load.
- Potential future lualine component to indicate when a tmux zoom is active (if exposed via environment or tmux vars).
- Evaluate whether to gate `<C-Space>` mapping on terminal / GUI support if conflicts arise.

### 2025-09-13: Integrated render-markdown.nvim
Actions Performed:
- Added `MeanderingProgrammer/render-markdown.nvim` to plugin declarations in `lua/plugins/init.lua` alongside its icon dependency `nvim-web-devicons` (already present) and ensured `nvim-treesitter` (already declared) is available.
- Created `lua/plugins/render_markdown.lua` implementing a guarded `setup()` that mirrors the prior lazy spec options (html comment conceal, full style code blocks with disabled background, inline/block heading rendering, custom heading icons, foreground highlight groups, and no backgrounds).
- Inserted `require("plugins.render_markdown").setup()` into the ordered initialization sequence so configuration is applied after core UI components.

Rationale:
- Centralizes Markdown rendering enhancements in a dedicated module consistent with existing project structure.
- Ensures graceful failure (pcall) if plugin not yet installed while keeping startup resilient.

Integrity Notes:
- Only additive changes; no existing mappings or core behaviors altered.
- Highlights referenced (RenderMarkdownCode / RenderMarkdownH1..H6) assume user colorscheme or custom highlight definitions will supply groups; absence results in default fallback without error.

Follow-up (Optional):
- Define explicit highlight groups (e.g., in colorscheme.lua) for RenderMarkdown* if finer color control desired.
- Consider enabling differential backgrounds per heading level for improved visual hierarchy once palette finalized.
- Evaluate performance impact on very large Markdown buffers; if needed, gate advanced rendering behind a size heuristic.


### 2025-09-13: Fixed double statusline inside tmux
Actions Performed:
- Updated `lua/plugins/tpipeline.lua` to set `vim.o.laststatus = 0` when inside a tmux session, hiding Neovim's native statusline while tpipeline embeds lualine into tmux.
- Stored previous `laststatus` value and restored it on `VimLeavePre` for safety if detaching or reusing config outside tmux.
- Retained highlight link (`StatusLine` -> `WinSeparator`) and thin fillchars while simplifying display to a single embedded line.
- Left lualine's `globalstatus = true` untouched (cancellation of conditional adjustment) since suppression at Vim UI layer is sufficient.

Rationale:
- Eliminates redundant stacked statuslines (tmux + Neovim) improving vertical space and visual clarity.
- Restoration logic prevents unintended side effects when exiting Neovim or reattaching outside tmux.

Integrity Notes:
- Change scoped to tmux sessions only (`$TMUX` gate). Outside tmux the statusline behavior is unchanged.
- No modification to lualine module; relies on tpipeline to surface content upstream to tmux.

Follow-up (Optional):
- Provide a user command (e.g., `:ToggleTmuxEmbed`) to re-enable native statusline temporarily for debugging.
- Add a lualine component indicating when embedding is active (reads environment or a global flag set by tpipeline setup).
- Consider a heuristic to revert `laststatus` if `$TMUX` becomes unset mid-session (rare scenario when tmux dies).


### 2025-09-13: Reordered plugin declarations for readability
Actions Performed:
- Regrouped entries in `lua/plugins/init.lua` under clearly labeled sections (Core, LSP / Language, Completion & AI, Snippets, Navigation, Editing Enhancements, UI / Visuals, Tmux Integration).
- Ensured ordering within groups reflects dependency and load logic (e.g., Treesitter after mason specs but before completion stack usage; completion engine `blink.cmp` before its sources and AI assistants).
- Verified setup call sequence already matched grouped functional order; no changes required beyond visual alignment.
- Left existing versions / pinned tags (blink.cmp v1.6.0) intact.

Rationale:
- Improves scanability and future maintenance (easy insertion point per category).
- Reduces risk of accidental misordering when adding related plugins.

Integrity Notes:
- No functional changes; only reordering/comments in declaration block.
- Setup invocation order remains semantically identical; runtime behavior unaffected.

Follow-up (Optional):
- Consider alphabetizing within each group once the set stabilizes.
- Introduce a CI/lint check (stylua or custom script) to enforce grouping conventions if churn increases.


### 2025-09-13: Added descriptions to LSP buffer-local keymaps
Actions Performed:
- Updated `lua/lsp/init.lua` to attach buffer-local keymaps with `desc` metadata via a helper `bmap` wrapper.
- Added descriptions for: Hover, Go to Definition, List References, Go to Declaration, Go to Implementation, Rename Symbol, Code Action.
- Left global format mapping centralized in `core/keymaps.lua` (did not reintroduce buffer-local `<leader>cf`).

Rationale:
- Enhances which-key style discoverability and improves clarity in future tooling that surfaces mapping metadata.
- Centralizing description assignment in helper reduces duplication and future maintenance overhead.

Integrity Notes:
- No functional behavior change beyond adding user-facing descriptions. Existing key bindings remain identical.
- Mapping helper continues to scope mappings to the buffer from the `LspAttach` event, preventing global leakage.

Follow-up (Optional):
- Consider namespacing LSP mappings under a dedicated `<leader>l` prefix in future refactors to reduce potential collisions.
- Potential addition: map `<leader>cd` for diagnostics (e.g., `vim.diagnostic.open_float`) with a clear description.


### 2025-09-13: Integrated mini.starter (start screen)
Actions Performed:
- Added `echasnovski/mini.starter` to plugin declarations under UI / Visuals group in `lua/plugins/init.lua`.
- Created `lua/plugins/mini_starter.lua` providing guarded `M.setup()` that configures a custom ASCII logo header, recent files section, builtin actions, and custom shortcuts (New file, Find files, Live grep, Open Oil, Quit).
- Inserted `require("plugins.mini_starter").setup()` into UI / Visuals setup sequence after other interface components.
- Added `<leader>ss` mapping in `lua/core/keymaps.lua` to open the start screen on demand (protected with pcall).

Rationale:
- Provides a lightweight, fast start screen with quick access to recent files and common actions while maintaining minimal dependency footprint.
- Centralizes startup UX improvements without impacting headless or file-argument launches.

Integrity Notes:
- Setup wrapped in pcall to avoid errors if plugin not yet installed on first run.
- Does not override existing behavior when launching Neovim with file arguments (start screen only appears when manually invoked or when user configures further automation).

Follow-up (Optional):
- Add dynamic footer info (e.g., git branch, plugin count) or session management entries.
- Consider integrating project root detection for curated recent files per project scope.
- Optionally auto-open mini.starter on empty `nvim` launch instead of Oil, or provide a toggle between the two.



### 2025-09-13: Integrated mini.surround via monorepo
Actions Performed:
- Confirmed consolidated Mini ecosystem usage through single monorepo spec `nvim-mini/mini.nvim` (already present in plugin list) instead of individual module specs.
- Created `lua/plugins/mini_surround.lua` implementing guarded setup (`pcall(require, "mini.surround")`) to avoid errors during first-time install.
- Added explicit, mnemonic surround mappings: `sa` (add), `sd` (delete), `sf` (find right), `sF` (find left), `sh` (highlight), `sr` (replace), `sn` (update n_lines).
- Inserted `require("plugins.mini_surround").setup()` into the Editing Enhancements section of `lua/plugins/init.lua` immediately after `dial` setup.
- Removed earlier placeholder content (previous accidental mini.pick duplication) by overwriting the surround module with the correct implementation.

Rationale:
- Unifies Mini plugin management, reducing load order complexity and potential version drift between individual mini.* modules.
- Provides ergonomic, discoverable surround operations without introducing an additional external dependency (e.g., nvim-surround), keeping footprint minimal.
- Guarded require pattern maintains resilient startup during plugin bootstrap phases.

Integrity Notes:
- No global namespaces polluted; all logic encapsulated in module pattern consistent with repository conventions.
- Surround mappings chosen to avoid collisions with existing keymaps (prefix `s` currently unused elsewhere in config).
- Default Mini.surround behavioral parameters retained except for explicit mapping table and `respect_selection_type` for predictable visual-mode edits.

Follow-up Suggestions (Optional):
- Consider documenting surround keymaps in which-key by adding a group (e.g., registering prefix `s` with labels) if discoverability needs increase.
- Potential future tweak: add custom surroundings (e.g., for markdown emphasis or JSX tags) via `custom_surroundings` option.
- Evaluate introducing a toggle command to temporarily disable surround mappings in filetypes where `s` is heavily repurposed (currently not an issue).


