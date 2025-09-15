# ~/.config/zsh/zshrc.d/50-mise.zsh
# SPDX-License-Identifier: MIT

# Fast path: activate mise for zsh (manages PATH, tools, env per dir)
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Optional: also expose shims for non-interactive shells/cron (lighter, fewer features)
# if command -v mise >/dev/null 2>&1; then
#   eval "$(mise activate zsh --shims)"
#   # Or add shims dir explicitly (usually under XDG data):
#   # path=("${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims" ${path:#${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims})
#   # export PATH="${(j.:.)path}"
# fi

# vim: set ft=zsh ts=2 sw=2:

