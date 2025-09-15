# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

export FZF_DEFAULT_COMMAND='rg --files --follow --no-ignore-vcs --hidden -g "!{node_modules/*,.git/*,.venv/*}"'

export FZF_DEFAULT_OPTS="--layout=reverse \
  --inline-info \
  --height 40% \
  --tmux bottom,40%
  --bind 'tab:down' \
  --bind 'shift-tab:up'"

export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'eza --tree --color=always {}'"

# Ensure FZF completion trigger is backtick
export FZF_COMPLETION_TRIGGER='`'
export FZF_COMPLETION_OPTS='--border --info=inline'
export FZF_COMPLETION_PATH_OPTS='--walker file,dir,follow,hidden'
export FZF_COMPLETION_DIR_OPTS='--walker dir,follow'

# Source FZF completion after zvm is initialized
zvm_after_init_commands+=('source <(fzf --zsh)')

# Customize completion previews
_fzf_comprun() {
  local command=$1; shift
  case "$command" in
    cd)           fzf --preview 'eza -tree --icons=auto --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
    ssh)          fzf --preview 'dig {}' "$@" ;;
    *)            fzf --preview 'bat -n --color=always --theme=gruvbox-dark {}' "$@" ;;
  esac
}

_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" --exclude ".venv" . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" --exclude "venv" . "$1"
}


_FZF_CMD_D='fzf \
  --height 80% \
  --info inline \
  --border \
  --layout reverse \
  --color=dark'

_FZF_CMD_F='fzf \
  --height 80% \
  --info inline \
  --border \
  --layout reverse \
  --color=dark \
  --preview "bat --style=numbers --color=always {} | head -500"'

_FIND_FILES='fd --hidden --exclude ".git/"'

