# SPDX-License-Identifier: MIT
# Copyright David Kristiansen
#
# xonsh interactive config.
# Loaded from ~/.config/xonsh/rc.xsh (XDG). Managed via stow (dot-config/xonsh).

# Input syntax highlighting — pygments ships the gruvbox-dark style.
$XONSH_COLOR_STYLE = 'gruvbox-dark'

# --- Dark-background fixes -------------------------------------------------
# Tell apps the terminal is dark (unset under tmux → many tools assume light).
$COLORFGBG = '15;0'

# Use GNU dircolors' dark-safe defaults. xonsh's bundled LsColors theme paints
# backups/temp files as 38;5;16 (pure black) — invisible on a dark terminal.
# $LS_COLORS = $(dircolors -b).split("'")[1]
$LS_COLORS='rs=0:di=01;36:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:'

# Gruvbox the prompt_toolkit widgets. By default the completion menu is
# bg:#bbbbbb on #000000 (a light dropdown) — that's the "light mode" look.
$XONSH_STYLE_OVERRIDES = {
    'completion-menu':                          'bg:#3c3836 #ebdbb2',  # bg1 / fg1
    'completion-menu.completion.current':       'bg:#fabd2f #1d2021',  # yellow / bg0_h
    'completion-menu.meta.completion':          'bg:#504945 #a89984',  # bg2 / fg4
    'completion-menu.meta.completion.current':  'bg:#665c54 #ebdbb2',  # bg3 / fg1
    'completion-menu.multi-column-meta':        'bg:#504945 #ebdbb2',
    'scrollbar.background':                      'bg:#3c3836',
    'scrollbar.button':                         'bg:#fabd2f',
    'auto-suggestion':                          '#665c54',             # dim gruvbox gray
    'bottom-toolbar':                           'bg:#3c3836 #ebdbb2',
}
# ---------------------------------------------------------------------------

# Prompt: starship (shared ~/.config/starship.toml).
# p10k can't run here — it's zsh code; starship is the cross-shell equivalent.
# execx($(starship init xonsh --print-full-init))

# Coreutils as xonsh builtins (cat, echo, …) so they work without GNU coreutils on PATH.
xontrib load coreutils


$MULTILINE_PROMPT = '`·.,¸,.·*¯`·.,¸,.·*¯'
$XONSH_SHOW_TRACEBACK = True
$XONSH_STORE_STDOUT = True
$XONSH_HISTORY_MATCH_ANYWHERE = True
$COMPLETIONS_CONFIRM = True
$XONSH_AUTOPAIR = True
$PROMPT = lambda: '{user}@{hostname}:{cwd} @> '
source "$HOME/.cargo/env.xsh"
