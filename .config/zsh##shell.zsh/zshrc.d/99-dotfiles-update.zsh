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
    zsystem flock -t 0 "$DOT_LOCK" >/dev/null 2>&1 || return 1
  else
    mkdir "$DOT_LOCK.dir" 2>/dev/null || return 1
  fi
  # Be quiet if lock is acquired (produce no output)
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
  setopt LOCAL_OPTIONS NO_NOTIFY NO_MONITOR

  _acquire_lock || return 0
  {
    # repo sanity
    git -C "$DOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

    # config
    local DOT_BRANCH="${DOT_BRANCH:-main}"
    local start_branch
    start_branch=$(git -C "$DOT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null) || return 0

    # helper: dirty check (index or worktree)
    local dirty=0
    git -C "$DOT_DIR" diff --quiet --ignore-submodules -- || dirty=1
    git -C "$DOT_DIR" diff --cached --quiet --ignore-submodules -- || dirty=1

    # If not on main: only auto-switch if clean
    if [[ "$start_branch" != "$DOT_BRANCH" ]]; then
      if (( dirty )); then
        _log "working tree dirty on '$start_branch'; skip auto-switch to $DOT_BRANCH"
        return 0
      fi
    fi

    # Ensure remote tracking for main exists; fetch quietly (tolerate offline fail)
    git -C "$DOT_DIR" fetch --prune --quiet 2>/dev/null || {
      _log "fetch failed (offline?); skipping"
      return 0
    }

    # Make sure local main exists; create/tracking if missing
    if ! git -C "$DOT_DIR" show-ref --verify --quiet "refs/heads/$DOT_BRANCH"; then
      if git -C "$DOT_DIR" show-ref --verify --quiet "refs/remotes/origin/$DOT_BRANCH"; then
        git -C "$DOT_DIR" branch --track "$DOT_BRANCH" "origin/$DOT_BRANCH" >/dev/null 2>&1 || true
      fi
    fi

    # Checkout main if needed
    if [[ "$start_branch" != "$DOT_BRANCH" ]]; then
      git -C "$DOT_DIR" checkout -q "$DOT_BRANCH" || {
        _log "cannot checkout $DOT_BRANCH; skipping"
        return 0
      }
    fi

    # Ensure upstream for main
    git -C "$DOT_DIR" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1 \
      || git -C "$DOT_DIR" branch --set-upstream-to "origin/$DOT_BRANCH" "$DOT_BRANCH" >/dev/null 2>&1 || true

    # Check if remote has updates for main
    local need_update=0
    need_update=$(git -C "$DOT_DIR" rev-list --count "HEAD..origin/$DOT_BRANCH" 2>/dev/null || print 0)

    if (( need_update > 0 )); then
      _log "$DOT_BRANCH behind by $need_update; fast-forwarding…"
      # Fast-forward only to keep main pristine
      if git -C "$DOT_DIR" merge --ff-only --quiet "origin/$DOT_BRANCH"; then
        _log "updated $DOT_BRANCH; running bootstrap"
        if [[ -x "$DOT_DIR/bootstrap" ]]; then
          ( cd "$DOT_DIR" && ./bootstrap ) >>"$DOT_LOG" 2>&1
        else
          _log "bootstrap not executable or missing"
        fi
      else
        _log "$DOT_BRANCH diverged locally; not auto-merging"
      fi
    fi

    # If we started on a different branch, hop back and rebase onto updated main
    if [[ "$start_branch" != "$DOT_BRANCH" ]] && \
       git -C "$DOT_DIR" show-ref --verify --quiet "refs/heads/$start_branch"; then
      git -C "$DOT_DIR" checkout -q "$start_branch" || {
        _log "failed to return to '$start_branch'"; return 0
      }
      # Rebase with autostash and preserve merges if any
      if git -C "$DOT_DIR" rebase --autostash --rebase-merges "$DOT_BRANCH" >/dev/null 2>&1; then
        _log "rebased '$start_branch' onto '$DOT_BRANCH'"
      else
        _log "rebase of '$start_branch' onto '$DOT_BRANCH' failed; aborting"
        git -C "$DOT_DIR" rebase --abort >/dev/null 2>&1 || true
      fi
    fi
  } always {
    _release_lock
  }
}

# --- fire in the background --------------------------------------------------
{ _dotfiles_auto_update } &!

# vim: set ft=zsh ts=2 sw=2:

