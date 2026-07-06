# ~/.config/zsh/zshrc.d/70-fzf.zsh
# SPDX-License-Identifier: MIT
# fzf shell integration: Ctrl-R (history), Ctrl-T (file), Alt-C (cd).

command -v fzf >/dev/null 2>&1 || return 0

# Default options
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} --height=40% --layout=reverse --border"

# Use ripgrep for file listing if available
if command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Alt-C: use fd for directory search if available
if command -v fd >/dev/null 2>&1; then
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# Preview for Ctrl-T (file) and Alt-C (dir)
if command -v bat >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :200 {} 2>/dev/null || head -200 {}'"
fi
if command -v eza >/dev/null 2>&1; then
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons=auto {}'"
else
  export FZF_ALT_C_OPTS="--preview 'ls -lah --color=always {}'"
fi

# Load fzf keybindings + completion (cached — see 03-cached-eval.zsh).
# NOTE: the old `eval "$(fzf --zsh 2>/dev/null)" || fallback` never fell back:
# eval of an empty string exits 0. _cached_eval propagates the real status.
if ! _cached_eval fzf fzf --zsh; then
  # Fallback for older fzf versions without --zsh flag
  () {
    local fzf_base
    for fzf_base in /usr/share/fzf /usr/local/opt/fzf/shell /usr/share/doc/fzf/examples; do
      if [[ -d "$fzf_base" ]]; then
        [[ -r "$fzf_base/key-bindings.zsh" ]] && source "$fzf_base/key-bindings.zsh"
        [[ -r "$fzf_base/completion.zsh" ]]   && source "$fzf_base/completion.zsh"
        break
      fi
    done
  }
fi

# Bindings (applied by _user_rebind_all in 80-keybindings.zsh):
# ^R/^T/Alt-C widgets, and fzf-tab re-enabled after `fzf --zsh` steals ^I.
_fzf_bind_all() {
  local m
  for m in emacs vicmd viins; do
    bindkey -M $m '^R'  fzf-history-widget 2>/dev/null
    bindkey -M $m '^T'  fzf-file-widget    2>/dev/null
    bindkey -M $m '\ec' fzf-cd-widget      2>/dev/null
  done
}

return 0
# vim: set ft=zsh ts=2 sw=2:
