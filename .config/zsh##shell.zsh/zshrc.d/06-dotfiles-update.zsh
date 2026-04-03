# ~/.config/zsh/zshrc.d/06-dotfiles-update.zsh
# SPDX-License-Identifier: MIT
#
# Silently pull dotfiles and re-bootstrap in the background when there
# are new commits.  Runs after p10k instant prompt (02); all output is
# suppressed to avoid triggering p10k's "console output during init" warning.

(
  local dir="${DOT_DIR:-$HOME/.dotfiles}"
  local before=$(git -C "$dir" rev-parse HEAD)
  git -C "$dir" pull --rebase --quiet || return
  [[ $(git -C "$dir" rev-parse HEAD) != "$before" ]] && "$dir"/bootstrap
) &>/dev/null &!

# vim: set ft=zsh ts=2 sw=2:
