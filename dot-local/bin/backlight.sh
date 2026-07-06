#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright David Kristiansen
#
# Control internal laptop brightness and external DDC/CI monitor brightness together.
# External monitor is the source of truth / tie breaker.
# Also manages wluma auto-brightness (auto/manual mode toggle).

set -euo pipefail

INTERNAL_DEVICE="${INTERNAL_DEVICE:-intel_backlight}"
EXTERNAL_BUS="${EXTERNAL_BUS:-12}"
STEP="${STEP:-5}"
MIN_BRIGHTNESS="${MIN_BRIGHTNESS:-1}"
MAX_BRIGHTNESS="${MAX_BRIGHTNESS:-100}"
DDC_SLEEP="${DDC_SLEEP:-.4}"    # I2C sleep multiplier (lower = faster, raise if unreliable)

DDCUTIL="${DDCUTIL:-ddcutil}"
BRIGHTNESSCTL="${BRIGHTNESSCTL:-brightnessctl}"

# Common ddcutil flags — applied to every call for speed.
DDC_OPTS=(--bus "$EXTERNAL_BUS" --sleep-multiplier "$DDC_SLEEP")

# Cache file for the DDC max-brightness value (static per monitor).
DDC_MAX_CACHE="/tmp/backlight-ddc-max-bus${EXTERNAL_BUS}"

# Lock file for background DDC writes (prevents piling up).
DDC_WRITE_LOCK="/tmp/backlight-ddc-write.lock"

# Lock file for brightness commands (prevents scroll-event pile-up).
BRIGHTNESS_LOCK="/tmp/backlight.sh.lock"

usage() {
  cat <<EOF
Usage:
  $(basename "$0") get
  $(basename "$0") sync
  $(basename "$0") set PERCENT
  $(basename "$0") up [STEP]
  $(basename "$0") down [STEP]
  $(basename "$0") mode          Waybar JSON: current auto/manual state
  $(basename "$0") toggle        Toggle between auto (wluma) and manual
  $(basename "$0") auto          Start wluma.service
  $(basename "$0") manual        Stop wluma.service

Environment:
  INTERNAL_DEVICE   default: intel_backlight
  EXTERNAL_BUS      default: 12
  STEP              default: 5
  MIN_BRIGHTNESS    default: 1
  MAX_BRIGHTNESS    default: 100
  DDC_SLEEP         default: .4  (I2C sleep multiplier; raise if DDC/CI is unreliable)

Examples:
  $(basename "$0") get
  $(basename "$0") set 60
  $(basename "$0") up
  $(basename "$0") toggle

Sway:
  bindsym XF86MonBrightnessUp exec ~/.local/bin/backlight.sh up
  bindsym XF86MonBrightnessDown exec ~/.local/bin/backlight.sh down
EOF
}

# ── Auto-brightness (wluma, runs as the wluma.service user unit) ─────────────

is_auto() { systemctl --user is-active --quiet wluma.service; }

mode_json() {
  if is_auto; then
    printf '{"text":"󰃝","tooltip":"Brightness: auto (wluma)","class":"auto","alt":"auto"}\n'
  else
    printf '{"text":"󰃠","tooltip":"Brightness: manual","class":"manual","alt":"manual"}\n'
  fi
}

start_auto() {
  systemctl --user start wluma.service
}

stop_auto() {
  systemctl --user stop wluma.service
}

toggle_mode() {
  if is_auto; then stop_auto; else start_auto; fi
  pkill -RTMIN+10 waybar 2>/dev/null || true   # refresh waybar module
}

# ── Acquire flock for brightness commands only ───────────────────────────────
# Mode/toggle commands are instant and must never be blocked.
lock_brightness() {
  exec 9>"$BRIGHTNESS_LOCK"
  flock -n 9 || exit 0    # another instance is running → silently bail
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing command: $1"
}

clamp() {
  local value="$1"

  if (( value < MIN_BRIGHTNESS )); then
    value="$MIN_BRIGHTNESS"
  elif (( value > MAX_BRIGHTNESS )); then
    value="$MAX_BRIGHTNESS"
  fi

  printf '%s\n' "$value"
}

# Return the cached DDC max value, or read + cache it on first call.
get_ddc_max() {
  if [[ -f "$DDC_MAX_CACHE" ]]; then
    cat "$DDC_MAX_CACHE"
    return
  fi

  local current max
  read -r current max < <(get_external_raw)
  (( max > 0 )) || die "external monitor reported invalid max brightness: $max"
  printf '%s' "$max" > "$DDC_MAX_CACHE"
  printf '%s\n' "$max"
}

# Compute the raw DDC value from a percent, with a floor of 1 to prevent
# turning off the monitor.
percent_to_raw() {
  local percent="$1" max="$2" raw
  raw=$(( (percent * max + 50) / 100 ))
  (( raw >= 1 )) || raw=1
  printf '%s\n' "$raw"
}

# Fire a ddcutil setvcp in the background.  Releases the main flock so the
# next scroll-tick isn't blocked.  Uses its own lock to prevent pile-up.
ddc_write_bg() {
  local raw="$1"
  (
    exec 9>&-                             # release main flock in child
    exec 8>"$DDC_WRITE_LOCK"
    flock -n 8 || exit 0                   # another write is in-flight → skip
    "$DDCUTIL" "${DDC_OPTS[@]}" --noverify setvcp 10 "$raw" >/dev/null 2>&1
  ) &
  disown
}

get_external_raw() {
  local line
  # --brief output: "VCP 10 C <current> <max>" — no sed needed.
  line=$("$DDCUTIL" "${DDC_OPTS[@]}" --brief getvcp 10 2>/dev/null) || {
    die "failed to read external brightness on /dev/i2c-${EXTERNAL_BUS}"
  }

  local -a parts=($line)
  [[ ${#parts[@]} -ge 5 ]] || die "could not parse ddcutil output: $line"

  printf '%s %s\n' "${parts[3]}" "${parts[4]}"
}

get_external_percent() {
  local current max
  read -r current max < <(get_external_raw)

  (( max > 0 )) || die "external monitor reported invalid max brightness: $max"

  printf '%s\n' "$(( (current * 100 + max / 2) / max ))"
}

get_internal_percent() {
  "$BRIGHTNESSCTL" -m -d "$INTERNAL_DEVICE" \
    | awk -F, '{ gsub("%", "", $4); print $4 }'
}

set_internal_percent() {
  local percent
  percent="$(clamp "$1")"

  "$BRIGHTNESSCTL" -q -d "$INTERNAL_DEVICE" set "${percent}%"
}

set_external_percent() {
  local percent max raw
  percent="$(clamp "$1")"
  max="$(get_ddc_max)"
  raw="$(percent_to_raw "$percent" "$max")"

  "$DDCUTIL" "${DDC_OPTS[@]}" --noverify setvcp 10 "$raw" >/dev/null
}

set_both_percent() {
  local percent
  percent="$(clamp "$1")"

  # External is the tie breaker, but for an explicit target both get the same value.
  set_external_percent "$percent"
  set_internal_percent "$percent"
}

show_status() {
  local external internal
  external="$(get_external_percent)"
  internal="$(get_internal_percent)"

  printf 'external: %s%%\n' "$external"
  printf 'internal: %s%%\n' "$internal"
}

sync_from_external() {
  local external
  external="$(get_external_percent)"

  set_internal_percent "$external"

  printf 'synced internal to external: %s%%\n' "$external"
}

adjust_brightness() {
  local delta internal target max raw
  delta="$1"

  # Read internal (instant sysfs) instead of slow DDC/CI read.
  internal="$(get_internal_percent)"
  target="$(clamp "$(( internal + delta ))")"

  # Set internal immediately — user sees instant feedback.
  "$BRIGHTNESSCTL" -q -d "$INTERNAL_DEVICE" set "${target}%"

  # Set external in the background — don't block on slow I2C.
  max="$(get_ddc_max)"
  raw="$(percent_to_raw "$target" "$max")"
  ddc_write_bg "$raw"
}

main() {
  local command="${1:-}"
  shift || true

  # Mode/toggle commands are instant — no flock, no dependency checks.
  case "$command" in
    mode)    mode_json;   return ;;
    toggle)  toggle_mode; return ;;
    auto)    start_auto;  return ;;
    manual)  stop_auto;   return ;;
  esac

  # Everything below touches hardware — lock and check dependencies.
  need_cmd "$DDCUTIL"
  need_cmd "$BRIGHTNESSCTL"
  lock_brightness

  case "$command" in
    get | status)
      show_status
      ;;

    sync)
      sync_from_external
      ;;

    set)
      [[ $# -eq 1 ]] || die "set requires PERCENT"
      [[ "$1" =~ ^[0-9]+$ ]] || die "PERCENT must be an integer"
      set_both_percent "$1"
      printf 'set both to: %s%%\n' "$(clamp "$1")"
      ;;

    up | +)
      local step="${1:-$STEP}"
      [[ "$step" =~ ^[0-9]+$ ]] || die "STEP must be an integer"
      adjust_brightness "$step"
      ;;

    down | -)
      local step="${1:-$STEP}"
      [[ "$step" =~ ^[0-9]+$ ]] || die "STEP must be an integer"
      adjust_brightness "-$step"
      ;;

    -h | --help | help)
      usage
      ;;

    *)
      usage >&2
      exit 2
      ;;
  esac
}

main "$@"
