# SPDX-License-Identifier: MIT

# Modular config (sorted)
setopt null_glob
for rcfile in "$ZDOTDIR"/zshrc.d/*.zsh; do
  if [[ -r $rcfile ]]; then
    source "$rcfile" || print -u2 "failed to load $rcfile"
  fi
done
unsetopt null_glob



# Cache uv-generated completions (regenerate by deleting the cache files)
_uv_comp_dir="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}"
for _uv_tool in macpyver gaffa; do
  _uv_cache="$_uv_comp_dir/${_uv_tool}-completion.zsh"
  if [[ ! -r "$_uv_cache" && -n "$WORKSPACE" ]]; then
    uv run --project="${WORKSPACE}" "$_uv_tool" generate-completion zsh >"$_uv_cache" 2>/dev/null || continue
  fi
  [[ -r "$_uv_cache" ]] && source "$_uv_cache"
done
unset _uv_comp_dir _uv_tool _uv_cache

# vim: set ft=sh ts=2 sw=2:

