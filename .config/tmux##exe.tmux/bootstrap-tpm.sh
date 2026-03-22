#!/bin/bash
# SPDX-License-Identifier: MIT
# Reliable TPM bootstrapping script

set -e

# Determine plugin directory
if [ -n "$XDG_DATA_HOME" ]; then
  TPM_PATH="$XDG_DATA_HOME/tmux/plugins"
else
  TPM_PATH="$HOME/.local/share/tmux/plugins"
fi

TPM_REPO="https://github.com/tmux-plugins/tpm.git"
TPM_DIR="$TPM_PATH/tpm"

# Create directory if it doesn't exist
mkdir -p "$TPM_PATH" || {
  echo "[tpm] Error: Could not create plugin directory: $TPM_PATH" >&2
  exit 1
}

# Check if tpm is already installed
if [ -d "$TPM_DIR" ]; then
  # Update existing tpm installation
  if git -C "$TPM_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    git -C "$TPM_DIR" pull origin master > /dev/null 2>&1 || true
  fi
else
  # Clone tpm with retry logic
  if git clone "$TPM_REPO" "$TPM_DIR" > /dev/null 2>&1; then
    :  # Silent success
  else
    echo "[tpm] Error: Failed to clone TPM from $TPM_REPO" >&2
    exit 1
  fi
fi

# Verify tpm installation
if [ ! -f "$TPM_DIR/tpm" ]; then
  echo "[tpm] Error: TPM installation incomplete - tpm script not found at $TPM_DIR/tpm" >&2
  exit 1
fi

exit 0
