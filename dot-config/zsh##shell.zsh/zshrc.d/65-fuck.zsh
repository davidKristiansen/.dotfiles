# ~/.config/zsh/zshrc.d/65-fuck.zsh
# SPDX-License-Identifier: MIT
#
# pay-respects: maintained, Rust-based `thefuck` replacement (no Python).
#   - `fuck`            : correct & run the last command (interactive picker)
#   - Esc-Esc           : run the full corrector on the last command (vi: Esc, Esc)
#   - Ctrl-X Ctrl-X     : inline typo-fix the command on the line (insert mode)
#   - command-not-found : suggests missing commands automatically

if (( $+commands[pay-respects] )); then
  # Sets up the `fuck` alias, the `__pr_*` helpers, the `^X^X` inline widget,
  # and the command_not_found_handler. Output is static — cached (03-cached-eval).
  _cached_eval pay-respects pay-respects zsh --alias fuck

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

  # Bindings (applied by _user_rebind_all in 80-keybindings.zsh):
  #   vicmd Esc        -> fix last command (vi flow: Esc to normal, Esc to fix)
  #   emacs Esc-Esc    -> fix last command (if ever running in emacs mode)
  #   viins/emacs ^X^X -> inline fix of the command on the line (pay-respects)
  __pr_bind_keys() {
    bindkey -M vicmd '\e'   __pr_fix_last 2>/dev/null
    bindkey -M emacs '\e\e' __pr_fix_last 2>/dev/null
    bindkey -M viins '^X^X' __pr_inline   2>/dev/null
    bindkey -M emacs '^X^X' __pr_inline   2>/dev/null
  }
fi

return 0
# vim: set ft=zsh ts=2 sw=2:
