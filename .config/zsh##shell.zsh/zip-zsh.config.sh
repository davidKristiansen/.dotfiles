#!/usr/bin/env bash

# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

set -euo pipefail

# Determine cache dir (prefer XDG, fallback to ~/.cache)
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
OUTDIR="$CACHE_DIR/zsh-zip"
mkdir -p "$OUTDIR"

ZIP_NAME="zsh-config.zip"
ZIP_PATH="$OUTDIR/$ZIP_NAME"

TMP_LIST="$(mktemp)"
trap 'rm -f "$TMP_LIST"' EXIT

INCLUDES=(
  "$HOME/.zshenv"
  "$HOME/.config/zsh/"
  "$HOME/.config/environment.d/"
)

for path in "${INCLUDES[@]}"; do
  if [[ -e "$path" ]]; then
    realpath --relative-to="$HOME" "$path" >>"$TMP_LIST"
  fi
done

cd "$HOME"
zip -r "$ZIP_PATH" -@ <"$TMP_LIST" >/dev/null

echo "✅ Created $ZIP_PATH with:"
cat "$TMP_LIST"
