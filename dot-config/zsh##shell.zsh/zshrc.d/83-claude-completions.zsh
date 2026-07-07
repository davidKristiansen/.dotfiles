# ~/.config/zsh/zshrc.d/83-claude-completions.zsh
# SPDX-License-Identifier: MIT
# Claude Code CLI ships no completion generator (commander.js, no `completion`
# subcommand). _gnu_generic is zsh's built-in fallback: it parses a command's
# `--help` output for GNU-style long options. Best-effort, but covers flags;
# doesn't know subcommand-specific arguments.

if (( $+commands[claude] )); then
  autoload -Uz _gnu_generic
  compdef _gnu_generic claude
fi

# vim: set ft=zsh ts=2 sw=2:
