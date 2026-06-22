# SPDX-License-Identifier: MIT
# Auto-save tmux window state on directory change and after commands.
# Only triggers inside tmux, and only if the current window has a save file.

[[ -n "$TMUX" ]] || return 0

_tmux_autosave_window() {
    local save_dir="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/windows"
    local window_name
    window_name=$(tmux display-message -p '#{window_name}' 2>/dev/null) || return
    [[ -f "$save_dir/$window_name" ]] || return
    "$HOME/.local/bin/tmux-autosave-window" &!
}

# Delayed variant: wait briefly so pane_current_command reflects the new
# process (e.g. nvim) before snapshotting.
_tmux_autosave_window_delayed() {
    local save_dir="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/windows"
    local window_name
    window_name=$(tmux display-message -p '#{window_name}' 2>/dev/null) || return
    [[ -f "$save_dir/$window_name" ]] || return
    { sleep 0.3 && "$HOME/.local/bin/tmux-autosave-window" } &!
}

autoload -Uz add-zsh-hook
# chpwd: directory changes are instant, save immediately
add-zsh-hook chpwd   _tmux_autosave_window
# preexec: fires before a command runs; delay so pane_current_command updates
add-zsh-hook preexec _tmux_autosave_window_delayed
