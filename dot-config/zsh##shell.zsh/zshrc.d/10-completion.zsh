# ~/.config/zsh/zshrc.d/10-completion.zsh
# SPDX-License-Identifier: MIT
# NOTE: compinit is handled by ez-compinit (via antidote).
# This file only sets completion styles and options.

# Completion styles
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'
zstyle ':completion:*' menu select=2
setopt AUTO_MENU COMPLETE_IN_WORD NO_CASE_GLOB

# SSH hosts: extract Host aliases from ~/.ssh/config (excluding wildcards).
# Feeds both the completion system and fast-syntax-highlighting's ssh chroma.
if [[ -r "$HOME/.ssh/config" ]]; then
  local -a _ssh_config_hosts
  _ssh_config_hosts=(${(s: :)${${(M)${(f)"$(<$HOME/.ssh/config)"}:#Host *}#Host }})
  # Remove wildcard entries (e.g. Host *)
  _ssh_config_hosts=(${_ssh_config_hosts:#*[*?]*})
  zstyle ':completion:*:hosts' hosts $_ssh_config_hosts
fi
