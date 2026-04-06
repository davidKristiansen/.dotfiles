# ~/.config/zsh/zshrc.d/01-secrets.zsh
# SPDX-License-Identifier: MIT

# Source all *.env files from ~/.secrets/ with exported vars
if [[ -d "${HOME}/.secrets" ]]; then
  emulate -L zsh -o all_export
  for _secret in "${HOME}"/.secrets/*.env(N); do
    source "$_secret"
  done
  unset _secret
fi

return 0
# vim: set ft=zsh ts=2 sw=2:

