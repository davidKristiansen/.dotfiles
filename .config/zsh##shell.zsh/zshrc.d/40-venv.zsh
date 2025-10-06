# SPDX-License-Identifier: MIT
# Smart Python venv switcher with container-aware priority.
# - In containers: prefer `.venv.devcontainer`, fallback `.venv`
# - Outside: use `.venv`
# - Keeps $VIRTUAL_ENV/bin pinned at PATH[1]
# - Triggers on chpwd + precmd (and once at load)

# ----------------------------- helpers --------------------------------------

# Are we inside a (Docker/Podman/K8s) container?
_in_container() {
  # Fast path for Docker/Podman
  [[ -f "/.dockerenv" ]] && return 0
  # cgroup/containerd/k8s hints
  command -v grep >/dev/null 2>&1 && {
    \grep -qaE '(docker|containerd|kubepods|libpod)' /proc/1/cgroup 2>/dev/null && return 0
  }
  # systemd containers sometimes set envs (best-effort)
  [[ -n "$container" ]] && return 0
  return 1
}

# Find nearest parent dir containing any of the given venv names
# Usage: _nearest_venv_dir .venv.devcontainer .venv
_nearest_venv_dir() {
  local d=$PWD name
  while [[ $d != / ]]; do
    for name in "$@"; do
      if [[ -r "$d/$name/bin/activate" ]]; then
        echo "$d/$name"
        return 0
      fi
    done
    d=$(dirname "$d")   # portable parent-dir step
  done
  return 1
}

# Activate/deactivate + keep venv/bin first in PATH
# Track the root directory of the currently auto-activated venv
typeset -g _SMART_VENV_ROOT

__venv_switch_to() {
  local target="$1" current="$VIRTUAL_ENV"

  # If we have an active env and PWD has moved outside its root, drop target to force deactivation
  if [[ -n "$current" && -n "$_SMART_VENV_ROOT" ]]; then
    case $PWD/ in
      ($_SMART_VENV_ROOT/*) ;;  # still inside
      (*) [[ "$current" == $_SMART_VENV_ROOT/* ]] && target="" ;; # left project tree
    esac
  fi

  if [[ -n "$target" && "$current" != "$target" ]]; then
    command -v deactivate >/dev/null 2>&1 && [[ -n "$current" ]] && deactivate
    # shellcheck disable=SC1090
    source "$target/bin/activate" >/dev/null 2>&1 || return 1
    _SMART_VENV_ROOT="${target%/*}"   # parent dir of venv directory
  elif [[ -z "$target" && -n "$current" ]]; then
    if command -v deactivate >/dev/null 2>&1; then
      deactivate
    else
      # Fallback manual cleanup when no deactivate function exists
      path=(${^path:#$current/bin})
      export PATH="${(j.:.)path}"
      unset VIRTUAL_ENV
    fi
    _SMART_VENV_ROOT=""
  fi

  # Ensure active venv's bin is PATH[1]
  if [[ -n "$VIRTUAL_ENV" ]]; then
    local vbin="$VIRTUAL_ENV/bin"
    path=(${^path:#$vbin})   # remove any existing occurrences
    path=($vbin $path)       # prepend
    export PATH="${(j.:.)path}"
  fi
}

# ----------------------------- main hook ------------------------------------

_python_venv_smart() {
  # If direnv is managing things here, let it dance alone
  # typeset -f _direnv_hook >/dev/null 2>&1 && return 0

  local target
  if _in_container; then
    # Container: prefer .venv.devcontainer, then .venv
    target=$(_nearest_venv_dir .venv.devcontainer .venv)
  else
    # Host: just .venv
    target=$(_nearest_venv_dir .venv)
  fi

  __venv_switch_to "$target"
}

# --------------------------- autoload hooks ---------------------------------

autoload -Uz add-zsh-hook
add-zsh-hook chpwd  _python_venv_smart
add-zsh-hook precmd _python_venv_smart
_python_venv_smart  # run once now

