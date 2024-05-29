#!/usr/bin/env bash

set -o pipefail

source $(dirname $0)/__stow_conditions.sh

pushd () {
  command pushd "$@" > /dev/null
}
popd () {
  command popd > /dev/null
}

force=false
declare -A stows

usage () {
  echo $(basename $0) [dtfiSDh]
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
  ignore=(".git"
          "bootstrap"
          ".gitmodules"
          ".gitignore"
)
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
    base="${stow_candidate#"$dir"}"
    target_path="$target/$base"
    stow_candidate="$stow_candidate"

    sanitized_base=$(sanitize_path $base)
    if [[ "$sanitized_base" == /* ]]; then
      sanitized_base="${sanitized_base:1}"
    fi
    if contains $sanitized_base "${ignore[@]}"; then
      continue
    fi

    if [[ "$stow_candidate" == *"##"* ]]; then
      pass=true
      condition_string=${stow_candidate##*##}
      IFS=',' read -r -a conditions <<< "$condition_string"
      for condition in "${conditions[@]}"; do
        if [[ "$condition" == \!* ]]; then
          condition="${condition:1}"
          expected=1
        else
          expected=0
        fi
        IFS='.' read -r -a cond <<< "$condition"
        "__stow_""${cond[@]}" "${cond[@]:1}"
        if [[ $? != $expected ]]; then
          pass=false
          break
        fi
      done
      if [[ $pass == false ]]; then
        continue
      fi
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

sanitize_path() {
  a=($(echo "$1" | tr '/' '\n'))
  sanitized=""
  for token in ${a[@]}; do
    sanitized+="/${token%##*}"
  done
  echo $sanitized
}

unstow () {
  for candidate in $@; do
    target_path="$target/$candidate"
    target_path=$(sanitize_path $target_path)
    remove_symlink "$target_path"
  done
}

stow () {
  for candidate in $@; do

    target_path="$target/$candidate"
    stow_path="$dir/$candidate"

    target_path=$(sanitize_path $target_path)

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
      ln -s "$relative_path" "$(basename $target_path)"
    popd
    echo "$target_path -> $relative_path"

  done
}

if [[ ! -z $unstow_targets ]]; then
  unstow "${unstow_targets[@]}"
  exit 0
fi
if [[ -z $stow_targets ]]; then
  walk_dir $dir
fi
stow "${stow_targets[@]}"

# >&2 cat << EOF
# stow_targets=${stow_targets[*]}
# dir=$dir
# target=$target
# force=$force
# ignore=${ignore[*]}
# stow=${stow[*]}
# delete=${delete[*]}
# EOF
