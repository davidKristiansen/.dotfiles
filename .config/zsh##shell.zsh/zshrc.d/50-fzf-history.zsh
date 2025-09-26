# ~/.config/zsh/zshrc.d/50-fzf-history.zsh
# SPDX-License-Identifier: MIT

_fzf_history_pick() {
  local cmd
  cmd=$(
    fc -rl 1 | sed 's/^[[:space:]]*[0-9]\+[[:space:]]*//' \
      | fzf --prompt='history> ' --query="$LBUFFER" --height=60% --layout=reverse --border --info=inline
  )

  if [[ -n "$cmd" ]]; then
    LBUFFER=$cmd
    zle redisplay
  else
    # nothing selected → refresh UI before leaving so prompt stays intact
    zle redisplay
  fi
}
zle -N _fzf_history_pick

_fzf_rebind_ctrl_r() {
  bindkey -M viins -r '^R'   >/dev/null 2>&1
  bindkey -M vicmd -r '^R'   >/dev/null 2>&1
  bindkey -M emacs -r '^R'   >/dev/null 2>&1

  bindkey -M viins '^R' _fzf_history_pick
  bindkey -M vicmd '^R' _fzf_history_pick
  bindkey -M emacs '^R' _fzf_history_pick
}

_fzf_rebind_ctrl_r
zle -N zle-keymap-select _fzf_keymap_select
_fzf_keymap_select() { _fzf_rebind_ctrl_r }
zle -N zle-line-init _fzf_line_init
_fzf_line_init() { _fzf_rebind_ctrl_r }

if typeset -f zvm_after_init >/dev/null 2>&1; then
  zvm_after_init() { _fzf_rebind_ctrl_r }
fi

true

