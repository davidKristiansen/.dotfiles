# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

# Deduce dotfiles directory
if [ -d "$HOME/dotfiles" ]; then
  export DOT_DIR="$HOME/dotfiles"
else
  export DOT_DIR="$HOME/.dotfiles"
fi

# Pull dotfiles and run bootstrap (in background)
(
  setopt LOCAL_OPTIONS NO_NOTIFY NO_MONITOR
  {
    cd "$DOT_DIR"
    updated=$(\git -C "${DOT_DIR}" pull | \grep -v "Already up to date." 2>/dev/null)
    if [ -n "$updated" ]; then
      echo "$updated"
      echo "Hold on to your bootstraps"
      ./bootstrap
    fi
    wait
  } &
)
