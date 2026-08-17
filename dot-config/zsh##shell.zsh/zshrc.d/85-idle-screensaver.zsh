# ~/.config/zsh/zshrc.d/85-idle-screensaver.zsh
# SPDX-License-Identifier: MIT
# Idle "screensaver": after TMOUT seconds at a bare prompt (no foreground job),
# run neo's matrix rain. Any keypress dismisses it. zsh fires SIGALRM only while
# the line editor waits for input, so this never interrupts a running command.

command -v neo >/dev/null || return 0

# Multiplexer panes opt out: the rain repaints the whole pane and fights the
# multiplexer's own redraws (and, under herdr, its agent-state tracking).
# if [[ -n "$TMUX" && "$(tmux display-message -p '#S' 2>/dev/null)" == scratch ]]; then
if [[ -n "${TMUX:-}" || -n "${HERDR_PANE_ID:-}" || "${HERDR_ENV:-}" == 1 ]]; then
  return 0
fi

TMOUT=120

TRAPALRM() {
  neo --colormode=16 -D -a --screensaver
  zle reset-prompt   # redraw prompt + any half-typed line after dismiss
}

# vim: set ft=zsh ts=2 sw=2:
