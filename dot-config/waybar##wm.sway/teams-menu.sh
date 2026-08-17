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
#  replaces the tray icon, so instead of a scratchpad it lives "docked" (tiled,
#  ~left-half) on workspace $DOCK_WS; toggling flips it between that dock and a
#  floating window on whatever workspace you're currently looking at.
#
#  Roles in one file:
#    toggle    left-click (waybar on-click) / $mod+t → float-here ⇄ dock on W10
#    (no arg)  right-click (waybar on-click-right) → open the floating menu
#    --menu    running inside that terminal → show fzf, run the choice
# ─────────────────────────────────────────────────────────────────────────────

BROKER="${TEAMS_MQTT_BROKER:-localhost}"
PORT="${TEAMS_MQTT_PORT:-1883}"
APP_ID="${TEAMS_APP_ID:-teams-for-linux}"
MENU_ID="term.teams-menu"
DOCK_WS="${TEAMS_DOCK_WS:-10}"

mute()    { mosquitto_pub -h "$BROKER" -p "$PORT" -t teams/command \
              -m '{"action":"toggle-mute"}' -q 1; }
# dock: tile Teams onto workspace $DOCK_WS. A container moved to a workspace lands
#       on the right, so shuffle it left until it reaches the workspace's left edge,
#       then give it ~half the width. Alone it's already leftmost and a lone tiled
#       window ignores the resize → it just fills the workspace (which is fine).
dock() {
  swaymsg "[app_id=\"$APP_ID\"] floating disable, \
           move container to workspace number $DOCK_WS" 2>/dev/null
  # A moved container lands on the right, and ws10's windows sit inside a
  # full-width column — so nudge Teams left until it's the workspace's first
  # top-level tile (each 'move left' pops it one step out/leftward). Alone it
  # becomes the sole tile and the 50% resize is a no-op → it fills the screen.
  guard=0
  while [ "$guard" -lt 12 ]; do
    first=$(swaymsg -t get_tree | jq -r --arg a "$APP_ID" '
      ( [ .. | objects | select(.type? == "workspace")
          | select([ .. | objects | select(.app_id? == $a) ] | length > 0) ] | .[0] ) as $w
      | if (($w.nodes[0]? // {}) | .app_id) == $a then "yes" else "no" end')
    [ "$first" = "yes" ] && break
    swaymsg "[app_id=\"$APP_ID\"] move left" >/dev/null 2>&1
    guard=$((guard + 1))
  done
  swaymsg "[app_id=\"$APP_ID\"] resize set width 66 ppt" 2>/dev/null
}
# floaty: pull Teams onto the current workspace as a centered floating window.
floaty()  { swaymsg "[app_id=\"$APP_ID\"] move container to workspace current, \
              floating enable, resize set 60 ppt 70 ppt, move position center, \
              focus"; }
hide()    { dock; }   # menu "Hide window" now = send it back to the W$DOCK_WS dock
restart() { systemctl --user restart teams-for-linux.service; }
quit()    { systemctl --user stop    teams-for-linux.service; }

# True when Teams' window is currently floating (its con is a floating_con) — i.e.
# it's a "floaty", not tiled in the dock.
is_floating() {
  swaymsg -t get_tree | jq -e --arg a "$APP_ID" \
    '[ .. | objects | select(.app_id? == $a) | .type ] | any(. == "floating_con")' \
    >/dev/null
}

# Locate Teams by the workspace holding its window, then flip its state:
#   absent                → not running / no window → launch (single-instance safe).
#   floaty on this ws     → you're looking at the floaty → tile it back in the dock.
#   docked / on another ws → pull it here as a floating window (focus follows).
toggle() {
  ws=$(swaymsg -t get_tree | jq -r --arg a "$APP_ID" '
    [ .. | objects | select(.type? == "workspace")
      | select([ .. | objects | select(.app_id? == $a) ] | length > 0)
      | .name ] | .[0] // "absent"')
  focused=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .name')

  if [ "$ws" = "absent" ]; then
    teams-for-linux
  elif [ "$ws" = "$focused" ] && is_floating; then
    dock
  else
    floaty
  fi
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
