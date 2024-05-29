extension() {
  return 0
}

os () {
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

shell () {
  if [ $(basename $SHELL) == $1 ]; then
    return 0
  else
    return 1
  fi
}

docker () {
  if [ -f /.dockerenv ]; then
    return 0
  else
    return 1
  fi
}

wsl () {
  if $(lscpu | grep '^\(Hypervisor vendor\).*\([mM]icrosoft\|[wW]indows\)'); then
    return 0
  else
    return 1
  fi
}

exe () {
  if type $1 &>/dev/null; then
    return 0
  else
    return 1
  fi
}

wm () {
  return $(executable $1)
}
