# ~/.config/zsh/zshrc.d/10-completion.zsh
# SPDX-License-Identifier: MIT

autoload -Uz compinit bashcompinit

# Cache completion data; avoid races in shared homes (e.g., containers)
if [[ ! -e "$ZSH_COMPDUMP" || "$ZSH_COMPDUMP".zwc -ot "$ZSH_COMPDUMP" ]]; then
  compinit -d "$ZSH_COMPDUMP"
else
  compinit -C -d "$ZSH_COMPDUMP"
fi

# Enable bash completion compat if needed
# bashcompinit

# Completion styles
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'
zstyle ':completion:*' menu select=2
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'
zstyle ':fzf-tab:*' switch-group ',' '.'
setopt AUTO_MENU COMPLETE_IN_WORD NO_CASE_GLOB
