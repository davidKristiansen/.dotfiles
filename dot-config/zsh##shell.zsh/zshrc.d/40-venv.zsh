# SPDX-License-Identifier: MIT
# Smart Python venv switcher with container-aware priority.
# - In containers: prefer `.venv.devcontainer`, fallback `.venv`
# - Outside: use `.venv`
# - Keeps $VIRTUAL_ENV/bin pinned at PATH[1]
# - Triggers on chpwd + precmd (and once at load)

# ----------------------------- helpers --------------------------------------

# Are we inside a (Docker/Podman/K8s) container? Detected ONCE at load —
# container status can't change within a shell's lifetime, and the old
# per-chpwd `grep /proc/1/cgroup` forked on every directory change.
typeset -gi _SMART_VENV_IN_CONTAINER=0
() {
  # Fast path for Docker/Podman
  [[ -f /.dockerenv ]] && { _SMART_VENV_IN_CONTAINER=1; return }
  # systemd containers sometimes set $container (best-effort)
  [[ -n "$container" ]] && { _SMART_VENV_IN_CONTAINER=1; return }
  # cgroup/containerd/k8s hints (zsh pattern match, no grep fork)
  local cgroup=""
  [[ -r /proc/1/cgroup ]] && cgroup="$(</proc/1/cgroup)" 2>/dev/null
  [[ "$cgroup" == *(docker|containerd|kubepods|libpod)* ]] && _SMART_VENV_IN_CONTAINER=1
}

_in_container() { (( _SMART_VENV_IN_CONTAINER )) }

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
    d=${d:h}            # zsh native parent-dir step (no subprocess)
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

# Drop a venv whose interpreter has gone. A deleted or moved checkout
# leaves $VIRTUAL_ENV naming nothing. Every tool that reads it then warns
# or picks the wrong interpreter. Return 0 only when something changed.
__venv_drop_if_gone() {
  [[ -n "$VIRTUAL_ENV" && ! -x "$VIRTUAL_ENV/bin/python" ]] || return 1
  path=(${^path:#$VIRTUAL_ENV/bin})
  export PATH="${(j.:.)path}"
  unset VIRTUAL_ENV
  (( $+functions[deactivate] )) && unset -f deactivate
  _SMART_VENV_ROOT=""
  return 0
}

# ----------------------------- main hook ------------------------------------

_python_venv_smart() {
  # If direnv is active and manages this directory, let it own the env so we
  # don't fight over $VIRTUAL_ENV / PATH.
  if [[ -n "$DIRENV_DIR" ]] && typeset -f _direnv_hook >/dev/null 2>&1; then
    return 0
  fi

  __venv_drop_if_gone

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

# Watch for a venv that goes away under a shell that does not move. The
# test is one file check, so it is cheap enough for every prompt.
_python_venv_guard() {
  __venv_drop_if_gone && _python_venv_smart
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _python_venv_smart
add-zsh-hook precmd _python_venv_guard
_python_venv_smart  # run once now

# vim: set ft=zsh ts=2 sw=2:

