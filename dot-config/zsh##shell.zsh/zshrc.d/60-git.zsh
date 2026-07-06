# ~/.config/zsh/zshrc.d/60-git.zsh
# SPDX-License-Identifier: MIT

# GPG_TTY for signed commits in interactive terminals.
# $TTY is a zsh builtin parameter — no `tty` fork.
[[ -n "$TTY" ]] && export GPG_TTY="$TTY"

alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gca='git commit -a'
alias gco='git checkout'
alias gb='git switch -c'
alias gp='git push'
alias gl='git pull --rebase'
alias gd='git diff'

# vim: set ft=zsh ts=2 sw=2:
