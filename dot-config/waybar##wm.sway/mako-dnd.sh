#!/usr/bin/env bash
# mako-dnd.sh — waybar Do Not Disturb indicator for mako.
#   (no args)  emit JSON status for the custom/mako module
#   toggle     toggle mako's do-not-disturb mode
#
# mako tracks active "modes"; `makoctl mode` prints them one per line. We treat
# the presence of "do-not-disturb" as DND on. If mako isn't running yet,
# makoctl errors and we fall through to the notifications-on state.

case "$1" in
  toggle)
    makoctl mode -t do-not-disturb >/dev/null 2>&1
    ;;
  *)
    if makoctl mode 2>/dev/null | grep -qx 'do-not-disturb'; then
      printf '{"text":"󰂛","class":"on","tooltip":"Do Not Disturb: on"}\n'
    else
      printf '{"text":"󰂚","class":"off","tooltip":"Notifications: on"}\n'
    fi
    ;;
esac
