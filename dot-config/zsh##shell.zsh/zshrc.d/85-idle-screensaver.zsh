# ~/.config/zsh/zshrc.d/85-idle-screensaver.zsh
# SPDX-License-Identifier: MIT
# Idle "screensaver": after TMOUT seconds at a bare prompt (no foreground job),
# run neo's matrix rain. Any keypress dismisses it. zsh fires SIGALRM only while
# the line editor waits for input, so this never interrupts a running command.

command -v neo >/dev/null || return 0

# Skip the scratchpad terminal: it runs tmux session "scratch" (see
# ~/.local/bin/scratchpad.sh). A quake-style drop-down shouldn't paint matrix
# rain over itself while idle.
if [[ -n "$TMUX" && "$(tmux display-message -p '#S' 2>/dev/null)" == scratch ]]; then
  return 0
fi

TMOUT=120

TRAPALRM() {
  neo --colormode=16 -D -a --screensaver
  zle reset-prompt   # redraw prompt + any half-typed line after dismiss
}

# vim: set ft=zsh ts=2 sw=2:
