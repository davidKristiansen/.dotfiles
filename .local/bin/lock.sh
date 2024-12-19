#!/bin/sh

DUMP="${XDG_CACHE_HOME}"/bg.png
CORRUPTED=/tmp/bgc.png

grim "${DUMP}"
corrupter -mag 1 -boffset 3 -meanabber 5 "${DUMP}" "${CORRUPTED}"

gtklock --daemonize -s "${XDG_CONFIG_HOME}"/gtklock/style.css
