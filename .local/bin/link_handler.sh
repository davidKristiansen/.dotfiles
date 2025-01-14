#!/bin/bash

browser=firefox
doc_svn_base="$HOME/ROOTDIR/10.DocSVN"


case "${1}" in
  https://*.*/svn/repos/*)
    path=$(printf '%s\n' "${1#*svn/repos/}")
    path=$(printf '%s\n' "${path/trunk\/}")

    full_path="${doc_svn_base}"/"${path}"

    if [ -d "${full_path}" ]; then
      nautilus "${full_path}"
    elif [ -d "$(dirname "${full_path}")" ]; then
      nautilus "$(dirname "${full_path}")"
    else
      "${browser}" $1
    fi

    echo $(dirname $path)
    echo $1
    ;;
  *)
    "${browser}" "${1}"
  ;;
esac
