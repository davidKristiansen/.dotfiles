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

