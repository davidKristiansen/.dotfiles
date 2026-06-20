# ~/.config/zsh/zshrc.d/82-uv-completions.zsh
# SPDX-License-Identifier: MIT
#
# Cache uv-generated completions for project CLIs. Source whatever is already
# cached now (cheap); regenerate missing/cached files in the BACKGROUND so a
# cold cache never blocks shell startup on `uv run`. Newly generated completions
# become available on the next shell. Delete the cache files to force a refresh.

() {
  local comp_dir="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}"
  local tool cache
  for tool in macpyver gaffa; do
    cache="$comp_dir/${tool}-completion.zsh"
    [[ -r "$cache" ]] && source "$cache"
    if [[ ! -r "$cache" && -n "$WORKSPACE" ]] && command -v uv >/dev/null 2>&1; then
      # Write atomically via a temp file so a half-written cache is never sourced.
      ( uv run --project="$WORKSPACE" "$tool" generate-completion zsh \
          >| "$cache.tmp.$$" 2>/dev/null \
          && mv -f "$cache.tmp.$$" "$cache" \
          || rm -f "$cache.tmp.$$" ) &>/dev/null &!
    fi
  done
}

return 0
# vim: set ft=zsh ts=2 sw=2:
