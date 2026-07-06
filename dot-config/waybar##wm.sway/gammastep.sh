#!/usr/bin/env bash
# gammastep.sh — waybar night-light control.
#   (no args)  emit JSON status for the custom/gammastep module
#   toggle     start gammastep.service if stopped, stop it if running
#
# gammastep runs as a systemd user unit (gammastep.service). It reads
# ~/.config/gammastep/config.ini (manual location, wayland adjustment) and
# restores the gamma ramps on the clean SIGTERM that `systemctl stop` sends.

is_on() { systemctl --user is-active --quiet gammastep.service; }

case "$1" in
  toggle)
    if is_on; then
      systemctl --user stop gammastep.service
    else
      systemctl --user start gammastep.service
    fi
    ;;
  *)
    if is_on; then
      printf '{"text":"󰖔","class":"on","tooltip":"Night light: on"}\n'
    else
      printf '{"text":"󰖙","class":"off","tooltip":"Night light: off"}\n'
    fi
    ;;
esac
