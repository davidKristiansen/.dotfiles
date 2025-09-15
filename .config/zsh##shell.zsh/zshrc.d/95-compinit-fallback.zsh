# ~/.config/zsh/zshrc.d/95-compinit-fallback.zsh
# SPDX-License-Identifier: MIT

if (( ! ${+functions[compinit]} )); then
  autoload -Uz compinit
  compinit -d "${ZSH_COMPDUMP:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump}"
fi

return 0
# vim: set ft=zsh ts=2 sw=2:

