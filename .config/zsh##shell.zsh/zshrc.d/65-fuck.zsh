# ~/.config/zsh/zshrc.d/65-fuck.zsh
# SPDX-License-Identifier: MIT
#
# pay-respects: maintained, Rust-based `thefuck` replacement (no Python).
#   - `fuck`            : correct & run the last command (interactive picker)
#   - Esc-Esc           : run the full corrector on the last command (vi: Esc, Esc)
#   - Ctrl-X Ctrl-X     : inline typo-fix the command on the line (insert mode)
#   - command-not-found : suggests missing commands automatically

if command -v pay-respects >/dev/null 2>&1; then
  # Sets up the `fuck` alias, the `__pr_*` helpers, the `^X^X` inline widget,
  # and the command_not_found_handler.
  eval "$(pay-respects zsh --alias fuck)"

  # pay-respects' generated __pr_base captures the prompt via `print -P "$PROMPT"`
  # to pass as a context hint. Powerlevel10k's $PROMPT contains constructs that
  # error ("bad substitution") when re-expanded that way, which breaks `fuck`,
  # the inline widget, and command-not-found alike. The prefix is only a hint,
  # so override __pr_base to skip the prompt capture entirely.
  __pr_base() {
    _PR_MODE="$1" _PR_PREFIX="" _PR_LAST_COMMAND="$2" _PR_ALIAS="$(alias)" _PR_SHELL="zsh" pay-respects
  }

  # Esc-Esc runs the *full* corrector (identical to typing `fuck`), so it also
  # handles fixes inline mode can't infer from the command text alone — e.g.
  # `apt update` -> `sudo apt update`. pay-respects shows its confirm picker,
  # then runs the chosen command. (Use Ctrl-X Ctrl-X for inline typo fixes.)
  __pr_fix_last() {
    BUFFER='fuck'
    zle .accept-line
  }
  zle -N __pr_fix_last

  # zsh-vi-mode (zvm) resets all keymaps on its deferred init, wiping any
  # bindkey done at source time — the same reason 70-fzf.zsh / 51-zoxide.zsh
  # rebind via zvm hooks. Put every binding in a function, call it once, and
  # register it with both zvm after-init hooks so it survives the reset.
  #   vicmd Esc        -> fix last command (vi flow: Esc to normal, Esc to fix)
  #   emacs Esc-Esc    -> fix last command (if ever running in emacs mode)
  #   viins/emacs ^X^X -> inline fix of the command on the line (pay-respects)
  __pr_bind_keys() {
    bindkey -M vicmd '\e'   __pr_fix_last 2>/dev/null
    bindkey -M emacs '\e\e' __pr_fix_last 2>/dev/null
    bindkey -M viins '^X^X' __pr_inline   2>/dev/null
    bindkey -M emacs '^X^X' __pr_inline   2>/dev/null
  }
  __pr_bind_keys
  zvm_after_init_commands+=('__pr_bind_keys')
  zvm_after_lazy_keybindings_commands+=('__pr_bind_keys')
fi

return 0
# vim: set ft=zsh ts=2 sw=2:
