# ~/.config/zsh/zshrc.d/85-zoxide.zsh
# SPDX-License-Identifier: MIT

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

return 0
# vim: set ft=zsh ts=2 sw=2:

