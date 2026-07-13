# ─────────────────────────────────────────────────────────────────────────────
#  quickcmd wrapper ZDOTDIR — a one-line "Run" box that keeps your zsh intact
# ─────────────────────────────────────────────────────────────────────────────
#  quickcmd.sh launches `zsh -i` with ZDOTDIR pointing here and the real config
#  dir passed in $QUICKCMD_ORIG_ZDOTDIR. We load your full interactive config
#  (so completions, aliases and functions all work), then rebind Enter to launch
#  the typed command detached and quit — like Windows' Run dialog.
# ─────────────────────────────────────────────────────────────────────────────

# p10k's instant prompt assumes it owns startup output; skip it for this box.
POWERLEVEL9K_INSTANT_PROMPT=off

ORIG=${QUICKCMD_ORIG_ZDOTDIR:-$HOME}

# Load the real environment + interactive config from the original ZDOTDIR.
# Restore ZDOTDIR first so the sourced files' own "$ZDOTDIR/..." paths resolve.
[[ -r $HOME/.zshenv  ]] && source $HOME/.zshenv
ZDOTDIR=$ORIG
[[ -r $ORIG/.zshenv  ]] && source $ORIG/.zshenv
[[ -r $ORIG/.zshrc   ]] && source $ORIG/.zshrc

autoload -Uz add-zsh-hook

# Run-box behaviour via preexec (fires whenever a command line is accepted).
# We intercept *before* the shell runs it: launch it detached (so GUI apps don't
# tie the box open) and quit. Using preexec instead of rebinding Enter means we
# survive p10k, which rebinds ^M at line-init and would otherwise win.
# `zsh -ic` re-parses interactively so aliases expand as they would at a prompt.
_qc_preexec() {
  setsid ${SHELL:-zsh} -ic "$1" >/dev/null 2>&1 </dev/null &!
  exit 0
}
add-zsh-hook preexec _qc_preexec

# Force a minimal one-line prompt, overriding whatever the real config set
# (added last, so it wins over p10k's own precmd on every redraw).
_qc_prompt() { PROMPT='%F{cyan}❯%f '; RPROMPT=''; }
add-zsh-hook precmd _qc_prompt

# Wipe any startup output (motd, greeters) once, before the first prompt.
_qc_first=1
_qc_clear() { (( _qc_first )) && { clear; _qc_first=0; }; }
add-zsh-hook precmd _qc_clear
