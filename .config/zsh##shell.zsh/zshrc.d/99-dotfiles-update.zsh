#!/usr/bin/env zsh
# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

# --- bail if repo missing ----------------------------------------------------
[[ -d "$DOT_DIR/.git" ]] || return 0

# --- paths -------------------------------------------------------------------
: "${XDG_STATE_HOME:=$HOME/.local/state}"
typeset -gx DOT_STATE_DIR="$XDG_STATE_HOME/dotfiles"
typeset -gx DOT_LOG="$DOT_STATE_DIR/update.log"
typeset -gx DOT_LOCK="$DOT_STATE_DIR/update.lock"

mkdir -p -- "$DOT_STATE_DIR"

# --- tiny logger -------------------------------------------------------------
_log() {
  if [[ -t 1 ]]; then
    print -r -- "[dotfiles] $*"
  else
    print -r -- "[$(date +'%F %T')] $*" >>"$DOT_LOG"
  fi
}

# --- only run in background once --------------------------------------------
# lock using zsh's flock (portable fallback: mkdir)
_acquire_lock() {
  mkdir -p -- "$DOT_STATE_DIR"
  touch -- "$DOT_LOCK"
  if zmodload -F zsh/system b:zsystem 2>/dev/null; then
    zsystem flock -t 0 "$DOT_LOCK" || return 1
  else
    mkdir "$DOT_LOCK.dir" 2>/dev/null || return 1
  fi
}

_release_lock() {
  if command -v zsystem >/dev/null 2>&1; then
    zsystem flock -u "$DOT_LOCK" 2>/dev/null || true
  else
    rmdir "$DOT_LOCK.dir" 2>/dev/null || true
  fi
}

# --- worker ------------------------------------------------------------------
_dotfiles_auto_update() {
  # shell: be quiet, don’t notify on background job exit
  setopt LOCAL_OPTIONS NO_NOTIFY NO_MONITOR

  _acquire_lock || return 0
  {
    # sanity: repo & upstream
    git -C "$DOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
    local upstream
    upstream=$(git -C "$DOT_DIR" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null) || {
      _log "no upstream set; skipping"
      return 0
    }

    # fetch quietly; tolerate offline
    git -C "$DOT_DIR" fetch --prune --quiet 2>/dev/null || {
      _log "fetch failed (offline?); skipping"
      return 0
    }

    # compare with upstream
    local ahead behind
    ahead=$(git -C "$DOT_DIR" rev-list --count HEAD.."$upstream" 2>/dev/null || print 0)
    behind=$(git -C "$DOT_DIR" rev-list --count "$upstream"..HEAD 2>/dev/null || print 0)

    if [[ "$ahead" -gt 0 ]]; then
      _log "updates available: pulling (ff-only)…"
      if git -C "$DOT_DIR" pull --ff-only --quiet; then
        _log "updated; running bootstrap"
        if [[ -x "$DOT_DIR/bootstrap" ]]; then
          ( cd "$DOT_DIR" && ./bootstrap ) >>"$DOT_LOG" 2>&1
        else
          _log "bootstrap not executable or missing"
        fi
      else
        _log "pull failed (rebase needed? local changes?); skipping bootstrap"
      fi
    else
      # optionally report divergence
      if [[ "$behind" -gt 0 ]]; then
        _log "local commits ahead of upstream by $behind; not pulling"
      fi
    fi
  } always {
    _release_lock
  }
}

# --- fire in the background --------------------------------------------------
{ _dotfiles_auto_update } &!

# vim: set ft=zsh ts=2 sw=2:

