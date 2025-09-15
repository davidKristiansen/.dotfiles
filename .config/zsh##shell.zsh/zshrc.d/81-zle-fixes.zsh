# ~/.config/zsh/zshrc.d/81-zle-fixes.zsh
# SPDX-License-Identifier: MIT

# Use native bracketed-paste; don't let zsh-vi-mode own it
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# Bind in both vi maps
bindkey -M viins -r '^[[200~' 2>/dev/null || true
bindkey -M vicmd -r '^[[200~' 2>/dev/null || true
bindkey -M viins '^[[200~' bracketed-paste
bindkey -M vicmd '^[[200~' bracketed-paste

# If autosuggestions is present, rewrap widgets
(( $+functions[_zsh_autosuggest_start] )) && _zsh_autosuggest_start

return 0
# vim: set ft=zsh ts=2 sw=2:

