# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

if [[ -f ${HOME}/.secrets ]]; then
    emulate zsh -o all_export -c 'source "${HOME}/.secrets"'
fi

# load variables from environment.d
for _rc in "${XDG_CONFIG_HOME:-$HOME/.config}"/environment.d/*.conf; do
  # Ignore tilde files.
  if [[ "${_rc}:t" != '~' ]]; then
    emulate zsh -o all_export -c 'source "${_rc}"'
  fi
done
unset _rc
# Ensure path arrays do not contain duplicates.
typeset -gU path fpath

# Exit early if not interactive
[[ -o interactive ]] || return
if [ -f "${XDG_BIN_HOME:-$HOME/.local/bin}/tildranfetch.sh" ]; then
  source "${XDG_BIN_HOME:-$HOME/.local/bin}/tildranfetch.sh"
fi


# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Modular config (sorted)
for rcfile in "${ZDOTDIR}"/zshrc.d/*.zsh; do
  [[ -r "$rcfile" ]] && source "$rcfile"
done

# Completion system (lazy fallback if not set by plugin)
(( ${+functions[compinit]} )) || autoload -Uz compinit
compinit -d "${ZSH_COMPDUMP:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump}"

# Load Powerlevel10k theme if available
[[ ! -f "${ZDOTDIR}/.p10k.zsh" ]] || source "${ZDOTDIR}/.p10k.zsh"

