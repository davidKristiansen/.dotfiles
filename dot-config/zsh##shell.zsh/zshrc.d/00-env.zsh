# ~/.config/zsh/zshrc.d/00-env.zsh
# SPDX-License-Identifier: MIT

# Core environment + zsh housekeeping (XDG dirs already set in .zshenv)
export EDITOR="nvim"
export VISUAL="$EDITOR"
export PAGER="less"
export LESSCHARSET="utf-8"
# Set only LANG and let the LC_* categories inherit from it. LC_ALL is the
# nuclear override (forces every category) and is best reserved for ad-hoc use.
export LANG="en_US.UTF-8"
unset LC_ALL 2>/dev/null

# Zsh cache + history
export ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}"
export ZSH_COMPDUMP="${ZSH_COMPDUMP:-$ZSH_CACHE_DIR/.zcompdump-$(hostname -s 2>/dev/null || echo host)}"
export HISTFILE="${HISTFILE:-${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history}"
export HISTSIZE=100000
export SAVEHIST=100000

# Ensure dirs exist
mkdir -p -- "$ZSH_CACHE_DIR" "${HISTFILE%/*}"

# Saner umask for dev boxes
umask 022

# vim: set ft=zsh ts=2 sw=2:

