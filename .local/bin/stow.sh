#!/usr/bin/env bash

# set -euo pipefail

dir="."
target=".."
force=false
ignore=".git,bootstrap"
stow=unset
delete=unset

usage () {
  echo $(basename $0) [dtfiSDh] DIR
  exit $1
}

OPTSTRING="hd:t:fi:S:D:"

while getopts ${OPTSTRING} opt; do
  case $opt in
    d) dir=$OPTARG    ;;
    t) target=$OPTARG ;;
    f) force=true     ;;
    i) ignore=$OPTARG ;;
    S) stow=$OPTARG   ;;
    D) delete=$OPTARG ;;
    h) usage          ;;
    ?) usage 1        ;;
  esac
done
shift $(expr $OPTIND - 1 )

if [ $# -gt 1 ]; then
  usage 1
elif [ $# -eq 1 ]; then
  dir=$1
fi

IFS=', ' read -r -a ignore <<< "$ignore"
IFS=', ' read -r -a stow <<< "$stow"
IFS=', ' read -r -a delete <<< "$delete"
dir=$(realpath $dir)
target=$(realpath $target)
# relative_path=$(realpath -s --relative-to=$HOME/$directory $directory)



pushd () {
  command pushd "$@" > /dev/null
}
popd () {
  command popd > /dev/null
}
is_ignore () {
  if [[ " ${ignore[*]} " =~ [[:space:]]"$1"[[:space:]] ]];then
    true
  else
    false
  fi
}

stow_targets=()

walk_dir () {
  shopt -s nullglob dotglob

  for pathname in "$1"/*; do

    if is_ignore ${pathname#"$dir"/} ;then
      continue
    fi

    if [ -d "$pathname" ]; then
      walk_dir "$pathname"
    else
      stow_targets+=("${pathname#"$dir"/}")
    fi

  done

}

delete () {
  echo delete
}

stow () {
  echo stow
}

walk_dir $dir

echo ${stow_targets[*]}
>&2 cat << EOF
dir=$dir
target=$target
force=$force
ignore=${ignore[*]}
stow=${stow[*]}
delete=${delete[*]}
EOF
