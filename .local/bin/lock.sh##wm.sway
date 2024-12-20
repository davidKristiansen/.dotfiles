#!/bin/sh

CORRUPTER="${XDG_DATA_HOME}"/mise/installs/go-github-com-r00tman-corrupter/latest/bin/corrupter
DUMP=/tmp/bg.png
CORRUPTED=/tmp/bgc.png

grim "${DUMP}"
"${CORRUPTER}" -mag 1 -boffset 3 -meanabber 5 "${DUMP}" "${CORRUPTED}"

gtklock --daemonize -s "${XDG_CONFIG_HOME}"/gtklock/style.css
