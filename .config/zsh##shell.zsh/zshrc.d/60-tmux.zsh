# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

# ZSH-TMUX vars for plugin managers
ZSH_TMUX_AUTOSTART=true
ZSH_TMUX_AUTOCONNECT=true
ZSH_TMUX_AUTOQUIT=true
ZSH_TMUX_CONFIG="${XDG_CONFIG_HOME}/tmux/tmux.conf"
ZSH_TMUX_DEFAULT_SESSION_NAME=λ
ZSH_TMUX_AUTONAME_SESSION=true
ZSH_TMUX_UNICODE=true

# Project root markers
_project_root_markers=(
  .git .tmux-session-name .project
  package.json lazy-lock.json yarn.lock
  pyproject.toml setup.py
  Cargo.toml Makefile CMakeLists.txt
  .nvimrc .nvim/ init.lua
  .env .venv requirements.txt
)
