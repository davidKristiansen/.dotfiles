# ~/.config/zsh/zshrc.d/06-dotfiles-update.zsh
# SPDX-License-Identifier: MIT
#
# Notify (never auto-apply) when the dotfiles repo has upstream changes.
#
# Design choices:
#   - We FETCH only (read-only) — we never `pull`, never run `bootstrap`, and
#     never `exec zsh`. Applying updates is the user's explicit, manual choice.
#   - Throttled to at most once/hour so N terminals don't spam the network.
#   - Locked so concurrent shells don't fetch on top of each other.
#   - All git output is suppressed and the fetch is backgrounded so it never
#     prints during p10k's instant prompt.

zmodload -F zsh/datetime b:strftime p:EPOCHSECONDS
zmodload -F zsh/stat     b:zstat
zmodload -F zsh/system   b:zsystem 2>/dev/null

typeset -g _dot_dir="${DOT_DIR:-$HOME/.dotfiles}"
typeset -g _dot_cache="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}"
typeset -g _dot_check_stamp="$_dot_cache/dotfiles-last-check"   # throttle marker
typeset -g _dot_avail_stamp="$_dot_cache/dotfiles-update-available"
typeset -g _dot_lock="$_dot_cache/dotfiles-fetch.lock"
typeset -gi _dot_throttle=3600   # seconds between fetches

# ── throttled background fetch ──────────────────────────────────────────────
() {
  local now=$EPOCHSECONDS last=0 mtime
  if zstat -A mtime +mtime "$_dot_check_stamp" 2>/dev/null; then
    last=$mtime
  fi
  (( now - last < _dot_throttle )) && return 0

  [[ -d "$_dot_dir/.git" ]] || return 0

  (
    # Single-fetcher lock: a second shell that can't grab it just bows out.
    if ! mkdir "$_dot_lock" 2>/dev/null; then
      exit 0
    fi
    trap 'rmdir "$_dot_lock" 2>/dev/null' EXIT

    touch "$_dot_check_stamp"
    git -C "$_dot_dir" fetch --quiet || exit 0

    # Behind upstream? (HEAD has an upstream and it is ahead of us)
    local upstream behind
    upstream=$(git -C "$_dot_dir" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null) || exit 0
    behind=$(git -C "$_dot_dir" rev-list --count "HEAD..@{u}" 2>/dev/null) || exit 0
    if [[ -n "$behind" && "$behind" != 0 ]]; then
      print -r -- "$behind" >| "$_dot_avail_stamp"
    fi
  ) &>/dev/null &!
}

# ── one-shot notification on next prompt ────────────────────────────────────
_dotfiles_update_notify() {
  [[ -f "$_dot_avail_stamp" ]] || return
  local behind
  behind=$(<"$_dot_avail_stamp" 2>/dev/null)
  command rm -f "$_dot_avail_stamp"   # show once
  print -P -- "%F{yellow}📦 dotfiles: ${behind:-new} commit(s) upstream%f — run: %F{cyan}dotfiles pull --rebase && \"\$DOT_DIR\"/bootstrap%f"
  # Remove the hook after firing; the next shell re-arms it at load.
  add-zsh-hook -d precmd _dotfiles_update_notify
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _dotfiles_update_notify

# vim: set ft=zsh ts=2 sw=2:
