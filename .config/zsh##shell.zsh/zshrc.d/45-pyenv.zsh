# ~/.config/zsh/zshrc.d/45-pyenv.zsh
# SPDX-License-Identifier: MIT

if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
  # Uncomment for pyenv-virtualenv if installed
  # eval "$(pyenv virtualenv-init -)"
fi
