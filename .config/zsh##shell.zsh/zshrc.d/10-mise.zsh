# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

eval "$(~/.local/bin/mise activate zsh)"
eval "$(mise activate --shims)"

eval "$("${XDG_DATA_HOME}"/mise/installs/cargo-zoxide/latest/bin/zoxide init zsh --cmd cd)"
