# ~/.config/zsh/zshrc.d/03-cached-eval.zsh
# SPDX-License-Identifier: MIT
#
# _cached_eval <name> <command...>
# Source the output of <command...> from a cache file instead of forking on
# every startup. The cache regenerates when the command's binary is newer than
# the cache file, so tool upgrades are picked up automatically. Returns 1 (and
# drops the cache) if the command fails, so callers can fall back.

_cached_eval() {
  emulate -L zsh
  local name=$1 cache bin
  shift
  # Mtime source for invalidation: the binary named by <name> if it resolves
  # (covers wrapper-function generators like _mise_activate_gen), else the
  # first word of the command.
  bin=${commands[$name]:-${commands[$1]:-$1}}
  cache="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}/${name}-init.zsh"
  if [[ ! -s $cache || $bin -nt $cache ]]; then
    "$@" >| "$cache" 2>/dev/null || { command rm -f -- "$cache"; return 1 }
  fi
  source "$cache"
}

# vim: set ft=zsh ts=2 sw=2:
