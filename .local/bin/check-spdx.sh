#!/usr/bin/env bash

# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
LICENSE="MIT"
NAME="David Kristiansen"
HEADER="SPDX-License-Identifier: $LICENSE\nCopyright $NAME"

EXTENSIONS=("sh" "lua" "vim" "zsh" "bash" "py" "js" "ts" "json" "toml" "yml" "yaml" "conf")

# Comment style per file extension
declare -A COMMENT_MAP=(
  [sh]="#" [bash]="#" [zsh]="#" [lua]="--" [vim]="\""
  [py]="#" [js]="//" [ts]="//" [json]="//" [toml]="#"
  [yml]="#" [yaml]="#" [conf]="#"
)

# Flags
COLOR_MODE="auto"
FIX=false
DRY_RUN=false

# Helpers for colorized output
tput_color() {
  [[ -t 1 ]] || return 1
  tput setaf "$1"
}
style() {
  local code="$1"
  shift
  [[ $COLOR_MODE == never ]] && {
    echo "$*"
    return
  }
  [[ $COLOR_MODE == always || -t 1 ]] && printf "\033[${code}m%s\033[0m" "$*" || echo "$*"
}

# Parse CLI args
while [[ $# -gt 0 ]]; do
  case "$1" in
  --fix) FIX=true ;;
  --dry-run) DRY_RUN=true ;;
  --color=*) COLOR_MODE="${1#*=}" ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
  shift
done

MISSING=()

for ext in "${EXTENSIONS[@]}"; do
  while IFS= read -r -d '' file; do
    [[ "$file" == *"node_modules"* || "$file" == *.min.* ]] && continue

    if ! grep -q "SPDX-License-Identifier" "$file"; then
      MISSING+=("$file")
      if $FIX; then
        comment="${COMMENT_MAP[$ext]:-}"
        if [[ -n "$comment" ]]; then
          if $DRY_RUN; then
            echo "$(style 1\;33 "[dry-run]") Would fix: $file"
          else
            tmpfile=$(mktemp)
            {
              echo "$comment SPDX-License-Identifier: $LICENSE"
              echo "$comment Copyright $NAME"
              echo
              cat "$file"
            } >"$tmpfile"
            mv "$tmpfile" "$file"
            echo "$(style 1\;32 "[fixed]") $file"
          fi
        fi
      fi
    fi
  done < <(find "$REPO_ROOT" -type f -name "*.${ext}" -print0)
done

if [[ ${#MISSING[@]} -eq 0 ]]; then
  echo "$(style 1\;32 "✔") All files have SPDX headers"
else
  if ! $FIX; then
    echo "$(style 1\;31 "✘") Missing SPDX headers in:"
    printf "  - %s\n" "${MISSING[@]}"
    exit 1
  fi
fi
