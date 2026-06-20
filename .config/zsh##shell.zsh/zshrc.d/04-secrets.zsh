# ~/.config/zsh/zshrc.d/04-secrets.zsh
# SPDX-License-Identifier: MIT

# Source all *.env files from ~/.secrets/ with exported vars.
# Wrapped in an anonymous function so `emulate -L -o all_export` is scoped and
# auto-restored on return — at sourced-file top level `-L` has no function scope
# to restore from, so all_export would leak into the rest of .zshrc and silently
# export every subsequent top-level assignment.
if [[ -d "${HOME}/.secrets" ]]; then
  () {
    emulate -L zsh -o all_export
    local _secret
    for _secret in "${HOME}"/.secrets/*.env(N); do
      source "$_secret"
    done
  }
fi

return 0
# vim: set ft=zsh ts=2 sw=2:

