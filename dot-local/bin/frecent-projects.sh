#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

# Extract project paths from zoxide and sort them by recency *dominance*, score as tie-breaker

root_markers=(
  .git .tmux-session-name .project
  package.json lazy-lock.json yarn.lock
  pyproject.toml setup.py
  Cargo.toml Makefile CMakeLists.txt
  .nvimrc .nvim init.lua
  .env .venv requirements.txt
)

is_project_dir() {
  local dir=$1
  for marker in "${root_markers[@]}"; do
    if [[ -e "$dir/$marker" ]]; then
      return 0
    fi
  done
  return 1
}

zoxide query -ls | while read -r score path; do
  if is_project_dir "$path"; then
    mtime=$(stat -c %Y "$path" 2>/dev/null || echo 0)
    final_score=$(awk -v s="$score" -v m="$mtime" 'BEGIN { printf "%.0f", (m * 1e9) + s }')
    printf "%s\t%s\n" "$final_score" "$path"
  fi
done | sort -rn | cut -f2-
