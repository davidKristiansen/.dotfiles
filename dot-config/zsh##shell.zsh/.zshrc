# SPDX-License-Identifier: MIT

# Modular config (sorted). (N) = null_glob for this glob only, so we don't
# toggle a global option that other code might rely on.
for rcfile in "$ZDOTDIR"/zshrc.d/*.zsh(N); do
  if [[ -r $rcfile ]]; then
    source "$rcfile" || print -u2 "failed to load $rcfile"
  fi
done
unset rcfile

# vim: set ft=sh ts=2 sw=2:

