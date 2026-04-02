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

# Load fzf keybindings + completion
eval "$(fzf --zsh 2>/dev/null)" || {
  # Fallback for older fzf versions without --zsh flag
  local fzf_base
  for fzf_base in /usr/share/fzf /usr/local/opt/fzf/shell /usr/share/doc/fzf/examples; do
    if [[ -d "$fzf_base" ]]; then
      [[ -r "$fzf_base/key-bindings.zsh" ]] && source "$fzf_base/key-bindings.zsh"
      [[ -r "$fzf_base/completion.zsh" ]]    && source "$fzf_base/completion.zsh"
      break
    fi
  done
}

# Rebind for vi-mode compatibility (zsh-vi-mode may steal keymaps)
_fzf_bind_all() {
  for m in emacs vicmd viins; do
    bindkey -M $m '^R' fzf-history-widget    2>/dev/null
    bindkey -M $m '^T' fzf-file-widget       2>/dev/null
    bindkey -M $m '\ec' fzf-cd-widget        2>/dev/null
  done
}
_fzf_bind_all
zvm_after_init_commands+=('_fzf_bind_all')
zvm_after_lazy_keybindings_commands+=('_fzf_bind_all')

return 0
# vim: set ft=zsh ts=2 sw=2:
