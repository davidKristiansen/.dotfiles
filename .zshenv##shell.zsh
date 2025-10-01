# SPDX-License-Identifier: MIT

# Source environment variables from environment.d (if any)
if [ -d "$XDG_CONFIG_HOME/environment.d" ]; then
  for env_file in "$XDG_CONFIG_HOME"/environment.d/*.conf; do
    [ -r "$env_file" ] || continue
    set -o allexport
    . "$env_file"
    set +o allexport
  done
fi

# ----- Safe XDG defaults (before mkdir) -----
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_BIN_HOME:=$HOME/.local/bin}"

# Ensure XDG dirs exist
mkdir -p "$XDG_CONFIG_HOME" \
         "$XDG_DATA_HOME" \
         "$XDG_STATE_HOME/zsh" \
         "$XDG_CACHE_HOME/zsh" \
         "$XDG_BIN_HOME"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export TERM=xterm-256color

# ----- Devcontainer goodies -----
: "${DEVCONTAINER_ENV_FILE:=$XDG_CONFIG_HOME/devcontainer_environment/environment_variables}"

if [ -f /.dockerenv ]; then
  if [ -t 1 ] 2>/dev/null; then
    GPG_TTY="$(tty 2>/dev/null || true)"; export GPG_TTY
  fi
  if [ -r "$DEVCONTAINER_ENV_FILE" ]; then
    set -a
    . "$DEVCONTAINER_ENV_FILE"
    set +a
  fi
fi

# vim: set ft=sh ts=2 sw=2:

