# SPDX-License-Identifier: MIT

: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_BIN_HOME:=$HOME/.local/bin}"

# Ensure XDG dirs exist
mkdir -p "$XDG_CONFIG_HOME" \
         "$XDG_DATA_HOME" \
         "$XDG_STATE_HOME/zsh" \
         "$XDG_CACHE_HOME/zsh" \
         "$XDG_BIN_HOME"

export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
export TERM=xterm-256color

###############################################################################
# Load user environment variables and GPG_TTY if inside Docker

: "${DEVCONTAINER_ENV_FILE:=$XDG_CONFIG_HOME/devcontainer_environment/environment_variables}"

if [ -f /.dockerenv ]; then
  if [ -t 1 ] 2>/dev/null; then
    export GPG_TTY="$(tty 2>/dev/null || true)"
  fi

  if [ -r "$DEVCONTAINER_ENV_FILE" ]; then
    set -a
      # shellcheck disable=SC1090
      . "$DEVCONTAINER_ENV_FILE"
    set +a
  fi
fi

# vim: set ft=sh ts=2 sw=2:

