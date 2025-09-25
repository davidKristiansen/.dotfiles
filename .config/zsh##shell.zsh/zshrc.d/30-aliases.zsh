# ~/.config/zsh/zshrc.d/30-aliases.zsh
# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

# --- editor shorthands -------------------------------------------------------
# Detect VS Code integrated terminal
if [[ -n "$VSCODE_IPC_HOOK_CLI" || "$TERM_PROGRAM" == "vscode" ]]; then
  alias vim="code"
  alias :e="code"
  alias e="code"
else
  if [[ -n "$EDITOR" ]]; then
    alias vim="$EDITOR"
    alias :e="$EDITOR"
    alias e="$EDITOR"
  fi
fi
alias :q='exit'
alias :Q=':q'

# --- safer rm to trash if available -----------------------------------------
if command -v trash >/dev/null 2>&1; then
  alias rm='trash'
fi

# --- bat-enhanced coreutils (guarded) ---------------------------------------
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --theme gruvbox-dark --color auto --decorations auto'

  if command -v batgrep >/dev/null 2>&1; then
    # kill any existing grep alias first, then alias to batgrep
    unalias grep 2>/dev/null || true
    alias grep='batgrep --terminal-width="${COLUMNS:-80}"'
  else
    alias grep='grep --color=auto'
  fi

  command -v batman   >/dev/null 2>&1 && alias man='batman'
  command -v batpipe  >/dev/null 2>&1 && alias less='batpipe'
  command -v batwatch >/dev/null 2>&1 && alias watch='batwatch'
else
  alias grep='grep --color=auto'
fi

# --- ls / eza ----------------------------------------------------------------
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --color=auto --icons=auto'
  alias ll='ls --total-size --long --changed --sort modified --reverse --all --header --group-directories-first'
  alias tree='ls --tree'
else
  alias ls='ls --color=auto'
  alias ll='ls -lahb'
fi
alias la='ls -a'
alias l='ls'

# --- clipboard (WSL compatibility) ------------------------------------------
command -v clip.exe >/dev/null 2>&1 && alias clip='clip.exe'

# --- sudo with env -----------------------------------------------------------
alias sudo='sudo -E'

# --- ssh wrapper: cleanup terminal after exit -------------------------------
ssh() {
  command \ssh "$@"
  # Try to restore terminal; prefer "reset" if "rest" isn't supported
  if setterm -default -clear rest 2>/dev/null; then
    :
  else
    setterm -default -clear reset 2>/dev/null || true
  fi
}

# --- wget, tmux, svn with XDG paths -----------------------------------------
alias wget='wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'
alias tmux='tmux -u -f "$XDG_CONFIG_HOME/tmux/tmux.conf"'
alias svn='svn --config-dir "$XDG_CONFIG_HOME/subversion"'

# --- dotfiles helper ---------------------------------------------------------
alias dotfiles='/usr/bin/git -C "$DOT_DIR"'

# --- devcontainer helpers ----------------------------------------------------
alias dcu='devcontainer up'
alias dce='devcontainer exec --remote-env TERM="$TERM"'

# --- lazy helpers for git/docker --------------------------------------------
git() {
  if [[ -z "$1" ]] && command -v lazygit >/dev/null 2>&1; then
    command \lazygit
  else
    command \git "$@"
  fi
}

docker() {
  if [[ -z "$1" ]] && command -v lazydocker >/dev/null 2>&1; then
    command \lazydocker
  else
    command \docker "$@"
  fi
}

return 0
# vim: set ft=zsh ts=2 sw=2:

