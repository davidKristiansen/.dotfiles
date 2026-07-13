#!/usr/bin/env sh
# ─────────────────────────────────────────────────────────────────────────────
#  launcher.sh — single-instance fzf launcher ($mod+d, aka $menu)
# ─────────────────────────────────────────────────────────────────────────────
#  Opens fzf-launcher in a floating ghostty (app_id=term.launcher, styled by the
#  for_window rule). If one is already open, focus it instead of spawning a
#  second — so $mod+d never stacks duplicate launcher windows.
# ─────────────────────────────────────────────────────────────────────────────

APP_ID=term.launcher

if swaymsg -t get_tree | jq -e --arg a "$APP_ID" 'any(..; .app_id? == $a)' \
     >/dev/null 2>&1; then
  exec swaymsg "[app_id=\"$APP_ID\"] focus"
fi

exec ghostty --class="$APP_ID" -e "$HOME/.local/bin/fzf-launcher"
