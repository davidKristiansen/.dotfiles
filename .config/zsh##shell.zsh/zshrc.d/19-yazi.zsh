# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
  clear
  eza -TL 1 --icons=always
}

MAGIC_ENTER_GIT_COMMAND=y
MAGIC_ENTER_OTHER_COMMAND=y


