# ~/.config/zsh/zshrc.d/65-fuck.zsh
# SPDX-License-Identifier: MIT
# Lazy-load thefuck: avoid ~200ms eval at startup.
# The real init runs only on first invocation of `fuck`.

if command -v thefuck >/dev/null 2>&1; then
  fuck() {
    unfunction fuck
    eval "$(thefuck --alias)"
    fuck "$@"
  }
fi

return 0
# vim: set ft=zsh ts=2 sw=2:
