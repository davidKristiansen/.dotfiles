ZDOTDIR=$HOME/.config/zsh

for _rc in "${XDG_CONFIG_HOME:-$HOME/.config}"/environment.d/*.conf; do
  # Ignore tilde files.
  if [[ "${_rc}:t" != '~' ]]; then
    emulate zsh -o all_export -c 'source "${_rc}"'
  fi
done
unset _rc

#
###############################################################################
# Load user environment variables
devcontainer_settings=$HOME/.config/devcontainer_environment/environment_variables
if [[ -f $devcontainer_settings && -f /.dockerenv ]]; then
    # Executing in docker - load user specific container settings
    emulate zsh -o all_export -c 'source "${devcontainer_settings}"'
fi

# Ensure path arrays do not contain duplicates.
typeset -gU path fpath
