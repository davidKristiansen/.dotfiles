# ~/.config/zsh/zshrc.d/51-zoxide.zsh
# SPDX-License-Identifier: MIT
# Cached zoxide init (see 03-cached-eval.zsh).

if (( $+commands[zoxide] )); then
  _cached_eval zoxide zoxide init zsh --cmd cd

  # Wrap the original hook to handle cases where zoxide becomes unavailable later
  if (( $+functions[__zoxide_hook] )); then
    # Save the original hook
    function __zoxide_hook_original() {
      \command zoxide add -- "$(__zoxide_pwd)"
    }
    # Replace the hook with a safe version
    function __zoxide_hook() {
      if \command -v zoxide >/dev/null 2>&1; then
        __zoxide_hook_original "$@"
      fi
    }
  fi

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
      # ${(z)...}[2] = second word of `bindkey '^I'` output (no awk fork).
      local current_tab
      current_tab="${${(z)$(\builtin bindkey '^I' 2>/dev/null)}[2]}"
      if [[ -n "$current_tab" && "$current_tab" != __zoxide_cd_tab_widget ]]; then
        __zoxide_orig_tab_widget="$current_tab"
      fi
      \builtin bindkey '^I' __zoxide_cd_tab_widget
    }
    # NOTE: binding is applied by _user_rebind_all in 80-keybindings.zsh —
    # after enable-fzf-tab, so the delegate target is fzf-tab-complete.
  fi
fi

return 0
# vim: set ft=zsh ts=2 sw=2:
