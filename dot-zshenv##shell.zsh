# SPDX-License-Identifier: MIT

: "${XDG_CONFIG_HOME:=$HOME/.config}"

# ----- Runtime dir -----
# XDG_RUNTIME_DIR comes from the login session (pam_systemd), never from this
# repo -- but a devcontainer inherits the *host* value (/run/user/$UID) while
# /run/user inside the container stays root-owned and empty. The path is both
# unwritable and unfixable: no process running as us can create it. Anything
# that opens a socket there fails, and Neovim is the loud one -- serverstart()
# refuses with "Please make sure 'XDG_RUNTIME_DIR' is writeable", which takes
# fzf-lua's whole setup down with it. `su`/`ssh` sessions with no seat land in
# the same hole, so this is not gated on /.dockerenv.
# $UID is a zsh *and* bash builtin (no fork), and the -w test short-circuits the
# mkdir on every shell after the first, so the common path stays fork-free.
_zshenv_uid="${UID:-$(id -u)}"
: "${XDG_RUNTIME_DIR:=/run/user/$_zshenv_uid}"
if [ ! -w "$XDG_RUNTIME_DIR" ]; then
  XDG_RUNTIME_DIR="${TMPDIR:-/tmp}/xdg-runtime-$_zshenv_uid"
  # 0700 is required by the XDG spec: the runtime dir must not be group- or
  # world-accessible, since it holds sockets and other live session state.
  [ -d "$XDG_RUNTIME_DIR" ] || mkdir -p -m 700 -- "$XDG_RUNTIME_DIR" 2>/dev/null
fi
if [ -w "$XDG_RUNTIME_DIR" ]; then
  export XDG_RUNTIME_DIR
else
  # Unset beats pointing at a broken path: most tools then pick their own
  # TMPDIR fallback (Neovim uses /tmp/nvim.$USER) instead of hard-failing.
  unset XDG_RUNTIME_DIR
fi
unset _zshenv_uid

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
