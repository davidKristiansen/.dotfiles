#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 David Kristiansen
#
# motd.sh — a small login banner: a colored beam, a few system facts, and a
# random message. Prints nothing on non-interactive or sub-256-color terminals.

# Skip non-interactive or non-color terminals
[ -t 1 ] || exit 0
[ "$(tput colors 2>/dev/null || echo 0)" -lt 256 ] && exit 0

# === Configuration ===
BLOCK="▀"            # beam glyph
WIDTH=10             # beam width on the first line (tapers by one per line)
INFO_COL=15          # column where the info text starts
COLORS=(160 166 178 142 109 139 175)  # one per info line, top to bottom

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/motd"
CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}/motd"
MESSAGE_FILE="$CONFIG_HOME/messages.txt"
RARE_MESSAGE_FILE="$CONFIG_HOME/rare_messages.txt"
WEATHER_URL="https://wttr.in/Moss?format=%C+%t"

# === Container identity ======================================================
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
  [ -f /.dockerenv ] || [ -f /run/.containerenv ] \
    || grep -q '/containers/[0-9a-f]\{64\}' /proc/1/mountinfo 2>/dev/null
}

# === System facts ============================================================
get_rune() {
  local runes=("🜁" "🜂" "🜃" "🜄" "🜅" "🜆" "🜇" "🜈" "🜉" "🜊" "🜋" "🜌" "🜍" "🜎" "🜏")
  echo "${runes[RANDOM % ${#runes[@]}]}"
}

get_uptime() { uptime -p | sed 's/^up //'; }
get_mem()    { free -h | awk '/^Mem:/ {print $3 "/" $2}'; }
get_cpu()    { uptime | awk -F'load average:' '{gsub(/^ /, "", $2); print $2}'; }

# Earliest login timestamp for $USER via systemd-logind (wtmp-free systems)
last_login_loginctl() {
  command -v loginctl >/dev/null 2>&1 || return 1
  local s cls ts best="" best_e cur_e
  while read -r s; do
    [ -n "$s" ] || continue
    cls=$(loginctl show-session "$s" -p Class --value 2>/dev/null)
    [ "$cls" = "user" ] || continue
    ts=$(loginctl show-session "$s" -p Timestamp --value 2>/dev/null)
    [ -n "$ts" ] || continue
    cur_e=$(date -d "$ts" +%s 2>/dev/null || echo 0)
    if [ -z "$best" ] || [ "$cur_e" -lt "${best_e:-0}" ]; then
      best="$ts"; best_e="$cur_e"
    fi
  done < <(loginctl list-sessions --no-legend 2>/dev/null | awk -v u="$USER" '$3==u {print $1}')
  [ -n "$best" ] || return 1
  date -d "$best" '+%a %Y-%m-%d %H:%M' 2>/dev/null
}

get_last_login_line() {
  if in_container; then
    printf 'Container:  %s' "$(container_id)"
    return
  fi
  # Host environment: attempt to print last login.
  # Prefer util-linux `last`; fall back to systemd-logind on wtmp-free hosts.
  local ll
  if command -v last >/dev/null 2>&1; then
    ll=$(last -1 "$USER" 2>/dev/null | awk 'NR==1 {printf "%s %s %s %s", $4, $5, $6, $7}')
  fi
  [ -n "$ll" ] || ll=$(last_login_loginctl)
  if [ -n "$ll" ]; then
    printf 'Last login: %s' "$ll"
  else
    printf 'Last login: (unknown)'
  fi
}

# Non-blocking weather: prints cached text (nothing if cache is cold) and kicks
# off a detached refresh when the cache is missing or older than 15 minutes.
get_weather() {
  local cache="$CACHE_HOME/weather.cache"
  local valid_for=$((15 * 60))
  local now mtime age
  now=$(date +%s)
  mkdir -p "$CACHE_HOME"

  mtime=$(stat -c %Y "$cache" 2>/dev/null || echo 0)
  age=$((now - mtime))

  if [ "$age" -lt "$valid_for" ] && [ -s "$cache" ]; then
    tr -d '\n' < "$cache"
    return 0
  fi

  # Background updater; prints no placeholder.
  (
    tmpfile="$(mktemp "$CACHE_HOME/weather.cache.XXXXXX")" || exit 0
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

# === Message =================================================================
# Picks a random block (records separated by "------") from the message file,
# occasionally (1%) or on demand (--rare) from the rare file.
get_message() {
  local mode="${1:-}"
  local rare_chance=$((RANDOM % 100))
  local style="\033[3m"
  local rune_color=""
  local message=""

  local pick='BEGIN {srand()} {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0); blocks[NR]=$0} END {print blocks[int(1 + rand() * NR)]}'

  if [ -f "$RARE_MESSAGE_FILE" ] && { [ "$mode" = "rare" ] || [ "$rare_chance" -eq 0 ]; }; then
    message=$(awk -v RS='------' "$pick" "$RARE_MESSAGE_FILE")
    style="\033[1m\033[3m"
    rune_color="\033[38;5;220m"
  elif [ -f "$MESSAGE_FILE" ]; then
    message=$(awk -v RS='------' "$pick" "$MESSAGE_FILE")
  fi

  [ -z "$message" ] && message="The terminal greets you in silence."

  printf "%b  %b%s\033[0m" "${rune_color}$(get_rune)\033[0m" "$style" "$message"
}

# === Render ==================================================================
# Print one beam line: colored bar tapering by `idx`, padding, then info text.
render_line() {
  local idx="$1" text="$2"
  local beam=$((WIDTH - idx)); ((beam < 1)) && beam=1
  local pad=$((INFO_COL - beam)); ((pad < 1)) && pad=1
  local bar
  printf -v bar '%*s' "$beam" ''
  bar=${bar// /$BLOCK}
  printf '\033[38;5;%sm%s%*s%s\033[0m\n' "${COLORS[idx]}" "$bar" "$pad" '' "$text"
}

# Argument parsing
MODE="all"
for arg in "$@"; do
  case "$arg" in
    --rare) MODE="rare" ;;
  esac
done

# Assemble info lines (weather only when a cached value exists).
WEATHER_TEXT=$(get_weather)
INFO=(
  "User:       $(whoami)@$(container_id)"
  "Shell:      $SHELL"
  "Memory:     $(get_mem)"
  "CPU load:   $(get_cpu)"
  "Uptime:     $(get_uptime)"
  "$(get_last_login_line)"
)
[ -n "$WEATHER_TEXT" ] && INFO+=("Weather:    $WEATHER_TEXT")

for i in "${!INFO[@]}"; do
  render_line "$i" "${INFO[i]}"
done

# Message (left-aligned, blank line above and below)
printf "\n%s\n\n" "$(get_message "$MODE")"
