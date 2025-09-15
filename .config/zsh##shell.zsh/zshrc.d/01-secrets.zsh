# ~/.config/zsh/zshrc.d/01-secrets.zsh
# SPDX-License-Identifier: MIT

# Load private env with exported vars (same semantics as your old emulate trick)
if [[ -r "${HOME}/.secrets" ]]; then
  emulate -L zsh -o all_export
  source "${HOME}/.secrets"
fi

return 0
# vim: set ft=zsh ts=2 sw=2:

