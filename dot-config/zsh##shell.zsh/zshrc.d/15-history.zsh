# ~/.config/zsh/zshrc.d/15-history.zsh
# SPDX-License-Identifier: MIT

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY     # write each command as it runs, not just at exit,
                             # so concurrent tmux panes don't clobber each other
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt EXTENDED_HISTORY
# SHARE_HISTORY also imports other sessions' history live; left off so each pane
# keeps its own up-arrow order. Enable if you prefer fully shared history.
# setopt SHARE_HISTORY
