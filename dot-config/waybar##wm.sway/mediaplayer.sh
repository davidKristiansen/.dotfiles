#!/usr/bin/env bash
# Generic MPRIS "now playing" for Waybar.
#
# Works with ANY MPRIS player (Spotify, mpv, Firefox, …) via playerctl.
# Event-driven through `playerctl --follow` — no polling. Emits one line of
# Waybar JSON per change; clears the module when no player is present.
#
# JSON is built with jq so titles containing quotes/backslashes can't break it.

TAB=$'\t'

playerctl --follow \
  --format "{{status}}${TAB}{{markup_escape(artist)}}${TAB}{{markup_escape(title)}}${TAB}{{markup_escape(album)}}${TAB}{{playerName}}" \
  metadata 2>/dev/null |
while IFS="$TAB" read -r status artist title album player; do
  # No active player → blank line clears the module.
  if [ -z "$title" ] && [ -z "$artist" ]; then
    printf '\n'
    continue
  fi

  if [ -n "$artist" ]; then
    text="$artist — $title"
  else
    text="$title"
  fi

  tooltip="$title"
  [ -n "$artist" ] && tooltip="$tooltip"$'\n'"$artist"
  [ -n "$album" ]  && tooltip="$tooltip"$'\n'"$album"
  [ -n "$player" ] && tooltip="$tooltip"$'\n\n'"via ${player} · ${status}"

  class="$(printf '%s' "$status" | tr '[:upper:]' '[:lower:]')"

  jq -nc \
    --arg text "$text" \
    --arg tooltip "$tooltip" \
    --arg class "$class" \
    --arg alt "$status" \
    '{text:$text, tooltip:$tooltip, class:$class, alt:$alt}'
done

# vim: set ft=sh ts=2 sw=2:
