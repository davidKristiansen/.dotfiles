#!/usr/bin/env sh
# ─────────────────────────────────────────────────────────────────────────────
#  Waybar custom/teams — right-click action menu (small floating terminal + fzf)
# ─────────────────────────────────────────────────────────────────────────────
#  Right-click pops a small centered floating ghostty (app_id=term.teams-menu →
#  caught by the sway for_window rule: floating, sticky, 320×190px, centered)
#  running fzf. Picking a row runs the action and the terminal closes.
#
#  teams-for-linux is a systemd *user* service (teams-for-linux.service) and
#  takes commands over the local mosquitto broker (teams/command). Its window
#  replaces the tray icon, so "hide" parks it in the scratchpad.
#
#  Roles in one file:
#    toggle    left-click (waybar on-click) / $mod+t → show-here or hide Teams
#    (no arg)  right-click (waybar on-click-right) → open the floating menu
#    --menu    running inside that terminal → show fzf, run the choice
# ─────────────────────────────────────────────────────────────────────────────

BROKER="${TEAMS_MQTT_BROKER:-localhost}"
PORT="${TEAMS_MQTT_PORT:-1883}"
APP_ID="${TEAMS_APP_ID:-teams-for-linux}"
MENU_ID="term.teams-menu"

mute()    { mosquitto_pub -h "$BROKER" -p "$PORT" -t teams/command \
              -m '{"action":"toggle-mute"}' -q 1; }
hide()    { swaymsg "[app_id=\"$APP_ID\"] move scratchpad" 2>/dev/null; }
restart() { systemctl --user restart teams-for-linux.service; }
quit()    { systemctl --user stop    teams-for-linux.service; }

# Locate Teams by the workspace holding its window, then toggle:
#   absent         → not running / no window → launch (single-instance safe).
#   focused ws     → already here → hide it (sway's only "minimize": scratchpad).
#   __i3_scratch   → hidden in the scratchpad → reveal it on the current ws.
#   other ws       → living elsewhere → pull it to the current workspace.
toggle() {
  ws=$(swaymsg -t get_tree | jq -r --arg a "$APP_ID" '
    [ .. | objects | select(.type? == "workspace")
      | select([ .. | objects | select(.app_id? == $a) ] | length > 0)
      | .name ] | .[0] // "absent"')
  focused=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .name')

  case "$ws" in
    absent)        teams-for-linux ;;
    __i3_scratch)  swaymsg "[app_id=\"$APP_ID\"] scratchpad show" ;;
    "$focused")    swaymsg "[app_id=\"$APP_ID\"] move scratchpad" ;;
    *)             swaymsg "[app_id=\"$APP_ID\"] move container to workspace current, focus" ;;
  esac
}

if [ "$1" = "toggle" ]; then
  toggle
  exit 0
fi

# ── inner role: the fzf menu, running inside the floating terminal ────────────
if [ "$1" = "--menu" ]; then
  choice=$(printf '%s\n' \
    "󰍬  Toggle mute" \
    "󰖰  Hide window" \
    "󰑓  Restart Teams" \
    "󰗼  Quit Teams" \
    | fzf --reverse --height 100% --info=hidden --border=none \
          --prompt 'Teams  ' --pointer '▶')

  case "$choice" in
    *"Toggle mute"*)   mute ;;
    *"Hide window"*)   hide ;;
    *"Restart Teams"*) restart ;;
    *"Quit Teams"*)    quit ;;
  esac
  exit 0
fi

# ── outer role: open the centered floating terminal (positioned by the rule) ──
menu_exists() {
  swaymsg -t get_tree | jq -e --arg a "$MENU_ID" 'any(..; .app_id? == $a)' >/dev/null
}

# Already open (double right-click) → dismiss it instead of stacking a second.
if menu_exists; then
  swaymsg "[app_id=\"$MENU_ID\"] kill"
  exit 0
fi

exec swaymsg "exec --no-startup-id ghostty --class=$MENU_ID -e $HOME/.config/waybar/teams-menu.sh --menu"
