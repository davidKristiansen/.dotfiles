# ~/.config/zsh/zshrc.d/75-autosuggestions.zsh
# SPDX-License-Identifier: MIT
#
# zsh-autosuggestions tuning (plugin loads deferred via antidote; all of these
# are read at suggestion time, so setting them here is order-safe).
#
# Strategy: history first, then the completion engine — completion-powered
# ghost text as you type ("intellisense" feel) without touching fzf-tab, which
# keeps owning the Tab menu. Accept with Ctrl-F (bound in 80-keybindings.zsh,
# mirroring <C-F> = accept inline completion in the nvim config).

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Fetch suggestions asynchronously in a zpty so completion lookups never block
# typing.
ZSH_AUTOSUGGEST_USE_ASYNC=1

# Skip suggesting for very long buffers (no value, measurable cost).
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=80

return 0
# vim: set ft=zsh ts=2 sw=2:
