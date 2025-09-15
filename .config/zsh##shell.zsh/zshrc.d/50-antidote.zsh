# SPDX-License-Identifier: MIT

# Toggle verbose logs by exporting ZSHRC_DEBUG=1 before sourcing .zshrc
_debug() { [[ -n "$ZSHRC_DEBUG" ]] && print -r -- "[antidote] $*"; }

# Locations (XDG-tidy)
export ANTIDOTE_CLONE="${XDG_DATA_HOME:-$HOME/.local/share}/antidote/clone"
export ANTIDOTE_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/antidote/data"
_antidote_bin="${ANTIDOTE_CLONE}/antidote/antidote.zsh"

# Bootstrap if missing
if [[ ! -r "$_antidote_bin" ]]; then
  _debug "cloning antidote → $ANTIDOTE_CLONE/antidote"
  mkdir -p -- "$ANTIDOTE_CLONE"
  git clone --depth=1 https://github.com/mattmc3/antidote.git \
    "$ANTIDOTE_CLONE/antidote" >/dev/null 2>&1 || return 0
fi

# Load Antidote
[[ -r "$_antidote_bin" ]] || { _debug "antidote.zsh not found"; return 0; }
source "$_antidote_bin" || return 0

# Manifest locations
_plugins_txt="${ZDOTDIR:-$HOME/.config/zsh}/zsh_plugins.txt"
_plugins_zsh="${ZDOTDIR:-$HOME/.config/zsh}/zsh_plugins.zsh"

# Generate bundle if missing or stale
if [[ ! -s "$_plugins_zsh" || "$_plugins_txt" -nt "$_plugins_zsh" ]]; then
  _debug "bundling from $_plugins_txt → $_plugins_zsh"
  antidote bundle <"$_plugins_txt" >"$_plugins_zsh" || _debug "bundle failed"
fi

# Source the resolved bundle
if [[ -r "$_plugins_zsh" ]]; then
  _debug "sourcing bundle $_plugins_zsh"
  source "$_plugins_zsh"
else
  _debug "bundle missing: $_plugins_zsh"
fi

return 0
# vim: set ft=zsh ts=2 sw=2:

