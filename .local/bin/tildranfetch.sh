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
TILDRAN_XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}/tildran"
TILDRAN_MESSAGE_FILE="$TILDRAN_XDG_CONFIG_HOME/tildran_messages.txt"
TILDRAN_RARE_MESSAGE_FILE="$TILDRAN_XDG_CONFIG_HOME/tildran_rare_messages.txt"
WEATHER_URL="https://wttr.in/Moss?format=%C+%t"

COLORS=(160 166 178 142 109 139 175)
TERM_COLS=$(tput cols 2>/dev/null || echo 80)
((TERM_COLS < 40)) && TERM_COLS=80
WIDTH=10
INFO_COL=$TILDRAN_INFO_COL

# --- ANSI helpers ------------------------------------------------------------
ansi_strip() {
  # Strip CSI and OSC escape sequences
  sed -E 's/\x1B\[[0-9;?]*[ -/]*[@-~]//g; s/\x1B\][0-9]*;.*(\x07|\x1B\\)//g'
}

strlen_nocolor() {
  # Visible char count across all lines (collapse newlines to one string)
  local s
  s=$(printf '%s' "$1" | ansi_strip | tr -d '\n')
  printf '%s' "$s" | wc -m | tr -d ' '
}

# --- Container identity ------------------------------------------------------
# Returns: Podman name, or Docker short 12-char ID, else full hostname
container_id() {
  local id name

  # Podman: readable name
  if [ -f /run/.containerenv ]; then
    name=$(grep -E '^name=' /run/.containerenv 2>/dev/null | head -n1 | cut -d= -f2-)
    if [ -n "$name" ]; then
      printf '%s\n' "$name"
      return 0
    fi
  fi

  # Docker-ish: 64-hex ID in mountinfo paths
  id=$(\
    grep -oE '/containers/([0-9a-f]{64})' /proc/1/mountinfo 2>/dev/null \
      | head -n1 | sed 's#.*/##'\
  )
  if [ -n "$id" ]; then
    printf '%.12s\n' "$id"
    return 0
  fi

  # Hostname might already be a short ID
  if grep -qE '^[0-9a-f]{12}$' /etc/hostname 2>/dev/null; then
    head -c 12 /etc/hostname; echo
    return 0
  fi

  # Final fallback
  cat /etc/hostname
}

in_container() {
  [ -f /.dockerenv ] || [ -f /run/.containerenv ] || grep -q '/containers/[0-9a-f]\{64\}' /proc/1/mountinfo 2>/dev/null
}

# === Helper Functions ===
get_rune() {
  local runes=("🜁" "🜂" "🜃" "🜄" "🜅" "🜆" "🜇" "🜈" "🜉" "🜊" "🜋" "🜌" "🜍" "🜎" "🜏")
  echo "${runes[RANDOM % ${#runes[@]}]}"
}

get_username() { whoami; }
get_hostname() { container_id; }
get_shell() { echo "$SHELL"; }
get_uptime() { uptime -p | sed 's/^up //'; }

get_last_login_line() {
  if in_container; then
    printf 'Container:  %s' "$(container_id)"
    return
  fi
  # Host environment: attempt to print last login
  local ll
  ll=$(last -1 "$USER" 2>/dev/null | awk 'NR==1 {printf "%s %s %s %s", $4, $5, $6, $7}')
  if [ -n "$ll" ]; then
    printf 'Last login: %s' "$ll"
  else
    printf 'Last login: (unknown)'
  fi
}

get_mem() { free -h | awk '/^Mem:/ {print $3 "/" $2}'; }
get_cpu() { uptime | awk -F'load average:' '{gsub(/^ /, "", $2); print $2}'; }

# Non-blocking weather with cache + detached updater
get_weather() {
  # Return cached weather text if available; start async refresh if stale/missing.
  # Does NOT print placeholders. Prints nothing if cache cold.
  local cache_dir="$TILDRAN_XDG_CACHE_HOME"
  local cache="$cache_dir/weather.cache"
  local valid_for=$((15 * 60)) # 15 minutes
  local now mtime age
  now=$(date +%s)
  mkdir -p "$cache_dir"

  mtime=$(stat -c %Y "$cache" 2>/dev/null || echo 0)
  age=$((now - mtime))

  # If cache is valid, print and return
  if [ "$age" -lt "$valid_for" ] && [ -s "$cache" ]; then
    tr -d '
' < "$cache"
    return 0
  fi

  # Kick off background updater but do NOT print any placeholder
  (
    tmpfile="$(mktemp "$cache_dir/weather.cache.XXXXXX")" || exit 0
    curl -s -A curl "$WEATHER_URL" \
      | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' >"$tmpfile"
    if [ -s "$tmpfile" ]; then
      mv -f "$tmpfile" "$cache"
    else
      rm -f "$tmpfile"
    fi
  ) </dev/null >/dev/null 2>&1 & disown

  return 0
}


get_message() {
  local mode="${1:-}"
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

  local rune_symbol
  rune_symbol=$(get_rune)
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
# Pre-fetch weather text (empty if cache cold); updater runs in background.
WEATHER_TEXT=$(get_weather)
i=0
for COLOR in "${COLORS[@]}"; do
  # If this is the weather line and we don't have cached data, skip this line entirely
  if [ "$i" -eq 6 ] && [ -z "${WEATHER_TEXT}" ]; then
    ((i++))
    continue
  fi
  OFFSET=$((i * 1))
  BEAM_WIDTH=$((WIDTH - OFFSET))
  ((BEAM_WIDTH < 1)) && BEAM_WIDTH=1

  # Set color and render beam
  printf "\033[38;5;%sm" "$COLOR"
  for ((j = 0; j < BEAM_WIDTH; j++)); do
    printf "%s" "$TILDRAN_BLOCK"
  done

  # Padding after beam
  PADDING=$((INFO_COL - BEAM_WIDTH))
  ((PADDING < 1)) && PADDING=1
  printf '%*s' "$PADDING" ''

  # Info lines
  case "$i" in
    0) printf "User:       %s@%s\n" "$(get_username)" "$(get_hostname)" ;;
    1) printf "Shell:      %s\n" "$(get_shell)" ;;
    2) printf "Memory:     %s\n" "$(get_mem)" ;;
    3) printf "CPU load:   %s\n" "$(get_cpu)" ;;
    4) printf "Uptime:     %s\n" "$(get_uptime)" ;;
    5) printf "%s\n" "$(get_last_login_line)" ;;
    6) printf "Weather:    %s
" "${WEATHER_TEXT}" ;;
    *) echo ;;
  esac

  # Reset color
  printf "\033[0m"
  ((i++))

done

# === Message (left-aligned) ===
MESSAGE=$(get_message "$MODE")
printf "\n%s\n\n" "$MESSAGE"

