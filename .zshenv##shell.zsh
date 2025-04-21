# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

# Prefer XDG layout
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

###############################################################################
# Load user environment variables
devcontainer_settings=$HOME/.config/devcontainer_environment/environment_variables
if [[ -f $devcontainer_settings && -f /.dockerenv ]]; then
    # Executing in docker - load user specific container settings
    emulate zsh -o all_export -c 'source "${devcontainer_settings}"'
fi

