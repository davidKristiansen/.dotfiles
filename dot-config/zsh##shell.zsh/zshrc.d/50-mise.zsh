# ~/.config/zsh/zshrc.d/50-mise.zsh
# SPDX-License-Identifier: MIT

# Activate mise (full activation so chpwd/precmd hooks keep tool paths
# on PATH even after venv activate/deactivate cycles)
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
elif [[ -x "$HOME/.local/bin/mise" ]]; then
  eval "$($HOME/.local/bin/mise activate zsh)"
fi

# vim: set ft=zsh ts=2 sw=2:
