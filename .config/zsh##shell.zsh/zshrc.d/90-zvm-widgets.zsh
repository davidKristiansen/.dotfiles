function
_FZF_CMD_D='fzf \
  --height 80% \
  --info inline \
  --border\
  --layout reverse \
  --color=dark'

_FZF_CMD_F='fzf \
  --height 80% \
  --info inline \
  --border\
  --layout reverse \
  --color=dark \
  --preview "bat --style=numbers --color=always {} | head -500"'


_FIND_FILES='fd \
  --hidden \
  --exclude ".git/"'

function w_lazygit () {
  \lazygit
}

function w_find_files () {
  zle kill-whole-line
  local file=$(eval $_FIND_FILES | eval $_FZF_CMD_F)
  nvim $file
  zle reset-prompt
  zle accept-line
}

function w_quit () {
  exit
}

function w_cdi () {
  zle kill-whole-line
  local dir=$(zoxide query --list | eval $_FZF_CMD_D)
  cd "${dir}"
  zle reset-prompt
  zle accept-line
}

function zvm_after_lazy_keybindings () {
  zvm_define_widget w_find_files
  zvm_define_widget w_quit
  zvm_define_widget w_cdi
  zvm_define_widget w_lazygit

  zvm_bindkey vicmd ' f' w_find_files
  zvm_bindkey vicmd ':q' w_quit
  zvm_bindkey vicmd ' c' w_cdi
  zvm_bindkey vicmd ' g' w_lazygit
}

ZVM_READKEY_ENGINE=$ZVM_READKEY_ENGINE_ZLE
# ZVM_LINE_INIT_MODE=ZVM_MODE_NORMAL


# bindkey '^e' find_f
