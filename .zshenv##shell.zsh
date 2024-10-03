ZDOTDIR=$HOME/.config/zsh

if [[ -f "${ZDOTDIR}/.zshenv" ]]; then
  . "${ZDOTDIR}/.zshenv"
fi
#
###############################################################################
# Load user environment variables
devcontainer_settings=$HOME/.config/devcontainer_environment/environment_variables
if [[ -f $devcontainer_settings && -f /.dockerenv ]]; then
    # Executing in docker - load user specific container settings
    set -a
    . $devcontainer_settings
    set +a
fi
