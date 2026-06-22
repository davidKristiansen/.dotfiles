#!/bin/bash

while true; do
    if playerctl status --player=spotify &> /dev/null; then
        PLAYER_NAME=$(playerctl metadata --player=spotify --format '{{playerName}}')
        ARTIST=$(playerctl metadata --player=spotify --format '{{artist}}')
        TITLE=$(playerctl metadata --player=spotify --format '{{title}}')
        STATUS=$(playerctl --player=spotify status)

        if [ -n "$ARTIST" ]; then
            TEXT="$ARTIST - $TITLE"
        else
            TEXT="$TITLE"
        fi

        # Escape special characters for JSON
        TEXT=$(echo "$TEXT" | sed 's/"/\"/g')

        echo "{\"text\": \"$TEXT\", \"class\": \"custom-$PLAYER_NAME\", \"alt\": \"$PLAYER_NAME\"}"
    else
        echo "{}"
    fi
    sleep 1
done

# vim: set ft=sh ts=2 sw=2: