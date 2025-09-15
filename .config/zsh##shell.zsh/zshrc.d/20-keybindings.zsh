# ~/.config/zsh/zshrc.d/20-keybinds-vi.zsh
# SPDX-License-Identifier: MIT

# --- Vim mode ---------------------------------------------------------------
bindkey -v                             # enable vi keymaps (viins/vicmd)
export KEYTIMEOUT=1                    # faster key chord timeout (0.1s)

# Make "_" and "-" word separators (more natural w/ code & kebab_case)
WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>'

# --- Basic bindings (both modes) -------------------------------------------
# history substring search on ^P/^N (like fzf-ish up/down)
autoload -Uz history-beginning-search-backward history-beginning-search-forward
bindkey -M viins '^P' history-beginning-search-backward
bindkey -M viins '^N' history-beginning-search-forward
bindkey -M vicmd '^P' history-beginning-search-backward
bindkey -M vicmd '^N' history-beginning-search-forward

# jk → ESC in insert mode (go to normal/vicmd fast)
bindkey -M viins 'jk' vi-cmd-mode
bindkey -M viins 'jj' vi-cmd-mode

# Home/End keys (some terminals)
bindkey -M viins '\e[H' beginning-of-line
bindkey -M viins '\e[F' end-of-line
bindkey -M vicmd '\e[H' beginning-of-line
bindkey -M vicmd '\e[F' end-of-line

# Ctrl-L: clear screen but keep scrollback
zle -N _zsh_clear_screen
_zsh_clear_screen() { print -n '\e[H\e[2J'; zle reset-prompt; }
bindkey -M viins '^L' _zsh_clear_screen
bindkey -M vicmd '^L' _zsh_clear_screen

# --- Clipboard & edit -------------------------------------------------------
# Ctrl-Y: yank to system clipboard (requires xclip/wl-copy)
if command -v wl-copy >/dev/null 2>&1; then
  zle -N yank-clip
  yank-clip() { print -rn -- "$CUTBUFFER" | wl-copy; }
  bindkey -M vicmd 'yY' yank-clip
elif command -v xclip >/dev/null 2>&1; then
  zle -N yank-clip
  yank-clip() { print -rn -- "$CUTBUFFER" | xclip -selection clipboard; }
  bindkey -M vicmd 'yY' yank-clip
fi

# v → open current command in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# --- Paste that behaves -----------------------------------------------------
# bracketed-paste-magic if available
autoload -Uz bracketed-paste-magic; zle -N bracketed-paste bracketed-paste-magic
autoload -Uz url-quote-magic; zle -N self-insert url-quote-magic

# --- Cursor shape feedback (xterm/kitty/alacritty compatible) --------------
# 0/1/2 blink styles vary; 1=block, 5=bar
zle-line-init()  { print -n '\e[5 q' }  # insert: bar
zle-line-finish(){ print -n '\e[1 q' }  # command: block
zle -N zle-line-init
zle -N zle-line-finish

# --- Quality of life --------------------------------------------------------
# sensible completion behavior with vi mode
setopt AUTO_MENU COMPLETE_IN_WORD
autoload -Uz compinit
[[ -n "$ZSH_COMPDUMP" ]] && compinit -d "$ZSH_COMPDUMP" || compinit

# vim: set ft=zsh ts=2 sw=2:

