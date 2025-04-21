# SPDX-License-Identifier: MIT
# Bootstrap and load Antidote plugin manager

# Export Antidote cache dir
export ANTIDOTE_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/antidote/data"

# Internal: where Antidote is cloned
local antidote_repo="${XDG_DATA_HOME:-$HOME/.local/share}/antidote/clone"

# Plugin bundle paths
local zsh_plugins="${ZDOTDIR:-$HOME}/zsh_plugins"
local plugins_txt="${zsh_plugins}.txt"
local plugins_zsh="${zsh_plugins}.zsh"

# Bootstrap Antidote if needed
if [[ ! -f "${antidote_repo}/antidote.zsh" ]]; then
  echo "Cloning Antidote into: ${antidote_repo}"
  git clone --depth=1 https://github.com/mattmc3/antidote.git "${antidote_repo}"
fi

# Regenerate plugin loader if needed
if [[ ! -f "$plugins_zsh" || "$plugins_zsh" -ot "$plugins_txt" ]]; then
  (
    source "${antidote_repo}/antidote.zsh"
    antidote bundle <"$plugins_txt" >"$plugins_zsh"
  )
fi

# Load plugin bundle
source "$plugins_zsh"
