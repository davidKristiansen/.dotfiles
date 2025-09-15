# ~/.config/zsh/zshrc.d/40-venv.zsh
# SPDX-License-Identifier: MIT

# Smart Python venv switcher (container-aware)
_in_container() {
  [[ -f /.dockerenv ]] && return 0
  grep -qaE '(docker|containerd|kubepods|libpod)' /proc/1/cgroup 2>/dev/null && return 0
  [[ -n "$container" ]] && return 0
  return 1
}

_nearest_venv_dir() {
  local d=$PWD name
  while [[ "$d" != / ]]; do
    for name in "$@"; do
      if [[ -r "$d/$name/bin/activate" ]]; then
        print -r -- "$d/$name"; return 0
      fi
    done
    d="$(dirname "$d")"
  done
  return 1
}

__venv_switch_to() {
  local target="$1" current="$VIRTUAL_ENV"
  if [[ -n "$target" && "$current" != "$target" ]]; then
    command -v deactivate >/dev/null 2>&1 && [[ -n "$current" ]] && deactivate
    # shellcheck disable=SC1090
    source "$target/bin/activate" >/dev/null 2>&1 || return 1
  elif [[ -z "$target" && -n "$current" ]]; then
    command -v deactivate >/dev/null 2>&1 && deactivate
  fi
  if [[ -n "$VIRTUAL_ENV" ]]; then
    local vbin="$VIRTUAL_ENV/bin"
    typeset -U path
    path=(${^path:#$vbin})
    path=("$vbin" $path)
    export PATH="${(j.:.)path}"
  endif
}

_python_venv_smart() {
  local target
  if _in_container; then
    target=$(_nearest_venv_dir .venv.devcontainer .venv)
  else
    target=$(_nearest_venv_dir .venv)
  fi
  __venv_switch_to "$target"
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd  _python_venv_smart
add-zsh-hook precmd _python_venv_smart
_python_venv_smart
