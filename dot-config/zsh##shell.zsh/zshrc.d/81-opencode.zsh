# ~/.config/zsh/zshrc.d/81-opencode.zsh
# SPDX-License-Identifier: MIT
# Completion for opencode (yargs-generated, trimmed to a plain compdef).
# compdef is available here because ez-compinit ran during plugin load (49).

if (( $+commands[opencode] )); then
  _opencode_yargs_completions() {
    local IFS=$'\n'
    local -a reply
    reply=($(COMP_CWORD="$((CURRENT - 1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" \
      opencode --get-yargs-completions "${words[@]}"))
    if (( ${#reply} )); then
      _describe 'values' reply
    else
      _default
    fi
  }
  compdef _opencode_yargs_completions opencode
fi

return 0
# vim: set ft=zsh ts=2 sw=2:
