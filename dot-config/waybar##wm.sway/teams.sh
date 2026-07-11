#!/usr/bin/env sh
# ─────────────────────────────────────────────────────────────────────────────
#  Waybar custom module — teams-for-linux presence via MQTT
# ─────────────────────────────────────────────────────────────────────────────
#  teams-for-linux publishes its presence + call state to the local mosquitto
#  broker (the same broker that feeds Home Assistant). This script subscribes to
#  every retained `teams/*` topic and emits one line of Waybar JSON per change,
#  so the bar reflects Teams status without the SNI tray icon.
#
#  Topics (all retained):
#    teams/status         JSON {"status":"available|busy|do_not_disturb|away|
#                                        be_right_back|unknown", ...}
#    teams/connected      "true"|"false"   — is teams-for-linux running (LWT)
#    teams/in-call        "true"|"false"
#    teams/incoming-call  "true"|"false"
#    teams/camera         "true"|"false"
#    teams/screen-sharing "true"|"false"
#    teams/microphone     raw state string
#
#  Continuous module: run once, never exits. Reconnects itself if the broker
#  goes away; retained messages repopulate full state on every (re)subscribe.
# ─────────────────────────────────────────────────────────────────────────────

BROKER="${TEAMS_MQTT_BROKER:-localhost}"
PORT="${TEAMS_MQTT_PORT:-1883}"
PREFIX="${TEAMS_MQTT_PREFIX:-teams}"

# ── module state (repopulated from retained topics on each subscribe) ─────────
reset_state() {
  status="unknown"; connected="false"
  incall="false"; incoming="false"
  cam="false"; screen="false"; mic=""
}

# JSON string escaper for tooltip text (escapes \, ", and newlines).
esc() {
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g'
}

emit() {
  # Not running → dimmed "Offline".
  if [ "$connected" != "true" ]; then
    printf '{"text":"Offline","alt":"offline","class":"offline","tooltip":"Teams — not running"}\n'
    return
  fi

  case "$status" in
    available)      label="Available";      cls="available" ;;
    busy)           label="Busy";           cls="busy" ;;
    do_not_disturb) label="Do not disturb"; cls="dnd" ;;
    away)           label="Away";           cls="away" ;;
    be_right_back)  label="Be right back";  cls="brb" ;;
    *)              label="Unknown";        cls="unknown" ;;
  esac

  tip="Teams — $label"

  # Call state overrides the presence label (incoming blinks via CSS).
  if [ "$incoming" = "true" ]; then
    label="Incoming call"; cls="incoming-call"; tip="Teams — incoming call…"
  elif [ "$incall" = "true" ]; then
    tip="Teams — in a call ($label)"
    label="In call"; cls="in-call"
    [ -n "$mic" ]          && tip="$tip
 mic: $mic"
    [ "$cam" = "true" ]    && tip="$tip
 camera on"
    [ "$screen" = "true" ] && tip="$tip
 sharing screen"
  fi

  printf '{"text":"%s","alt":"%s","class":"%s","tooltip":"%s"}\n' \
    "$label" "$status" "$cls" "$(esc "$tip")"
}

# ── main loop: subscribe, react to each message, reconnect on drop ────────────
while true; do
  reset_state
  emit  # show current best-guess (offline) until retained state arrives

  # -v → "topic payload"; payload is the remainder of the line (may contain the
  # JSON blob). mosquitto_sub stays connected until the broker drops it.
  mosquitto_sub -h "$BROKER" -p "$PORT" -t "$PREFIX/#" -v 2>/dev/null |
  while read -r topic payload; do
    case "$topic" in
      "$PREFIX/status")
        # pull "status":"<value>" out of the JSON payload
        status=$(printf '%s' "$payload" | sed -n 's/.*"status":"\([a-z_]*\)".*/\1/p')
        [ -z "$status" ] && status="unknown" ;;
      "$PREFIX/connected")      connected="$payload" ;;
      "$PREFIX/in-call")        incall="$payload" ;;
      "$PREFIX/incoming-call")  incoming="$payload" ;;
      "$PREFIX/camera")         cam="$payload" ;;
      "$PREFIX/screen-sharing") screen="$payload" ;;
      "$PREFIX/microphone")     mic="$payload" ;;
      *) continue ;;
    esac
    emit
  done

  # Broker went away (or was never up). Show offline and retry shortly.
  connected="false"; emit
  sleep 5
done
