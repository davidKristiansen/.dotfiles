# ~/.config/zsh/zshrc.d/60-git.zsh
# SPDX-License-Identifier: MIT

# GPG_TTY for signed commits in interactive terminals
if [ -t 1 ] 2>/dev/null; then
  export GPG_TTY="$(tty 2>/dev/null || true)"
fi

alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gca='git commit -a'
alias gco='git checkout'
alias gb='git switch -c'
alias gp='git push'
alias gl='git pull --rebase'
alias gd='git diff'
