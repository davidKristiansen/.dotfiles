# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

__stow_extension() {
  return 0
}

__stow_os () {
  os=$(grep -E "^NAME=" /etc/os-release)
  os="${os#*=}"
  os="${os//\"/}"
  os="${os,,}"
  if [[ $os == "$1" ]];  then
    return 0
  else
    return 1
  fi
}

__stow_shell () {
  if [[ -z  $SHELL ]]; then
    return $(__stow_exe $1)
  fi

  if [ $(basename $SHELL) == $1 ]; then
    return 0
  else
    return 1
  fi
}

__stow_docker () {
  if [ -f /.dockerenv ]; then
    return 0
  else
    return 1
  fi
}

__stow_wsl () {
  if $(lscpu | grep '^\(Hypervisor vendor\).*\([mM]icrosoft\|[wW]indows\)'); then
    return 0
  else
    return 1
  fi
}

__stow_exe () {
  if type $1 &>/dev/null; then
    return 0
  else
    return 1
  fi
}

__stow_wm () {
  return $(__stow_exe $1)
}
