# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

function nvim-files { nvim +"FzfLua files"; zle redisplay; }
zle -N nvim-files
bindkey '^f' nvim-files

