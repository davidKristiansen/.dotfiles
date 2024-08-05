#!/usr/bin/env bash

set -o pipefail

source "$(dirname "${0}")/__stow_conditions.sh"

force=false
debug=0
dry_run=false
# declare -A stow_targets=()

__usage () {
  echo "$(basename $"0")" [dtfiSDh]
  exit "$1"
}

_log() {
  local level="${1}"
  local debug_level="${2}"


  shift 1
  if [[ $level == "debug" ]]; then
    if [[ "${debug_level}" =~ ^[0-9]+$ ]] ; then
      debug_level="${1}"
    else
      debug_level=1
      shift 1
    fi
  fi
  local message="${*}"


  case $level in
    debug)
      if [[ "$debug" -ge "$debug_level" ]]; then
        printf "%s""\n" "$message"
      fi
      ;;
    info)
        printf "%s""\n" "$message"
      ;;
    error)
        printf "%s""\n" "$message" 1>&2
      ;;
  esac
}


OPTSTRING="hd:t:fi:S:D:vn"

while getopts ${OPTSTRING} opt; do
  case $opt in
    d) dir=$OPTARG                 ;;
    t) target=$OPTARG              ;;
    f) force=true                  ;;
    i) ignore+=("$OPTARG")         ;;
    S) stow_targets+=("$OPTARG")   ;;
    D) unstow_targets+=("$OPTARG") ;;
    v) debug=$((debug+=1))         ;;
    n) dry_run=true                ;;
    h) __usage                     ;;
    ?) __usage 1                   ;;
  esac
done
shift [[ expr $OPTIND - 1 ]]

if [ $# -gt 1 ]; then
  __usage 1
elif [ $# -eq 1 ]; then
  stows=("${1}")
fi

if [[ -z $dir ]]; then
  _SOURCE=$(pwd)
else
  _SOURCE="$(realpath "$dir")"
fi

readonly _SOURCE

if [[ -z $target ]]; then
  _TARGET="$(dirname "$_SOURCE")"
else
  _TARGET="$(realpath "$target")"
fi

readonly _TARGET

__contains () {
  set -o noglob

  local test_variable="${1}"
  shift
  local array=("$@")

  for element in "${array[@]}"; do
    if [[ "${test_variable}" =~ $element ]]; then
      return 0
    fi
  done
  return 1
}


__check_conditions () {
  local candidate="${1}"
  if [[ ! "$candidate" == *"##"* ]]; then
    return 0
  fi
  local condition_string="${candidate##*##}"
  IFS=',' read -r -a conditions <<< "$condition_string"

  for condition in "${conditions[@]}"; do
    if [[ "$condition" == \!* ]]; then
      condition="${condition:1}"
      expected=1
    else
      expected=0
    fi
    IFS='.' read -r -a cond <<< "$condition"
    "__stow_" "${cond[@]}" "${cond[@]:1}"
    if [[ $? != "$expected" ]]; then
      _log debug 1 condition "${condition}" not met for "${candidate}"
      return 1
    fi
  done
  return 0
}

__sanitize() {
  local unsanitized=("$(echo "$1" | tr '/' '\n')")
  sanitized=""
  for token in "${unsanitized[@]}"; do
    sanitized+="${token%##*}"/
  done
  sanitized="${sanitized%/}"
  echo "$sanitized"
}

__unstow() {
  local target_path
  local unstow_target="${1}"

  target_path="${_TARGET}"/"$(__sanitize "${unstow_target}")"

  _log debug 1 unstowing "${unstow_target}"

  if [[ ! -L "${target_path}" ]]; then
    _log error "${target_path}" does not exists or is not a symlink
    return 1
  fi
  if [[ $dry_run == false ]]; then
    \rm "${target_path}"
  fi
  _log info "${target_path}" removed

}

__stow() {
  local stow_target="${1}"
  local source_path="${_SOURCE}"/"${stow_target}"
  local target_path
  local relative_path

  target_path="${_TARGET}"/"$(__sanitize "${stow_target}")"
  relative_path="$(realpath -s --relative-to="$(dirname "${target_path}")" "${source_path}")"

  _log debug 2 stow_target "$stow_target"
  _log debug 2 source_path "$source_path"
  _log debug 2 target_path "$target_path"
  _log debug 2 relative_path "$relative_path"

  _log debug 1 "stowing ""${stow_target}"""
  if __contains "${stow_target}" "${ignore[@]}"; then
    _log debug 1 "${stow_target}" ignored
    return 1
  fi

  if __check_conditions "${stow_target}"; then
    return 1
  fi

  if [[ ! -e "${source_path}" ]]; then
    _log error "${stow_target}" is not a stowable object!
    return 1
  fi

  if [[ -e "${target_path}" ]]; then
    if [[ $force == false ]]; then
      _log error "${target_path}" already exists! use -f to overwrite
      return 1
    fi
    if __unstow "${stow_target}"; then
      return $?
    fi
  fi

  if [[ ! -d "$(dirname "$target_path")" ]]; then
    if [[ $dry_run == false ]]; then
      \mkdir --parents "$(dirname "${target_path}")"
    fi
    _log info created path: "$(dirname "${target_path}")"
  fi
  (
    cd "$(dirname "${target_path}")" || exit
    if [[ $dry_run == false ]]; then
      \ln --symbolic "${relative_path}" "$(basename "${target_path}")"
    fi
  )
  _log info "${target_path}" "->" "${relative_path}"
}

__walk_dir () {
  shopt -s nullglob dotglob

  local root_path="${1}"
  root_path="${root_path%/}"
  _log debug 1 root_path: "$root_path"

  for child_path in "${root_path}"/*; do
    local stow_candidate="${child_path#"${_SOURCE}"/}"
    local source_path="${_SOURCE}"/"${stow_candidate}"
    local target_path

    target_path="${_TARGET}"/"$(__sanitize "${stow_candidate}")"

    _log debug 2 stow_candidate: "${stow_candidate}"
    _log debug 2 source_path: "${source_path}"
    _log debug 2 target_path: "${target_path}"

    if [[ -f "${source_path}" ]]; then
      stow_targets+=("${stow_candidate}")
      _log debug 1 adding "${stow_candidate}" to stow stow_targets
      continue
    fi
    if [[ -L "${target_path}" ]]; then
      stow_targets+=("${stow_candidate}")
      _log debug  adding "${stow_candidate}" to stow stow_targets
      continue
    fi
    if [[ ! -d "${target_path}" ]]; then
      stow_targets+=("${stow_candidate}")
      _log debug 1 adding "${stow_candidate}" to stow stow_targets
      continue
    fi

    __walk_dir "${stow_candidate}"
  done

}


if [[ ! -z $unstow_targets ]]; then
  for unstow_target in "${unstow_targets[@]}"; do
    __unstow "${unstow_target}"
  done
fi

if [[ -z $stow_targets && -z $unstow_targets ]]; then
  __walk_dir "${_SOURCE}"
fi

for stow_target in "${stow_targets[@]}"; do
  __stow "${stow_target}"
done

if [[ $dry_run == true ]]; then
  _log info "\n-n flag. Nothing was written to filesystem\n"
fi

_log debug 3 "\
debug=$debug\n\
stows=${stows[*]}\n\
dir=$_SOURCE\n\
target=$_TARGET\n\
force=$force\n\
ignore=${ignore[*]}\n\
stow_targets=${stow_targets[*]}\n\
unstow_targets=${unstow_targets[*]}\n\
"
