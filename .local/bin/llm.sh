# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

#/bin/sh

APP_ID=cadlkienfkclaiaibeoongdcgmdikeeg
APP_URL=https://chatgpt.com/

if ! (ps aux | grep "${APP_ID}"| grep -v grep > /dev/null); then
  swaymsg "exec                          \
    --no-startup-id                      \
    /opt/microsoft/msedge/microsoft-edge \
    --profile-directory=Default          \
    --app-id=${APP_ID}                   \
    --app-url=${APP_URL}                 \
    --class=crx__${APP_ID}"
  sleep 1.5
fi

swaymsg "[instance=crx__${APP_ID}] scratchpad show, move position center, resize set 90 ppt 90 ppt"

# vim: filetype=sh
