set -a
for _rc in "${XDG_CONFIG_HOME:-$HOME/.config}"/environment.d/*.conf; do
  # Ignore tilde files.
  if [[ "${_rc}:t" != '~' ]]; then
    . "${_rc}"
  fi
done
set +a
unset _rc

