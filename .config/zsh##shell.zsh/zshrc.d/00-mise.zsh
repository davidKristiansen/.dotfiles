# SPDX-License-Identifier: MIT
# Early activation of mise to ensure PATH/shims

# Activate mise (core + shims)
eval "$("$HOME/.local/bin/mise" activate zsh)"
eval "$(mise activate --shims)"
