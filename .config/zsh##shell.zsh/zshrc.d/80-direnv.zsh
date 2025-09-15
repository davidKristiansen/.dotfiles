# ~/.config/zsh/zshrc.d/80-direnv.zsh
# SPDX-License-Identifier: MIT

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
