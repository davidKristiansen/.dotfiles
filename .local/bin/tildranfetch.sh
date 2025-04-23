#!/usr/bin/env bash

# SPDX-License-Identifier: MIT
# Copyright (c) 2025 David Kristiansen

# Skip non-interactive or non-color terminals
[ -t 1 ] || exit 0
[ "$(tput colors 2>/dev/null || echo 0)" -lt 256 ] && exit 0

# === Configurable Variables ===
TILDRAN_BLOCK="▀"
TILDRAN_INFO_COL=15
TILDRAN_XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/tildran"
TILDRAN_XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/tildran"
TILDRAN_MESSAGE_FILE="$TILDRAN_XDG_CONFIG_HOME/tildran_messages.txt"
TILDRAN_RARE_MESSAGE_FILE="$TILDRAN_XDG_CONFIG_HOME/tildran_rare_messages.txt"
WEATHER_URL="https://wttr.in/Moss?format=%C+%t"

COLORS=(160 166 178 142 109 139 175)
TERM_COLS=$(tput cols 2>/dev/null || echo 80)
((TERM_COLS < 40)) && TERM_COLS=80
WIDTH=10
INFO_COL=$TILDRAN_INFO_COL

# === Helper Functions ===
get_rune() {
  local runes=("🜁" "🜂" "🜃" "🜄" "🜅" "🜆" "🜇" "🜈" "🜉" "🜊" "🜋" "🜌" "🜍" "🜎" "🜏")
  echo "${runes[RANDOM % ${#runes[@]}]}"
}

get_username() { whoami; }
get_hostname() { hostname; }
get_shell() { echo "$SHELL"; }
get_uptime() { uptime -p | sed 's/^up //'; }
get_last_login() { last -1 "$USER" | awk 'NR==1 {print $4,$5,$6,$7}'; }
get_mem() { free -h | awk '/^Mem:/ {print $3 "/" $2}'; }
get_cpu() { uptime | awk -F'load average:' '{print $2}' | sed 's/^ //'; }

get_weather() {
  local data_dir="$TILDRAN_XDG_DATA_HOME"
  local cache="$data_dir/weather.cache"
  local valid_for=$((15 * 60)) # 15 minutes
  local now
  now=$(date +%s)

  mkdir -p "$(dirname "$cache")"
  touch "$cache"

  local mtime
  mtime=$(stat -c %Y "$cache" 2>/dev/null || echo 0)
  local age=$((now - mtime))

  if [ "$age" -lt "$valid_for" ]; then
    cat "$cache"
    echo
    return
  fi

  {
    local tmpfile
    tmpfile="$(mktemp "${cache}.XXXXXX")"
    curl -s -A curl 'https://wttr.in/Moss?format=%C+%t' |
      sed 's/^[[:space:]]*//;s/[[:space:]]*$//' >"$tmpfile"

    if [ -s "$tmpfile" ]; then
      mv "$tmpfile" "$cache"
    else
      rm -f "$tmpfile"
    fi
  } &

  printf "☁️ loading...\n"
}

get_message() {
  local mode="$1"
  local rare_chance=$((RANDOM % 100))
  local style="\033[3m"
  local rune_color=""
  local message=""

  if [ -f "$TILDRAN_RARE_MESSAGE_FILE" ] && { [ "$mode" = "rare" ] || [ "$rare_chance" -eq 0 ]; }; then
    message=$(awk -v RS='------' 'BEGIN {srand()} {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0); blocks[NR]=$0} END {print blocks[int(1 + rand() * NR)]}' "$TILDRAN_RARE_MESSAGE_FILE")
    style="\033[1m\033[3m"
    rune_color="\033[38;5;220m"
  elif [ -f "$TILDRAN_MESSAGE_FILE" ]; then
    message=$(awk -v RS='------' 'BEGIN {srand()} {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0); blocks[NR]=$0} END {print blocks[int(1 + rand() * NR)]}' "$TILDRAN_MESSAGE_FILE")
  fi

  [ -z "$message" ] && message="Tildran greets you in silence."

  local rune_symbol=$(get_rune)
  printf "%b  %b%s\033[0m" "${rune_color}${rune_symbol}\033[0m" "$style" "$message"
}

# === Argument Parsing ===
MODE="all"
for arg in "$@"; do
  case "$arg" in
  --rare) MODE="rare" ;;
  esac
done

# === Beam and Info ===
i=0
for COLOR in "${COLORS[@]}"; do
  OFFSET=$((i * 1))
  BEAM_WIDTH=$((WIDTH - OFFSET))

  # Ensure at least one block width
  ((BEAM_WIDTH < 1)) && BEAM_WIDTH=1

  # Set color and render beam correctly
  printf "[38;5;%sm" "$COLOR"
  for ((j = 0; j < BEAM_WIDTH; j++)); do
    printf "%s" "$TILDRAN_BLOCK"
  done

  # Consistent spacing after beam
  PADDING=$((INFO_COL - BEAM_WIDTH))
  ((PADDING < 1)) && PADDING=1
  printf '%*s' "$PADDING" ''

  # Info lines (aligned neatly)
  case "$i" in
  0) printf "User:       %s@%s\n" "$(get_username)" "$(get_hostname)" ;;
  1) printf "Shell:      %s\n" "$(get_shell)" ;;
  4) printf "Uptime:     %s\n" "$(get_uptime)" ;;
  5) printf "Last login: %s\n" "$(get_last_login)" ;;
  2) printf "Memory:     %s\n" "$(get_mem)" ;;
  3) printf "CPU load:   %s\n" "$(get_cpu)" ;;
  6) printf "Weather:    %s\n" "$(get_weather)" ;;
  *) echo ;;
  esac

  # Reset color
  printf "\033[0m"
  ((i++))
  # sleep 0.03  # Disabled for instant prompt readiness
done

# === Handle special modes ===
MESSAGE=$(get_message $MODE)

# === Center Message ===
MESSAGE_COL=$(((TERM_COLS - ${#MESSAGE}) / 2))
printf "\n%s\n\n" "$MESSAGE"
