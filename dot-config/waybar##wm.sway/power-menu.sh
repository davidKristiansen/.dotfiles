#!/usr/bin/env bash
# Sway power menu — a swaynag bar with confirmable actions.
# Triggered by the Waybar power button. Re-running closes the previous one.

pkill -x swaynag 2>/dev/null

exec swaynag \
  -t warning \
  -m '  Power' \
  -b '  Lock'      'loginctl lock-session' \
  -b '  Logout'    'swaymsg exit' \
  -b '  Suspend'   'systemctl suspend' \
  -b '  Reboot'    'systemctl reboot' \
  -b '  Shutdown'  'systemctl poweroff'

# vim: set ft=sh ts=2 sw=2:
