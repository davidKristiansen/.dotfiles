#!/usr/bin/env bash
# fcitx.sh — waybar input-method indicator for fcitx5.
#   (no args)  emit JSON status for the custom/fcitx module
#
# Always shows the あ glyph; the CSS colors it (gray = off, accent = Mozc on).
# `fcitx5-remote -n` prints the current IM's unique name: "mozc" when composing
# Japanese, "keyboard-*" for the latin passthrough. This is orthogonal to sway's
# xkb layout (see sway/language for US/NO). If fcitx5 isn't running yet the
# command errors and we fall through to the off state.

im=$(fcitx5-remote -n 2>/dev/null)

case "$im" in
  mozc)
    printf '{"text":"あ","class":"mozc","tooltip":"Japanese (Mozc) — on"}\n'
    ;;
  *)
    printf '{"text":"あ","class":"off","tooltip":"Latin — Japanese off"}\n'
    ;;
esac
