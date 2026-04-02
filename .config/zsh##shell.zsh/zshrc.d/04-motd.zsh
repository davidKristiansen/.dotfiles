# ~/.config/zsh/zshrc.d/02-motd.zsh
# SPDX-License-Identifier: MIT

motd="${XDG_BIN_HOME:-$HOME/.local/bin}/tildranfetch.sh"

# Run exactly once per TTY per shell startup
if [[ -o interactive && -t 1 && -x "$motd" ]]; then
  "$motd"
fi

return 0
# vim: set ft=zsh ts=2 sw=2:

