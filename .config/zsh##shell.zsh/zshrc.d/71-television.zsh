# ~/.config/zsh/zshrc.d/71-television.zsh
# SPDX-License-Identifier: MIT
# Television (tv) shell integration — replaces fzf shell keybindings.
# Provides: Ctrl-R (history), Ctrl-T (smart autocomplete),
#           Ctrl-F (open file in $EDITOR), Ctrl-P (paste file path),
#           Ctrl-G (live grep), Alt-D (zoxide cd)
#
# NOTE: Ctrl-{H,J,K,L} are reserved for tmux/nvim pane navigation.
# NOTE: Alt-{H,J,K,L,O} are reserved for tmux-tilish pane switching.

command -v tv >/dev/null 2>&1 || return 0

# ── tv init zsh (completions + Ctrl-R/Ctrl-T widgets) ────────────────
eval "$(tv init zsh)"

# ── helpers ──────────────────────────────────────────────────────────
_tv_disable_bracketed_paste() {
  [[ -n $zle_bracketed_paste ]] && print -nr ${zle_bracketed_paste[2]} >${TTY:-/dev/tty}
}
_tv_enable_bracketed_paste() {
  [[ -n $zle_bracketed_paste ]] && print -nr ${zle_bracketed_paste[1]} >${TTY:-/dev/tty}
}

# ── Ctrl-F: find file and open in $EDITOR ───────────────────────────
_tv_files_open() {
  emulate -L zsh
  zle -I
  _tv_disable_bracketed_paste
  local file
  file=$(tv files --no-status-bar </dev/tty)
  zle reset-prompt
  if [[ -n "$file" ]]; then
    ${EDITOR:-nvim} "$file" </dev/tty
  fi
  _tv_enable_bracketed_paste
}
zle -N tv-files-open _tv_files_open

# ── Ctrl-P: find file and paste path into prompt ────────────────────
_tv_files_paste() {
  emulate -L zsh
  zle -I
  _tv_disable_bracketed_paste
  local res
  res=$(tv files --no-status-bar </dev/tty | while read -r line; do echo -n -E "${(q)line} "; done)
  res=${res% }
  zle reset-prompt
  if [[ -n "$res" ]]; then
    LBUFFER+=$res
  fi
  _tv_enable_bracketed_paste
}
zle -N tv-files-paste _tv_files_paste

# ── Ctrl-G: live grep (text search) and paste path into prompt ──────
_tv_grep() {
  emulate -L zsh
  zle -I
  _tv_disable_bracketed_paste
  local res
  res=$(tv text --no-status-bar </dev/tty | while read -r line; do echo -n -E "${(q)line} "; done)
  res=${res% }
  zle reset-prompt
  if [[ -n "$res" ]]; then
    LBUFFER+=$res
  fi
  _tv_enable_bracketed_paste
}
zle -N tv-grep _tv_grep

# ── Alt-D: zoxide directory jump via tv ──────────────────────────────
_tv_zoxide() {
  emulate -L zsh
  zle -I
  _tv_disable_bracketed_paste
  local res
  res=$(tv dirs --no-status-bar </dev/tty)
  zle reset-prompt
  if [[ -n "$res" ]] && command -v __zoxide_cd >/dev/null 2>&1; then
    __zoxide_cd "$res"
  elif [[ -n "$res" ]]; then
    cd "$res"
  fi
  zle accept-line
  _tv_enable_bracketed_paste
}
zle -N tv-zoxide _tv_zoxide

# ── Bind keys across all vi + emacs keymaps ─────────────────────────
_tv_bind_all() {
  for m in emacs vicmd viins; do
    bindkey -M $m '^R' tv-shell-history
    bindkey -M $m '^T' tv-smart-autocomplete
    bindkey -M $m '^F' tv-files-open
    bindkey -M $m '^P' tv-files-paste
    bindkey -M $m '^G' tv-grep
    bindkey -M $m '\ed' tv-zoxide          # Alt-D
  done
}
_tv_bind_all

# Re-bind after zsh-vi-mode steals keymaps on every keymap switch.
# zvm_after_init runs once; zvm_after_lazy_keybindings ensures
# our bindings survive vi-mode keymap resets.
if (( $+functions[zvm_after_init] )) || [[ -n "$ZVM_INIT_DONE" ]]; then
  # Plugin already loaded — just rebind now
  _tv_bind_all
fi
zvm_after_init_commands+=('_tv_bind_all')
zvm_after_lazy_keybindings_commands+=('_tv_bind_all')

return 0
# vim: set ft=zsh ts=2 sw=2:
