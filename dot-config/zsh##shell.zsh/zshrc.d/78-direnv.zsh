# ~/.config/zsh/zshrc.d/78-direnv.zsh
# SPDX-License-Identifier: MIT
# Cache direnv hook output to avoid eval on every shell startup.

if (( $+commands[direnv] )); then
  _cached_eval direnv direnv hook zsh
fi

return 0
# vim: set ft=zsh ts=2 sw=2:
