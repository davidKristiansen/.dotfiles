# ~/.config/zsh/zshrc.d/06-dotfiles-update.zsh
# SPDX-License-Identifier: MIT
#
# Silently pull dotfiles and re-bootstrap in the background when there
# are new commits.  Runs after p10k instant prompt (02); all output is
# suppressed to avoid triggering p10k's "console output during init" warning.
#
# When the background pull lands new commits it writes a stamp file.
# A precmd hook detects the stamp and respawns zsh so the new config
# takes effect automatically at the next prompt.

zmodload -F zsh/datetime b:strftime p:EPOCHSECONDS
zmodload -F zsh/stat    b:zstat

typeset -g _dotfiles_stamp="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}/dotfiles-updated"
typeset -g _dotfiles_boot=$EPOCHSECONDS

# ── background pull ─────────────────────────────────────────────────────
(
  local dir="${DOT_DIR:-$HOME/.dotfiles}"
  local stamp="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}/dotfiles-updated"
  local before=$(git -C "$dir" rev-parse HEAD)
  git -C "$dir" pull --rebase --quiet || return
  if [[ $(git -C "$dir" rev-parse HEAD) != "$before" ]]; then
    "$dir"/bootstrap
    touch "$stamp"
  fi
) &>/dev/null &!

# ── respawn hook ────────────────────────────────────────────────────────
_dotfiles_respawn_check() {
  [[ -f "$_dotfiles_stamp" ]] || return
  # Only act if the stamp was written after this shell started
  local stamp_mtime
  zstat -A stamp_mtime +mtime "$_dotfiles_stamp" 2>/dev/null || return
  (( stamp_mtime > _dotfiles_boot )) || return
  # Clean up so a freshly exec'd shell doesn't loop
  command rm -f "$_dotfiles_stamp"
  exec zsh
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _dotfiles_respawn_check

# vim: set ft=zsh ts=2 sw=2:
