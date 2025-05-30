# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

alias vim=$EDITOR
alias :e=$EDITOR
alias e=$EDITOR
alias :q=exit
alias :Q=:q

if type trash >/dev/null; then
    alias rm=trash
fi
if type bat >/dev/null; then
    alias cat=bat --theme gruvbox-dark --color auto --decoration auto
    alias grep=batgrep --terminal-width=$COLUMNS
    alias man=batman
    alias less=batpipe
    alias watch=batwatch
fi

if command -v eza &>/dev/null; then
    alias ls='eza --color=auto --icons=auto'
    alias ll='ls \
      --total-size \
      --long \
      --changed \
      --sort modified \
      --reverse \
      --all \
      --header \
      --group-directories-first \
    '
    alias tree='ls --tree'
else
    alias ls='ls --color=auto'
    alias ll='ls -lahb'
fi
alias la='ls -a'
alias l=ls
if type clip.exe >/dev/null; then
    alias clip='clip.exe'
fi

alias sudo="sudo -E"
# alias sudo="sudo "

function ssh_alias() {
  ssh "$@";
  setterm -default -clear rest;
  # If `-clear rest` gives error `setterm: argument error: 'rest'`, try `-clear reset` instead
}

alias ssh=ssh_alias
# alias ssh="kitty +kitten ssh"

alias wget='wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'
alias tmux="tmux -u -f '${XDG_CONFIG_HOME}'/tmux/tmux.conf"

alias dotfiles='/usr/bin/git -C "${DOT_DIR}"'
alias svn="svn --config-dir $XDG_CONFIG_HOME/subversion"

# function rm mv () {
#   if git rev-parse --is-inside-work-tree &> /dev/null
#   then
#     git $0 "$@"
#   else
#     command $0 "$@"
#   fi
# }


alias dcu="devcontainer up"
alias dce="devcontainer exec --remote-env TERM=$(echo $TERM)"


function git () {
  if [[ -z "${1}" ]]; then
    command \lazygit
  else
    command \git "${@}"
  fi
}

function docker () {
  if [[ -z "${1}" ]]; then
    command \lazydocker
  else
    command \docker "${@}"
  fi
}

# alias macpyver='$HOME/Work/ISX038/es2_eval/MacPyver_SilEval/macpyver/macpyver.py'
# alias ollama='docker exec -ti ollama ollama'

# vim: set filetype=bash:
