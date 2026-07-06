# ~/.config/zsh/zshrc.d/50-mise.zsh
# SPDX-License-Identifier: MIT

# Activate mise (full activation so chpwd/precmd hooks keep tool paths
# on PATH even after venv activate/deactivate cycles).
#
# The activate script is static per mise version — cache it (03-cached-eval)
# instead of forking `mise activate` on every startup. Two safety measures:
#   - Generation runs with mise's session vars scrubbed: from an already-
#     activated shell, `mise activate` emits a deactivation preamble with a
#     hardcoded snapshot of the generating shell's PATH, which must never be
#     cached and replayed into fresh shells.
#   - The eager `_mise_hook` line is stripped. The precmd hook registered by
#     the same script runs the identical `mise hook-env` before the first
#     prompt — behind p10k's instant prompt — instead of blocking startup for
#     the full fork (~50ms). Shims are on the base PATH (environment.d), so
#     tools still resolve during the rest of startup.
() {
  local mise_bin
  if (( $+commands[mise] )); then
    mise_bin=${commands[mise]}
  elif [[ -x "$HOME/.local/bin/mise" ]]; then
    mise_bin="$HOME/.local/bin/mise"
  else
    return 0
  fi
  _mise_activate_gen() {
    env -u MISE_SHELL -u __MISE_DIFF -u __MISE_SESSION -u __MISE_ORIG_PATH \
      "$1" activate zsh | grep -vx '_mise_hook'
  }
  _cached_eval mise _mise_activate_gen "$mise_bin"
  unfunction _mise_activate_gen
}

# vim: set ft=zsh ts=2 sw=2:
