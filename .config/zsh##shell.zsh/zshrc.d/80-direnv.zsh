# ~/.config/zsh/zshrc.d/80-direnv.zsh
# SPDX-License-Identifier: MIT
# Cache direnv hook output to avoid eval on every shell startup.

if command -v direnv >/dev/null 2>&1; then
  _direnv_cache="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}/direnv-hook.zsh"
  if [[ ! -r "$_direnv_cache" ]]; then
    direnv hook zsh > "$_direnv_cache"
  fi
  source "$_direnv_cache"
  unset _direnv_cache
fi

return 0
# vim: set ft=zsh ts=2 sw=2:
