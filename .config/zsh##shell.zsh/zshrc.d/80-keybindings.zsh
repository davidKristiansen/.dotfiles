# ~/.config/zsh/zshrc.d/80-keymap-vi.zsh
# SPDX-License-Identifier: MIT

export KEYTIMEOUT=1

# Enable vi mode if plugin not loaded
if ! typeset -f zvm_after_init >/dev/null; then
  bindkey -v
fi

# Widget: edit command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line

# jk / jj escape bindings (insert → command mode)
bindkey -M viins 'jk' vi-cmd-mode
bindkey -M viins 'jj' vi-cmd-mode

# v in command mode → open line in $EDITOR
bindkey -M vicmd 'v' edit-command-line

# Ctrl-E in insert mode → open line in $EDITOR
bindkey -M viins '^E' edit-command-line

# Copilot
bindkey -M viins '^[s' zsh_gh_copilot_suggest
bindkey -M viins '^[e' zsh_gh_copilot_explain
bindkey -M vicmd 'gs'  zsh_gh_copilot_suggest   # like Vim :gs
bindkey -M vicmd 'ge'  zsh_gh_copilot_explain   # like Vim :ge

return 0
# vim: set ft=zsh ts=2 sw=2:

