# deduce dotfiles dir
if [ -d $HOME/dotfiles ]; then
  export DOT_DIR=$HOME/dotfiles
else
  export DOT_DIR=$HOME/.dotfiles
fi

(
  setopt LOCAL_OPTIONS NO_NOTIFY NO_MONITOR
  {
    cd "${DOT_DIR}"
    updated=$(dotfiles pull | \grep -v "Already up to date." 2>/dev/null)
    if [ ! -z "${updated}" ]; then
      echo $updated
      echo Hold on to your bootstraps
      ./bootstrap
    fi
    wait
  } &
)
