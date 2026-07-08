# ~/.config/zsh/zshrc.d/00-env.zsh
# SPDX-License-Identifier: MIT

# Core environment + zsh housekeeping (XDG dirs already set in .zshenv)
export EDITOR="nvim"
export VISUAL="$EDITOR"
export PAGER="less"
export LESSCHARSET="utf-8"
# Set only LANG and let the LC_* categories inherit from it. LC_ALL is the
# nuclear override (forces every category) and is best reserved for ad-hoc use.
export LANG="en_US.UTF-8"
unset LC_ALL

# Zsh cache + history. ZSH_CACHE_DIR / ZSH_COMPDUMP are exported by .zshenv
# (using $HOST — no hostname fork); don't redefine them here.
export HISTFILE="${HISTFILE:-${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history}"
export HISTSIZE=100000
export SAVEHIST=100000

# Ensure dirs exist (guarded: skip the mkdir fork on the common path)
[[ -d "$ZSH_CACHE_DIR" && -d "${HISTFILE:h}" ]] || mkdir -p -- "$ZSH_CACHE_DIR" "${HISTFILE:h}"

# Saner umask for dev boxes
umask 022

# Fixed default model for Claude Code. Set here (repo-tracked, never written by
# Claude) rather than in ~/.claude/settings.json, which /model rewrites on every
# switch and is a stow symlink into this repo. Env var takes precedence over the
# settings.json `model` field, so this is the effective default for every new
# session. Switch per-session with `/model` → `s` (not Enter), or `claude
# --model <id>`; both are ephemeral and never touch settings.json.
export ANTHROPIC_MODEL="opus"

# vim: set ft=zsh ts=2 sw=2:

