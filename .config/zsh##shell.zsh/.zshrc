# SPDX-License-Identifier: MIT

# Modular config (sorted)
setopt null_glob
for rcfile in "$ZDOTDIR"/zshrc.d/*.zsh; do
  if [[ -r $rcfile ]]; then
    source "$rcfile" || print -u2 "failed to load $rcfile"
  fi
done
unsetopt null_glob



source <(uv run --project="${WORKSPACE}" macpyver --generate-completion zsh 2>/dev/null) || true

# vim: set ft=sh ts=2 sw=2:

