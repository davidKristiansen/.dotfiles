# ~/.config/zsh/zshrc.d/01-motd.zsh
# SPDX-License-Identifier: MIT
# Runs before p10k instant prompt (02-p10k-instant.zsh) to avoid console output warnings.

motd="${XDG_BIN_HOME:-$HOME/.local/bin}/motd.sh"

if [[ -o interactive && -x "$motd" ]]; then
  "$motd"
fi

return 0
# vim: set ft=zsh ts=2 sw=2:

