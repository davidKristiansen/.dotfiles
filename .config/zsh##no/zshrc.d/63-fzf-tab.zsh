# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

# Disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false

# Set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'

# Enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Prevent menu so fzf-tab can capture prefix
zstyle ':completion:*' menu no

# Preview directory contents when completing `cd`
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -tree --icons=auto --color=always $realpath'

# Use fzf-tab popup interface
zstyle ':fzf-tab:*' popup-min-size 80 8
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# Set fzf-tab config and keybindings
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' continuous-trigger '/'
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2

# Ensure fzf-tab uses FZF_DEFAULT_OPTS (may cause issues in some configs)
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# Explicitly set fzf-tab to be used by autocomplete
zstyle ':autocomplete:tab:*' completion fzf
