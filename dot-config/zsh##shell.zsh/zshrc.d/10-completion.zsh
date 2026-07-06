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
# fzf-tab replaces the completion menu; the builtin menu must stay off or
# fzf-tab silently falls back to it for some completers.
zstyle ':completion:*' menu no
setopt AUTO_MENU COMPLETE_IN_WORD NO_CASE_GLOB

# SSH hosts: extract Host aliases from ~/.ssh/config (excluding wildcards).
# Feeds both the completion system and fast-syntax-highlighting's ssh chroma.
# Anonymous function so `local` actually scopes (at sourced-file top level it
# behaves like typeset -g and leaks).
if [[ -r "$HOME/.ssh/config" ]]; then
  () {
    local -a hosts
    hosts=(${(s: :)${${(M)${(f)"$(<$HOME/.ssh/config)"}:#Host *}#Host }})
    # Remove wildcard entries (e.g. Host *)
    hosts=(${hosts:#*[*?]*})
    zstyle ':completion:*:hosts' hosts $hosts
  }
fi

# vim: set ft=zsh ts=2 sw=2:
