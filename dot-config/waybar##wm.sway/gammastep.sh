#!/usr/bin/env bash
# gammastep.sh — waybar night-light control.
#   (no args)  emit JSON status for the custom/gammastep module
#   toggle     start gammastep if stopped, stop it if running
#
# gammastep reads ~/.config/gammastep/config.ini (manual location, wayland
# adjustment) and restores the gamma ramps on a clean SIGTERM exit.

case "$1" in
  toggle)
    if pgrep -x gammastep >/dev/null; then
      pkill -x gammastep
    else
      gammastep >/dev/null 2>&1 &
    fi
    ;;
  *)
    if pgrep -x gammastep >/dev/null; then
      printf '{"text":"󰖔","class":"on","tooltip":"Night light: on"}\n'
    else
      printf '{"text":"󰖙","class":"off","tooltip":"Night light: off"}\n'
    fi
    ;;
esac
