# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

# Find the nearest parent dir that has .venv/bin/activate
_nearest_venv_dir() {
  local d=$PWD
  while [[ $d != / ]]; do
    if [[ -r "$d/.venv/bin/activate" ]]; then
      echo "$d/.venv"
      return 0
    fi
    d=${d:h}
  done
  return 1
}

_python_venv_smart() {
  # If direnv is managing envs here, don't fight it
  # typeset -f _direnv_hook >/dev/null && return 0

  local target=$(_nearest_venv_dir)
  local current="$VIRTUAL_ENV"

  # Switch to nearest venv if different
  if [[ -n "$target" && "$current" != "$target" ]]; then
    command -v deactivate >/dev/null 2>&1 && [[ -n "$current" ]] && deactivate
    # shellcheck disable=SC1090
    source "$target/bin/activate" >/dev/null 2>&1
  # No venv found up the tree → deactivate if one is active
  elif [[ -z "$target" && -n "$current" ]]; then
    command -v deactivate >/dev/null 2>&1 && deactivate
  fi

  # Keep active venv's bin first in PATH (beats shims)
  if [[ -n "$VIRTUAL_ENV" ]]; then
    local vbin="$VIRTUAL_ENV/bin"
    path=(${^path:#$vbin})
    path=($vbin $path)
    export PATH="${(j.:.)path}"
  fi
}

autoload -Uz add-zsh-hook
# Make sure we run after most things
add-zsh-hook chpwd  _python_venv_smart
add-zsh-hook precmd _python_venv_smart
# Run once for current shell
_python_venv_smart

