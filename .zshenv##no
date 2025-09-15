# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

# Prefer XDG layout
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

###############################################################################
# Load user environment variables and GPG_TTY if inside Docker

devcontainer_settings="$HOME/.config/devcontainer_environment/environment_variables"

if [[ -f /.dockerenv ]]; then
    # If running in Docker
    export GPG_TTY=$(tty)
    if [[ -f $devcontainer_settings ]]; then
        emulate zsh -o all_export -c "source \"$devcontainer_settings\""
    fi
fi

