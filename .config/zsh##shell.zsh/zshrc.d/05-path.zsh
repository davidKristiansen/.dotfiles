# ~/.config/zsh/zshrc.d/05-path.zsh
# SPDX-License-Identifier: MIT

# Split existing PATH into zsh's $path array and make entries unique
typeset -U path
path=(${=PATH})

# Helpers
_prepend_path() { local d="$1"; [[ -d $d ]] || return; path=("$d" ${path:#$d}); }
_append_path()  { local d="$1"; [[ -d $d ]] || return; path=(${path:#$d} "$d"); }

# Your bins (prepend so they win over shims/system where intended)
_prepend_path "${XDG_BIN_HOME:-$HOME/.local/bin}"

# Optional dev tool bins (only if you really need them globally):
_prepend_path "${PYENV_ROOT:-${XDG_DATA_HOME:-$HOME/.local/share}/pyenv}/bin"
_prepend_path "${XDG_DATA_HOME:-$HOME/.local/share}/npm/bin"
_prepend_path "${XDG_DATA_HOME:-$HOME/.local/share}/flutter/bin"
_prepend_path "${CARGO_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/cargo}/bin"

# Export back
export PATH="${(j.:.)path}"
export GOBIN="${XDG_BIN_HOME:-$HOME/.local/bin}"

# --- resolve dotfiles dir ----------------------------------------------------
typeset -gx DOT_DIR
if [[ -d "$HOME/dotfiles" ]]; then
  DOT_DIR="$HOME/dotfiles"
else
  DOT_DIR="$HOME/.dotfiles"
fi

# vim: set ft=zsh ts=2 sw=2:
