{
  setopt LOCAL_OPTIONS NO_NOTIFY NO_MONITOR
  MACCHINA="${XDG_DATA_HOME}"/mise/installs/cargo-macchina/latest/bin/macchina
  if type "${MACCHINA}" >/dev/null; then
    "${MACCHINA}"
  fi
}
