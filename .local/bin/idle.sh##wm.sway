#!/bin/sh

/usr/bin/swayidle -d -w \
  timeout 240   'swaymsg "output * dpms off"' \
    resume   'swaymsg "output * dpms on"'  \
  timeout 120   '"${XDG_BIN_HOME}"/lock.sh'       \
    resume   'swaymsg "output * dpms on"'  \
  timeout 1800   'systemctl suspend'           \
    resume   'swaymsg "output * dpms on"'  \
    before-sleep   '"${XDG_BIN_HOME}"/lock.sh'
