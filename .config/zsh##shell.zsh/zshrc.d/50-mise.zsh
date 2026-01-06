# ~/.config/zsh/zshrc.d/50-mise.zsh
# SPDX-License-Identifier: MIT

# Ensure local bin is in path (redundancy check)
if [[ -d "$HOME/.local/bin" ]]; then
  # Prepend to path if not present
  path=("$HOME/.local/bin" ${path:#$HOME/.local/bin})
  export PATH
fi

# Activate mise
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh --shims)"
elif [[ -x "$HOME/.local/bin/mise" ]]; then
  # Fallback if not in PATH
  eval "$($HOME/.local/bin/mise activate zsh --shims)"
fi

# vim: set ft=zsh ts=2 sw=2:
