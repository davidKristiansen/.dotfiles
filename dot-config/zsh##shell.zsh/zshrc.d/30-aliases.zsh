# ~/.config/zsh/zshrc.d/30-aliases.zsh
# SPDX-License-Identifier: MIT
# Copyright David Kristiansen

# --- editor shorthands -------------------------------------------------------
# Detect VS Code integrated terminal
if [[ -n "$VSCODE_IPC_HOOK_CLI" || "$TERM_PROGRAM" == "vscode" ]]; then
  alias vim="code"
  alias :e="code"
  alias e="code"
else
  if [[ -n "$EDITOR" ]]; then
    alias vim="$EDITOR"
    alias :e="$EDITOR"
    alias e="$EDITOR"
  fi
fi
alias :q='exit'
alias :Q=':q'

# --- safer rm to trash if available -----------------------------------------
if command -v trash >/dev/null 2>&1; then
  alias rm='trash'
fi

# --- bat-enhanced coreutils (guarded) ---------------------------------------
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --theme gruvbox-dark --color auto --decorations auto'

  # Keep real grep (incompatible flags/regex with batgrep); expose batgrep as bgrep.
  alias grep='grep --color=auto'
  command -v batgrep >/dev/null 2>&1 && \
    alias bgrep='batgrep --terminal-width="${COLUMNS:-80}"'

  command -v batman   >/dev/null 2>&1 && alias man='batman'
  command -v batpipe  >/dev/null 2>&1 && alias less='batpipe'
  # Keep real watch (different flag surface); expose batwatch as bwatch.
  command -v batwatch >/dev/null 2>&1 && alias bwatch='batwatch'
else
  alias grep='grep --color=auto'
fi

# --- ls / eza ----------------------------------------------------------------
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --color=auto --icons=auto'
  alias ll='eza --total-size --long --changed --sort modified --reverse --all --header --group-directories-first'
  alias tree='eza --tree'
else
  alias ls='ls --color=auto'
  alias ll='ls -lahb'
fi
alias la='ls -a'
alias l='ls'

# --- clipboard (WSL compatibility) ------------------------------------------
command -v clip.exe >/dev/null 2>&1 && alias clip='clip.exe'

# --- sudo with env -----------------------------------------------------------
# alias sudo='sudo -E'

# --- ssh wrapper: cleanup terminal after exit -------------------------------
ssh() {
  command ssh "$@"
  # Restore terminal defaults after exiting a remote session.
  setterm -default -clear reset 2>/dev/null || true
}

# --- wget, tmux, svn with XDG paths -----------------------------------------
alias wget='wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'
alias tmux='tmux -u -f "$XDG_CONFIG_HOME/tmux/tmux.conf"'
alias svn='svn --config-dir "$XDG_CONFIG_HOME/subversion"'

# --- dotfiles helper ---------------------------------------------------------
alias dotfiles='/usr/bin/git -C "$DOT_DIR"'

# --- devcontainer helpers ----------------------------------------------------
# dce [workspace-folder] [session-name] [-- custom command...]
#   workspace-folder : path to project (default: $PWD)
#   session-name     : tmux session name (default: basename of workspace-folder)
#   -- command...    : override the default tmux attach-or-new behaviour
#
# Ensures the container is running (devcontainer up) before exec-ing into it.
dce() {
  local ws_folder session
  local -a cmd

  # ── parse arguments ──────────────────────────────────────────────────
  # Everything after a bare "--" becomes the custom command.
  local parsing_opts=true
  local positional=()
  for arg in "$@"; do
    if $parsing_opts && [[ "$arg" == "--" ]]; then
      parsing_opts=false
      continue
    fi
    if $parsing_opts; then
      positional+=("$arg")
    else
      cmd+=("$arg")
    fi
  done

  ws_folder="${positional[1]:-$PWD}"
  session="${positional[2]:-${ws_folder:t}}"   # :t = basename in zsh

  # ── dotfiles provisioning (only used when creating a new container) ───
  local -a dotfiles_args=(
    --dotfiles-repository "https://github.com/davidKristiansen/.dotfiles.git"
    --dotfiles-install-command "bootstrap"
    --dotfiles-target-path '$HOME/.dotfiles'
  )

  # ── ensure container is running ───────────────────────────────────────
  # Try to reuse an already-running container (e.g. one started by VS Code)
  # before falling back to creating a new one.
  # NOTE: devcontainer up may exit non-zero even when the container starts
  # successfully (e.g. a failing postStartCommand), so we always capture
  # the output and check for a container id rather than relying on the
  # exit code alone.
  local up_output
  up_output="$(devcontainer up --expect-existing-container --workspace-folder="$ws_folder" 2>/dev/null)"
  if [[ $? -ne 0 ]] || ! printf '%s' "$up_output" | command grep -q '"containerId"'; then
    up_output="$(devcontainer up "${dotfiles_args[@]}" --workspace-folder="$ws_folder" 2>&1)"
  fi

  # ── extract container id and remote user from JSON output ────────────
  local container_id remote_user
  container_id="$(printf '%s' "$up_output" | command grep -o '"containerId":"[^"]*"' | head -1 | cut -d'"' -f4)"
  remote_user="$(printf '%s' "$up_output" | command grep -o '"remoteUser":"[^"]*"' | head -1 | cut -d'"' -f4)"

  if [[ -z "$container_id" ]]; then
    echo "dce: devcontainer up failed — no container id in output"
    printf '%s\n' "$up_output"
    return 1
  fi

  # ── exec into container ──────────────────────────────────────────────
  if (( ${#cmd} )); then
    # Non-interactive: use devcontainer exec (handles env probing, etc.)
    devcontainer exec --remote-env TERM="$TERM" --workspace-folder="$ws_folder" "${cmd[@]}"
  else
    # Interactive tmux: use docker exec -it for proper TTY allocation
    local -a docker_exec=(
      docker exec -it
      -e TERM="$TERM"
      -e LANG="${LANG}"
      -e LC_ALL="${LC_ALL}"
    )
    [[ -n "$remote_user" ]] && docker_exec+=(-u "$remote_user")
    "${docker_exec[@]}" "$container_id" \
      tmux attach-session -t "$session" 2>/dev/null \
      || "${docker_exec[@]}" "$container_id" \
        tmux new-session -s "$session"
  fi
}

# --- lazy helpers for git/docker --------------------------------------------
git() {
  if [[ -z "$1" ]] && command -v lazygit >/dev/null 2>&1; then
    command \lazygit
  else
    command \git "$@"
  fi
}

docker() {
  if [[ -z "$1" ]] && command -v lazydocker >/dev/null 2>&1; then
    command \lazydocker
  else
    command \docker "$@"
  fi
}

# --- quick todo --------------------------------------------------------------
# to        : open todo in tmux float (or nvim if not in tmux)
# ta <task> : add item to inbox
to() {
  if [[ -n "$TMUX" ]]; then
    tmux display-popup -E -b rounded \
      -S "fg=colour142" -s "bg=colour235" \
      -T " 󰄬 Todo " -w 60% -h 70% \
      "$HOME/.local/bin/tmux-todo"
  else
    "$HOME/.local/bin/tmux-todo"
  fi
}

ta() {
  local todo_file="${XDG_DATA_HOME:-$HOME/.local/share}/vault/32 Tasks/todo.md"
  if [[ -z "$*" ]]; then
    echo "usage: ta <task description>"
    return 1
  fi
  sed -i "/^## Inbox$/a - [ ] $*" "$todo_file"
  echo "added: $*"
}


extract() {
 # Extract files from mime types
  local file="$1"
  [[ -f "$file" ]] || { echo "extract: '$file' is not a valid file"; return 1; }

  local mime
  mime=$(\file --brief --mime-type -- "$file")

  case "$mime" in
    application/zip) unzip "$file" ;;
    application/x-7z-compressed) 7z x "$file" ;;
    application/x-rar|application/vnd.rar) unrar x "$file" ;;
    application/x-tar) tar -xf "$file" ;;
    application/gzip) tar -xzf "$file" ;;
    application/x-bzip2) tar -xjf "$file" ;;
    application/x-xz) tar -xJf "$file" ;;
    application/zstd|application/x-zstd) tar --use-compress-program=unzstd -xf "$file" ;;
    application/x-compress) uncompress "$file" ;;
    application/vnd.debian.binary-package) ar x "$file" ;;
    *) echo "extract: unsupported file type '$mime'" ;;
  esac
}

return 0
# vim: set ft=zsh ts=2 sw=2:

