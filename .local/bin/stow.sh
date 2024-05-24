#!/usr/bin/env bash

pushd () {
  command pushd "$@" > /dev/null
}
popd () {
  command popd > /dev/null
}

force=false

usage () {
  echo $(basename $0) [dtfiSDh] DIR
  exit $1
}

OPTSTRING="hd:t:fi:S:D:"

while getopts ${OPTSTRING} opt; do
  case $opt in
    d) dir=$OPTARG                 ;;
    t) target=$OPTARG              ;;
    f) force=true                  ;;
    i) ignore+=("$OPTARG")         ;;
    S) stow_targets+=("$OPTARG")   ;;
    D) unstow_targets+=("$OPTARG") ;;
    h) usage                       ;;
    ?) usage 1                     ;;
  esac
done
shift $(expr $OPTIND - 1 )

if [ $# -gt 1 ]; then
  usage 1
elif [ $# -eq 1 ]; then
  dir=$1
fi

if [[ -z $ignore ]]; then
  ignore=(".git" "bootstrap")
fi
if [[ -z $dir ]]; then
  dir=$(pwd)
else
  dir="$(realpath "$dir")"
fi
if [[ -z $target ]]; then
  target="$(dirname "$dir")"
else
  target="$(realpath "$target")"
fi

contains () {
  val=$1
  shift
  arr=("$@")
  if [[ " ${arr[*]} " =~ [[:space:]]"$val"[[:space:]] ]]; then
    true
  else
    false
  fi
}

walk_dir () {
  shopt -s nullglob dotglob

  for stow_candidate in "$1"/*; do
    base="${stow_candidate#"$dir"/}"
    target_path="$target/$base"
    stow_candidate="$stow_candidate"

    if contains $base "${ignore[@]}"; then
      continue
    fi

    if [ -f "$stow_candidate" ]; then
      stow_targets+=("$base")
      continue
    fi
    if [ -L "$target_path" ]; then
      stow_targets+=("$base")
      continue
    fi

    if [ ! -d "$target_path" ]; then
      stow_targets+=("$base")
      continue
    fi

    walk_dir $stow_candidate
  done
}

remove_symlink() {
    if [[ ! -L "$1" ]]; then
      echo \"$1\" does not exist or is not a symlink
      return 1
    fi
    rm "$1"
    echo \"$1\" removed
    return 0
}

unstow () {
  for candidate in $@; do
    target_path="$target/$candidate"
    remove_symlink "$target_path"
  done
}

stow () {
  for candidate in $@; do

    target_path="$target/$candidate"
    stow_path="$dir/$candidate"

    if [[ ! -e "$stow_path" ]]; then
      echo \"$stow_path\" not a stowable object!
      continue
    fi

    if [[ -e "$target_path" ]]; then
      if [[ $force == false ]]; then
        echo "$target_path" already exist. Use the \"\(-f\)orce\"
        continue
      fi
      unstow $candidate
      if [[ $? != 0 ]]; then
        continue
      fi
    fi

    target_dir="$(dirname $target_path)"
    stow_dir="$(dirname $stow_path)"
    relative_path=$(realpath -s --relative-to="$target_dir" "$stow_path")

    mkdir -p $target_dir
    pushd $target_dir
      ln -s "$relative_path" .
    popd
    echo "$target_path -> $relative_path"

  done
}

if [[ -z $stow_targets ]]; then
  walk_dir $dir
fi
stow "${stow_targets[@]}"


if [[ ! -z $unstow_targets ]]; then
  unstow "${unstow_targets[@]}"
fi

# >&2 cat << EOF
# stow_targets=${stow_targets[*]}
# dir=$dir
# target=$target
# force=$force
# ignore=${ignore[*]}
# stow=${stow[*]}
# delete=${delete[*]}
# EOF
