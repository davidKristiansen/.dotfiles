# ~/.config/zsh/zshrc.d/85-zoxide.zsh
# SPDX-License-Identifier: MIT
# Cache zoxide init output to avoid eval on every shell startup.

if command -v zoxide >/dev/null 2>&1; then
  _zoxide_cache="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}/zoxide-init.zsh"
  if [[ ! -r "$_zoxide_cache" ]]; then
    zoxide init zsh --cmd cd > "$_zoxide_cache"
  fi
  source "$_zoxide_cache"
  unset _zoxide_cache

  # Custom widget: bare "cd<tab>" (no trailing space) triggers zoxide interactive.
  # With a space ("cd <tab>"), normal fzf-tab directory completion fires instead.
  if [[ -o zle ]]; then
    function __zoxide_cd_tab_widget() {
      if [[ "$BUFFER" == "cd" ]]; then
        local result
        result="$(\command zoxide query --interactive)" || result=''
        if [[ -n "$result" ]]; then
          BUFFER="cd ${(q-)result}"
          CURSOR=${#BUFFER}
          \builtin zle reset-prompt
          \builtin zle accept-line
        else
          \builtin zle reset-prompt
        fi
      else
        # Delegate to the original completion widget (fzf-tab or default).
        \builtin zle "${__zoxide_orig_tab_widget:-expand-or-complete}"
      fi
    }
    \builtin zle -N __zoxide_cd_tab_widget

    function __zoxide_bind_cd_tab() {
      # Capture whatever tab is currently bound to so we can delegate.
      local current_tab
      current_tab="$(\builtin bindkey '^I' 2>/dev/null | awk '{print $2}')"
      if [[ -n "$current_tab" && "$current_tab" != __zoxide_cd_tab_widget ]]; then
        __zoxide_orig_tab_widget="$current_tab"
      fi
      \builtin bindkey '^I' __zoxide_cd_tab_widget
    }

    # Defer binding until after all plugins (fzf-tab, zsh-vi-mode) are loaded.
    # Use precmd hook to run once on first prompt (all plugins initialized by then).
    function __zoxide_deferred_bind() {
      __zoxide_bind_cd_tab
      add-zsh-hook -d precmd __zoxide_deferred_bind
    }
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd __zoxide_deferred_bind
    # Also re-bind after zsh-vi-mode resets keymaps.
    zvm_after_init_commands+=('__zoxide_bind_cd_tab')
    zvm_after_lazy_keybindings_commands+=('__zoxide_bind_cd_tab')
  fi
fi

return 0
# vim: set ft=zsh ts=2 sw=2:
