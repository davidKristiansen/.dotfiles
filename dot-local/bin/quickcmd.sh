#!/usr/bin/env sh
# ─────────────────────────────────────────────────────────────────────────────
#  quickcmd.sh — Windows-"Run"-style one-line command box ($mod+r)
# ─────────────────────────────────────────────────────────────────────────────
#  Opens a tiny floating ghostty (app_id=term.quickcmd) running your interactive
#  zsh via a wrapper ZDOTDIR (~/.config/quickcmd), so completions/aliases stay
#  intact. Enter runs the typed command detached and the box closes; empty input
#  or Ctrl-D just closes. Re-pressing $mod+r replaces any open box.
#
#  ghostty clamps its window height at initial map (a terminal advertises a
#  min size), so the one-line height from the window rule doesn't stick. We
#  background a poller that shrinks the box to one line once it has mapped.
# ─────────────────────────────────────────────────────────────────────────────

APP_ID=term.quickcmd
QC_ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/quickcmd"
QC_HEIGHT="${QUICKCMD_HEIGHT:-50}"   # px; bump this if you want room for menus

# Replace any box already open (kill is harmless when nothing matches).
swaymsg "[app_id=\"$APP_ID\"] kill" 2>/dev/null

# Once the window maps, shrink it to one line. zsh/p10k loading causes ghostty
# to reflow (re-growing the box), so retry the resize until the height sticks.
(
  i=0
  while [ "$i" -lt 60 ]; do
    swaymsg -t get_tree | jq -e --arg a "$APP_ID" 'any(..; .app_id? == $a)' \
      >/dev/null 2>&1 && break
    i=$((i + 1)); sleep 0.05
  done
  j=0
  while [ "$j" -lt 25 ]; do
    swaymsg "[app_id=\"$APP_ID\"] resize set 620 px $QC_HEIGHT px, move position center" \
      >/dev/null 2>&1
    sleep 0.15
    cur=$(swaymsg -t get_tree | jq -r --arg a "$APP_ID" \
      '.. | objects | select(.app_id? == $a) | .rect.height' 2>/dev/null)
    [ -n "$cur" ] && [ "$cur" -le "$((QC_HEIGHT + 8))" ] && break
    j=$((j + 1))
  done
) &

exec ghostty --class="$APP_ID" --window-padding-x=8 --window-padding-y=2 \
  -e env QUICKCMD_ORIG_ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}" \
         ZDOTDIR="$QC_ZDOTDIR" zsh -i
