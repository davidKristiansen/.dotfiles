# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

# History file
if [ ! -f "${HISTFILE}" ]; then
  mkdir -p "$(dirname "${HISTFILE}")"
  touch "${HISTFILE}"
fi

HISTSIZE=290000
SAVEHIST=$HISTSIZE

# Remove older command from the history if a duplicate is to be added
setopt HIST_IGNORE_ALL_DUPS

# Prompt for spelling correction of commands
setopt CORRECT

# Customize spelling correction prompt
SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '
