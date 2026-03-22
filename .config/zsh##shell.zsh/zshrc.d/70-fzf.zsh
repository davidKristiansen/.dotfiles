# ~/.config/zsh/zshrc.d/70-fzf.zsh
# SPDX-License-Identifier: MIT
# Minimal fzf config — only env vars needed by fzf-tab.
# Shell keybindings (Ctrl-R, Ctrl-T, etc.) are handled by television.

if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} --height=40% --layout=reverse --border"
  if command -v rg >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
  fi
fi

return 0
# vim: set ft=zsh ts=2 sw=2:

