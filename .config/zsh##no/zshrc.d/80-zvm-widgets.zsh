# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

function w_lazygit() {
  \lazygit
}

function w_find_files() {
  zle kill-whole-line
  local file=$(eval $_FIND_FILES | eval $_FZF_CMD_F)
  nvim "$file"
  zle reset-prompt
  zle accept-line
}

function w_quit() {
  exit
}

function w_tmux_session() {
  zle kill-whole-line
  zle -I

  local proj
  proj=$("${XDG_BIN_HOME:-$HOME/.local/bin}"//frecent-projects.sh |
    fzf --preview 'eza -TL 1 --color=always {}') || return

  zle -I

  local raw_name="${proj##*/}"
  local session="${raw_name//[^a-zA-Z0-9_-]/_}"

  if [[ -n "$TMUX" ]]; then
    BUFFER="tmux has-session -t '${session}' 2>/dev/null && tmux switch-client -t '${session}' || (cd ${proj:q} && tmux new-session -ds '${session}' -c ${proj:q} && tmux switch-client -t '${session}')"
  else
    BUFFER="cd ${proj:q} && tmux new-session -A -s '${session}'"
  fi

  zle accept-line
}
zle -N w_tmux_session

function w_open_nvim_here() {
  zle kill-whole-line
  zle -I
  nvim +":lua Snacks.dashboard()"
  zle reset-prompt
  zle accept-line
}
zle -N w_open_nvim_here

function w_zoxide_interactive() {
  zle kill-whole-line
  zle -I

  local dir
  dir=$(zoxide query --interactive) || return
  [[ -z "$dir" ]] && return

  # Create smart post-cd preview command
  local post_cd
  if [[ -d "$dir/.git" ]]; then
    post_cd="git status"
  else
    post_cd="eza -TL 1 --icons=auto"
  fi

  BUFFER="cd ${dir:q} && ${post_cd}"
  zle accept-line
}
zle -N w_zoxide_interactive

function w_cdi() {
  zle kill-whole-line
  local dir=$(zoxide query --list | eval $_FZF_CMD_D)
  cd "${dir}"
  zle reset-prompt
  zle accept-line
}

function w_nvim_files() {
  if [[ -o zle ]]; then
    zle kill-whole-line
  fi
  nvim +":lua Snacks.picker.smart()"
  if [[ -o zle ]]; then
    zle reset-prompt
  fi
}
zle -N w_nvim_files

function w_fzf_open() {
  if [[ -o zle ]]; then
    zle kill-whole-line
  fi
  local file=$(fzf --height 80% --preview 'bat --style=numbers --color=always {} | head -500')
  [[ -z "$file" ]] && return

  if command -v xdg-open &>/dev/null; then
    xdg-open "$file"
  elif command -v open &>/dev/null; then
    open "$file"
  elif command -v wslview &>/dev/null; then
    wslview "$file"
  elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
    cmd.exe /C start "" "$file"
  else
    echo "Don't know how to open files on this system :("
    return 1
  fi

  if [[ -o zle ]]; then
    zle reset-prompt
  fi
}
zle -N w_fzf_open

function w_fuck() {
  BUFFER="fuck"
  zle accept-line
}
zle -N w_fuck

zle -N w_find_files
zle -N w_quit
zle -N w_cdi
zle -N w_lazygit

ZVM_READKEY_ENGINE=$ZVM_READKEY_ENGINE_ZLE
# ZVM_LINE_INIT_MODE=ZVM_MODE_NORMAL

# bindkey '^e' find_f
