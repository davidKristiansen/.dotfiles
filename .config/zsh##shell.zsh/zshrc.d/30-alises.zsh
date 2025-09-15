# ~/.config/zsh/zshrc.d/30-aliases.zsh
# SPDX-License-Identifier: MIT

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias cls='clear'
alias please='sudo'
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }
