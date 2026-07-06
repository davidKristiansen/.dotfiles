# ~/.config/zsh/zshrc.d/80-keybindings.zsh
# SPDX-License-Identifier: MIT
#
# Single home for keybinding application. zsh-vi-mode (zvm) resets all keymaps
# during its deferred init, wiping any bindkey done at plugin source time.
# Feature files (51-zoxide, 65-fuck, 70-fzf) therefore only *define* a bind
# function; _user_rebind_all below applies them in one deterministic order and
# re-applies them whenever zvm resets keymaps.

# --- vi mode -----------------------------------------------------------------
export KEYTIMEOUT=1

if (( $+functions[zvm_init] )); then
  # zvm intercepts insert-mode keys itself, so a raw `bindkey -M viins jk`
  # never fires under it (and KEYTIMEOUT=1 gives multi-char bindings only a
  # 10ms window anyway). Use zvm's own escape binding; it supports one
  # sequence, so `jk` wins over `jj`.
  ZVM_VI_INSERT_ESCAPE_BINDKEY='jk'
else
  bindkey -v
  # Without zvm, jk/jj need a longer keytimeout than 10ms to be typeable.
  # Tradeoff: Esc-prefixed sequences resolve in 200ms instead of 10ms.
  KEYTIMEOUT=20
  bindkey -M viins 'jk' vi-cmd-mode
  bindkey -M viins 'jj' vi-cmd-mode
fi

# --- widgets -------------------------------------------------------------------
autoload -Uz edit-command-line
zle -N edit-command-line

# --- personal bindings ---------------------------------------------------------
_user_bind_keys() {
  bindkey -M vicmd 'v'  edit-command-line   # normal mode: open line in $EDITOR
  bindkey -M viins '^E' edit-command-line   # insert mode: same
  # Accept the autosuggestion ghost text — mirrors <C-F> in nvim (on_attach).
  # The widget is created when the deferred plugin loads; binding by name is
  # safe before that.
  bindkey -M viins '^F' autosuggest-accept
  bindkey -M emacs '^F' autosuggest-accept
}

# --- central rebind ------------------------------------------------------------
# Order matters:
#   1. fzf widgets      ^R / ^T / Alt-C
#   2. enable-fzf-tab   take ^I back (`fzf --zsh` binds it to fzf-completion)
#   3. pay-respects     vicmd Esc, emacs Esc-Esc, ^X^X
#   4. zoxide cd-tab    wraps whatever ^I is bound to — must run after fzf-tab
#   5. personal keys    last, so nothing overrides them
_user_rebind_all() {
  (( $+functions[_fzf_bind_all]        )) && _fzf_bind_all
  (( $+functions[enable-fzf-tab]       )) && enable-fzf-tab 2>/dev/null
  (( $+functions[__pr_bind_keys]       )) && __pr_bind_keys
  (( $+functions[__zoxide_bind_cd_tab] )) && __zoxide_bind_cd_tab
  _user_bind_keys
  return 0
}

# Apply now — but only when zvm is absent: with zvm loaded, its deferred init
# wipes these keymaps at the first prompt anyway, so source-time binding is
# ~5ms of wasted work (the precmd/zvm hooks below do the real binding) …
(( $+functions[zvm_init] )) || _user_rebind_all

# … once more at the first prompt: every plugin is initialized by then, and
# this precmd registers after zvm's deferred-init precmd so it runs after the
# keymap reset …
_user_rebind_once() {
  _user_rebind_all
  add-zsh-hook -d precmd _user_rebind_once
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _user_rebind_once

# … and after any later zvm keymap reset (lazy keybindings).
zvm_after_init_commands+=('_user_rebind_all')
zvm_after_lazy_keybindings_commands+=('_user_rebind_all')

return 0
# vim: set ft=zsh ts=2 sw=2:
