#!/bin/sh

/usr/bin/swayidle -d -w \
  timeout 240   'swaymsg "output * dpms off"' \
    resume   'swaymsg "output * dpms on"'  \
  timeout 120   'lock.sh'       \
    resume   'swaymsg "output * dpms on"'  \
  timeout 1800   'systemctl suspend'           \
    resume   'swaymsg "output * dpms on"'  \
    before-sleep   'lock.sh'
