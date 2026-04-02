# ~/.config/zsh/zshrc.d/85-zoxide.zsh
# SPDX-License-Identifier: MIT
# Cache zoxide init output to avoid eval on every shell startup.

if command -v zoxide >/dev/null 2>&1; then
  _zoxide_cache="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}/zoxide-init.zsh"
  if [[ ! -r "$_zoxide_cache" ]]; then
    zoxide init zsh --cmd cd > "$_zoxide_cache"
  fi
  source "$_zoxide_cache"
  unset _zoxide_cache
fi

return 0
# vim: set ft=zsh ts=2 sw=2:
