# SPDX-License-Identifier: MIT

: "${XDG_CONFIG_HOME:=$HOME/.config}"
# Source environment variables from environment.d (if any)
if [ -d "$XDG_CONFIG_HOME/environment.d" ]; then
  for env_file in "$XDG_CONFIG_HOME"/environment.d/*.conf; do
    [ -r "$env_file" ] || continue
    set -o allexport
    . "$env_file"
    set +o allexport
  done
fi

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Completion dump belongs in the cache dir. Defined here (not only in the
# interactive rc) so any zsh that runs compinit — including a non-interactive
# `zsh -c` from tooling — never falls back to ~/.zcompdump. $HOST is a zsh
# builtin (no fork), and %%.* trims any domain to match `hostname -s`.
export ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}"
# Two-step expansion (not zsh's nested ${${...}}) so bash can source this file
# too (bootstrap does, under `set -u`).
_zshenv_host="${HOST:-${HOSTNAME:-host}}"
export ZSH_COMPDUMP="${ZSH_COMPDUMP:-$ZSH_CACHE_DIR/.zcompdump-${_zshenv_host%%.*}}"
unset _zshenv_host

# NOTE: do not set TERM here. The terminal emulator (and tmux) set the correct
# TERM; forcing xterm-256color clobbers truecolor/italics-capable values such as
# xterm-kitty / alacritty / tmux-256color, and .zshenv runs for non-interactive
# shells too.

# ----- Devcontainer goodies -----
: "${DEVCONTAINER_ENV_FILE:=$XDG_CONFIG_HOME/devcontainer_environment/environment_variables}"

if [ -f /.dockerenv ]; then
  # $TTY is a zsh builtin parameter — no `tty` fork. Default guards bash
  # sourcing under `set -u`, where TTY doesn't exist.
  if [ -n "${TTY:-}" ]; then
    export GPG_TTY="$TTY"
  fi
  if [ -r "$DEVCONTAINER_ENV_FILE" ]; then
    set -a
    . "$DEVCONTAINER_ENV_FILE"
    set +a
  fi
fi

# Rustup/cargo environment (guarded: not every box has a rust toolchain)
[ -r "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# vim: set ft=sh ts=2 sw=2:
