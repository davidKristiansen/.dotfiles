# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

function zvm_after_lazy_keybindings() {
  zvm_define_widget w_nvim_files
  zvm_define_widget w_fzf_open
  zvm_define_widget w_fuck
  zvm_define_widget w_find_files
  zvm_define_widget w_quit
  zvm_define_widget w_cdi
  zvm_define_widget w_lazygit
  zvm_define_widget w_nvim_session
  zvm_define_widget w_open_nvim_here
  zvm_define_widget w_zoxide_interactive

  zvm_bindkey vicmd '^e' w_open_nvim_here
  zvm_bindkey vicmd '^c' w_zoxide_interactive

  zvm_bindkey viins '^f' w_nvim_files
  zvm_bindkey vicmd '^f' w_nvim_files
  zvm_bindkey vicmd '  ' w_nvim_files

  zvm_bindkey vicmd '^s' w_tmux_session
  zvm_bindkey viins '^s' w_tmux_session

  zvm_bindkey viins '^[f' w_fzf_open # Alt-F
  zvm_bindkey vicmd '^[f' w_fzf_open

  zvm_bindkey viins '^[^[' w_fuck # ESC ESC in insert mode
  zvm_bindkey vicmd '^[^[' w_fuck # ESC ESC in normal mode

  zvm_bindkey vicmd ' f' w_find_files
  zvm_bindkey vicmd ':q' w_quit
  zvm_bindkey vicmd ' c' w_cdi
  zvm_bindkey vicmd ' g' w_lazygit
}

# Disable forward-i-search binding (Ctrl-S)
# bindkey -r '^s'

# Optional: turn off terminal flow control so Ctrl-S is usable
# Disable terminal flow control so Ctrl-S is usable
[[ -t 0 ]] && stty -ixon 2>/dev/null
