# ~/.config/zsh/zshrc.d/09-fpath.zsh
# SPDX-License-Identifier: MIT

# Add custom completion directory
_custom_completion_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/completions"
if [[ ! -d "$_custom_completion_dir" ]]; then
  mkdir -p "$_custom_completion_dir"
fi
fpath=("$_custom_completion_dir" $fpath)

# vim: set ft=zsh ts=2 sw=2:
