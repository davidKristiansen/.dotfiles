# ~/.config/zsh/zshrc.d/90-prompt.zsh
# SPDX-License-Identifier: MIT

P10K_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/p10k"

if [[ -r "$P10K_DIR/powerlevel10k.zsh-theme" ]]; then
  source "$P10K_DIR/powerlevel10k.zsh-theme"
  # Optional: load personal config if you have one
  [[ -r "$ZDOTDIR/p10k.zsh" ]] && source "$ZDOTDIR/p10k.zsh"
else
  autoload -Uz colors vcs_info
  colors
  setopt PROMPT_SUBST
  zstyle ':vcs_info:git*' formats '%F{cyan}(%b)%f'
  precmd() { vcs_info }
  PROMPT='%F{green}%n@%m%f %F{yellow}%~%f ${vcs_info_msg_0_}
$ '
fi

# vim: set ft=zsh ts=2 sw=2:

