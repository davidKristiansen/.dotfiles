#!/usr/bin/env bash
# ~/.local/bin/link_handler.sh
set -Eeuo pipefail

LOG="${XDG_CACHE_HOME:-$HOME/.cache}/teams-url.log"
mkdir -p "$(dirname "$LOG")"
ts(){ date +'%F %T'; }
log(){ echo "$(ts) $*" >>"$LOG"; }

# Your exact trunk regex (Bash regex, not sed): ^https://.*/svn/repos/.*/trunk/.*
SVN_TRUNK_RE='^https://.*/svn/repos/.*/trunk/.*'

# pick first URL-y arg (Teams sometimes passes extra)
pick_url() {
  for a in "$@"; do
    case "$a" in
      http://*|https://*|svn://*|svn+ssh://*|file://*|mailto:*|tel:*) printf '%s' "$a"; return 0;;
    esac
  done
  return 1
}

log "args=$* PPID=$PPID"
url="$(pick_url "$@")" || { log "no_url_found"; exit 0; }

# trim stray trailing punct from chat clients
url="${url%%[),.]}"
log "url=$url"

# route by your regex
if [[ "$url" =~ $SVN_TRUNK_RE ]]; then
  log "route=svn-nav match=SVN_TRUNK_RE"
  exec "$HOME/.local/bin/svn-nav" "$url"
fi

# default: detached system opener
log "route=xdg-open"
exec setsid -f xdg-open "$url" >/dev/null 2>&1

