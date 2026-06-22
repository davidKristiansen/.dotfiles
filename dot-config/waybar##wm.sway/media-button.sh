#!/usr/bin/env bash
# Media control glyph for Waybar — usage: media-button.sh <prev|play|next>
#
# Each button only appears while an MPRIS player exists, and the "play" button
# reflects the live playback state. Event-driven via `playerctl --follow`.

btn="$1"

playerctl --follow --format '{{status}}' metadata 2>/dev/null |
while IFS= read -r status; do
  # Empty status == no player → blank line hides the button.
  if [ -z "$status" ]; then
    printf '\n'
    continue
  fi

  case "$btn" in
    prev) printf '\n' ;;
    next) printf '\n' ;;
    play)
      case "$status" in
        Playing) printf '\n' ;;   # show pause glyph while playing
        *)       printf '\n' ;;     # show play glyph otherwise
      esac
      ;;
  esac
done

# vim: set ft=sh ts=2 sw=2:
