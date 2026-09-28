# ~/.config/zsh/zshrc.d/84-workmux-completions.zsh
# SPDX-License-Identifier: MIT
# Cached workmux completions (see 03-cached-eval.zsh). The script calls
# compdef, which ez-compinit queues until compinit runs.

if (( $+commands[workmux] )); then
  _cached_eval workmux workmux completions zsh
fi

return 0
# vim: set ft=zsh ts=2 sw=2:
