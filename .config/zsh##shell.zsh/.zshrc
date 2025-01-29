for _rc in "${XDG_CONFIG_HOME:-$HOME/.config}"/environment.d/*.conf; do
  # Ignore tilde files.
  if [[ "${_rc}:t" != '~' ]]; then
    emulate zsh -o all_export -c 'source "${_rc}"'
  fi
done
unset _rc
# Ensure path arrays do not contain duplicates.
typeset -gU path fpath


[[ -f "${HOME}"/.secrets ]] && emulate zsh -o all_export -c 'source "${HOME}"/.secrets'
[[ -z "${XDG_RUNTIME_DIR}" ]] && export XDG_RUNTIME_DIR=$XDG_CACHE_HOME

{
  setopt LOCAL_OPTIONS NO_NOTIFY NO_MONITOR
  MACCHINA="${XDG_DATA_HOME}"/mise/installs/cargo-macchina/latest/bin/macchina
  if type "${MACCHINA}" >/dev/null; then
    "${MACCHINA}"
  fi
}

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source anything in .zshrc.d
for _rc in "${ZDOTDIR:-$HOME}"/zshrc.d/*.zsh; do
  # Ignore tilde files.
  if [[ "${_rc}:t" != '~' ]]; then
    source "${_rc}"
  fi
done
unset _rc

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# Append `../` to your input for each `.` you type after an initial `..`
zstyle ':zim:input' double-dot-expand yes

\mkdir -p "${XDG_CACHE_HOME}"/zsh
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME"/zsh/zcompcache

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
