# SPDX-License-Identifier: MIT

# --- p10k instant prompt (must be near top, before anything noisy) ----------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

return 0
# vim: set ft=zsh ts=2 sw=2:
