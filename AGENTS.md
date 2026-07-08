# Agents

Personal dotfiles, deployed with [`stow.sh`](https://github.com/davetothek/stow.sh)
(a single-file symlink manager) and bootstrapped with [`mise`](https://mise.jdx.dev)
for tool installation. One repo drives laptops, workstations, and devcontainers;
what gets deployed on each is decided by **conditional filenames**, not branches.

## Layout & deployment

Files live un-hidden in the repo under `dot-`-prefixed packages and are symlinked
into `$HOME` by `stow.sh --dotfiles`, which translates a leading `dot-` to `.` **per
path component**:

```
dot-config/nvim/init.lua   →   ~/.config/nvim/init.lua
dot-zshenv##shell.zsh       →   ~/.zshenv   (## suffix stripped, see below)
```

Top-level packages: `dot-config/`, `dot-claude/`, `dot-local/`, `dot-gnupg/`,
`dot-pi/`, plus a few root files. Running `stow.sh --dotfiles` from the repo root
stows them all into `~`.

- `.stowignore` — glob patterns for files that live here but must **not** be
  symlinked (project scaffolding: `bootstrap`, `AGENTS.md`, `.github/`, `.gitignore`,
  `.pre-commit-config.yaml`, `.secrets.baseline`, and this repo's own `.claude/`).

## Conditional files (`##` annotations)

A `##<condition>` suffix on any path component makes that file/dir deploy only when
the condition holds. **The suffix is stripped from the symlink name**, so
`20-host.toml##!docker` deploys as `20-host.toml`. Multiple conditions can be
comma-joined (`file##os.linux,exe.nvim` = both must hold); a leading `!` negates.

Conditions used in this repo (all `stow.sh` built-ins — no custom scripts installed):

| Annotation      | Deploys the file only when…                                  |
|-----------------|--------------------------------------------------------------|
| `##exe.<cmd>`   | `<cmd>` is on `PATH` (`command -v`). Most configs are gated this way so an app's config only lands if the app exists. |
| `##wm.sway`     | `sway` is on `PATH` (same `command -v` check) — Sway/Wayland-only configs. |
| `##shell.zsh`   | `$SHELL`'s basename is `zsh`.                                 |
| `##laptop`      | A battery exists (`/sys/class/power_supply/BAT*`).           |
| `##!docker`     | **Not** inside a container (no `/.dockerenv`).               |

Other built-ins available if needed: `os.<name>`, `desktop` (no battery), `wsl`.

**Consequence for `exe.*`:** a config is skipped if its binary isn't installed *at
stow time*. This is why `bootstrap` stows twice (below) — install the apps, then
re-stow so their now-present configs link.

## Bootstrap

`./bootstrap` is idempotent (safe to re-run; it `git pull`s first). It resolves a
chicken-and-egg problem between stow and mise with a **two-pass stow**:

1. **Pass 1 — mise config only.** `mise install` reads `~/.config/mise/conf.d/*.toml`,
   which only exist once stowed, so we stow *just* that subtree first:
   ```sh
   stow.sh --dotfiles -f -d dot-config -t "$XDG_CONFIG_HOME/mise" mise
   ```
   (stow strips the `mise` package level, so `conf.d/*` lands at `~/.config/mise/conf.d/`.)
2. **Install** mise + all tools from the conf.d tiers.
3. **Pass 2 — full stow.** `stow.sh --dotfiles -f`. Now the tools exist, so every
   `##exe.X` config whose binary mise just installed resolves and gets linked.

Note: most `##exe.*` gates are system/GUI apps installed via apt, *not* mise —
`bootstrap` has no apt step, so those configs link only once the app is present.
Re-run `./bootstrap` after installing system packages to pick them up.

### mise tiers (`dot-config/mise/conf.d/`)

Split by host type via the same `##` conditions, loaded in numeric order:

- `00-core.toml` — CLI essentials, everywhere (incl. containers).
- `10-dev.toml` — lightweight dev tooling, everywhere.
- `20-host.toml##!docker` — heavy toolchains (rust, cmake, …), real hosts only.
- `30-gui.toml##laptop` — GUI/hardware-bound tools, laptop only.

## Tooling

- The git pager is [`hunk`](https://github.com/modem-dev/hunk) (`core.pager = hunk pager`),
  an interactive TUI for humans. When reading diffs programmatically, use
  `git --no-pager diff` (or pipe to `cat`) so output is captured as plain text
  instead of launching the viewer.

## Subsystem instructions

- **Neovim:** see `dot-config/nvim/AGENTS.md` for architecture, plugin management,
  keymaps, and LSP configuration.

## Guidelines

- Minimize scope; touch only what the request needs.
- Ask for clarification before large structural refactors.
- Do NOT maintain a manual changelog; git history provides traceability.
- Do NOT create a new branch unless explicitly asked.
