# ~/.config/zsh/zshrc.d/72-fzf-tab.zsh
# SPDX-License-Identifier: MIT

# General fzf-tab UX
zstyle ':fzf-tab:*' switch-group ',' '.'     # , and . to switch groups/columns
zstyle ':fzf-tab:*' fzf-flags --ansi --height=60% --border --reverse

# Make process completion show names (so fuzzy search by command works)
# Use a rich ps so fzf sees both PID and command line
zstyle ':completion:*:processes' command 'ps -Ao pid,user,pcpu,pmem,etime,tty,stat,command'

# Pretty preview when completing PIDs (kill/killall)
zstyle ':fzf-tab:complete:kill:*' fzf-preview \
  'ps -o pid,user,pcpu,pmem,etime,tty,stat,command -p $word --no-headers'
zstyle ':fzf-tab:complete:killall:*' fzf-preview \
  'pgrep -a $word 2>/dev/null || ps -Ao pid,command | grep -i --color=always $word'

# cd with directory preview (uses eza or ls)
if command -v eza >/dev/null 2>&1; then
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -lah --color=always --icons=auto $realpath'
else
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -lah --color=always $realpath'
fi

# ssh host preview (shows final Hostname/User/Port)
zstyle ':fzf-tab:complete:ssh:*' fzf-preview \
  'ssh -G $word 2>/dev/null | sed -n "s/^\(hostname\|user\|port\) //p"'

# Git branch preview (last commits)
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
  'git --no-pager log --oneline --decorate -n 20 -- $word 2>/dev/null'

return 0
# vim: set ft=zsh ts=2 sw=2:

