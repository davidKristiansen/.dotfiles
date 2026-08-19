#!/bin/bash
# Claude Code status line.
#
# Shows, in order: the model display name, the basename of the session's
# working directory, the git repo identity and state for that directory
# (toplevel basename, branch or DETACHED@<sha>), and a dirty indicator
# (+staged ~unstaged/untracked) when the tree is not clean.
#
# Never `cd` - the user's zsh chpwd hook errors on `cd`. Always use `git -C`
# so the report matches the session's cwd, not the shell's cwd.

input=$(cat)

if command -v jq >/dev/null 2>&1; then
  model=$(printf '%s' "$input" | jq -r '.model.display_name // empty')
  cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
else
  extract_field() {
    printf '%s' "$input" |
      grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" |
      head -n 1 |
      sed -E 's/.*:[[:space:]]*"([^"]*)"/\1/'
  }
  model=$(extract_field display_name)
  cwd=$(extract_field current_dir)
  [ -z "$cwd" ] && cwd=$(extract_field cwd)
fi

[ -z "$model" ] && model="Claude"
[ -z "$cwd" ] && cwd="$PWD"

dir_base=$(basename -- "$cwd")

out="$model | $dir_base"

toplevel=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)

if [ -n "$toplevel" ]; then
  repo_base=$(basename -- "$toplevel")

  branch=$(git -C "$cwd" symbolic-ref --short -q HEAD 2>/dev/null)
  if [ -z "$branch" ]; then
    sha=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
    branch="DETACHED@${sha:-unknown}"
  fi

  out="$out | $repo_base:$branch"

  staged=0
  unstaged=0
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    x=${line:0:1}
    y=${line:1:1}
    if [ "$x" != " " ] && [ "$x" != "?" ]; then
      staged=$((staged + 1))
    fi
    if [ "$y" != " " ] || [ "$x" = "?" ]; then
      unstaged=$((unstaged + 1))
    fi
  done <<EOF
$(git -C "$cwd" status --porcelain 2>/dev/null)
EOF

  if [ "$staged" -gt 0 ] || [ "$unstaged" -gt 0 ]; then
    out="$out +$staged ~$unstaged"
  fi
fi

printf '%s' "$out"
