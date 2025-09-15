# SPDX-License-Identifier: MIT
# Completion system setup (static and dynamic)

# Site functions (user completions)
local site_path="${XDG_DATA_HOME:-$HOME/.local/share}/site-functions"
if [[ -d "$site_path" && ! "${fpath[(r)$site_path]}" ]]; then
  fpath=("$site_path" $fpath)
fi

# Dynamic shell completions
if command -v uv &>/dev/null; then
  eval "$(uv generate-shell-completion zsh)"
fi

if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh --cmd cd)"
fi

if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

if command -v thefuck &>/dev/null; then
  eval "$(thefuck --alias)"
fi

# Rustup completions: add to fpath if needed
if command -v rustup &>/dev/null; then
  local rustup_path
  rustup_path="${XDG_DATA_HOME:-$HOME/.local/share}/rustup/completions"
  if [[ -d "$rustup_path" && ! "${fpath[(r)$rustup_path]}" ]]; then
    fpath+=("$rustup_path")
  fi
fi


# Finalize compinit after all fpath mods
(( ${+functions[compinit]} )) || autoload -Uz compinit
compinit -d "${ZSH_COMPDUMP:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump}"
