# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [ ! -f "${HISTFILE}" ]; then
  mkdir -p "$(dirname "${HISTFILE}")"
  touch "${HISTFILE}"
fi
#

# Source anything in .zshrc.d
for _rc in "${ZDOTDIR:-$HOME}"/zshrc.d/*.zsh; do
  # Ignore tilde files.
  if [[ "${_rc}:t" != '~' ]]; then
    source "${_rc}"
  fi
done
unset _rc

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

# Prompt for spelling correction of commands.
setopt CORRECT

# Customize spelling correction prompt.
SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# Append `../` to your input for each `.` you type after an initial `..`
zstyle ':zim:input' double-dot-expand yes

\mkdir -p "${XDG_CACHE_HOME}"/zsh
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME"/zsh/zcompcache

HISTSIZE=290000
SAVEHIST=$HISTSIZE

# ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# bindkey '^r' fzf-history-widget
#
#
#
# if type pyenv >/dev/null; then
#   eval "$(pyenv init --path)"
# fi
#
#
#
# if [ -f ~/.fzf.zsh ]; then
#   . ~/.fzf.zsh
# fi
#
# # if type thefuck &> /dev/null; then
# #   eval $(thefuck --alias)
# # fi
#
# export LC_ALL="en_US.UTF-8"
#
#
# ## fzf-tab
# # disable sort when completing `git checkout`
# zstyle ':completion:*:git-checkout:*' sort false
# # set descriptions format to enable group support
# # NOTE: don't use escape sequences here, fzf-tab will ignore them
# zstyle ':completion:*:descriptions' format '[%d]'
# # set list-colors to enable filename colorizing
# zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
# zstyle ':completion:*' menu no
# # preview directory's content with eza when completing cd
# zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# # switch group using `<` and `>`
# zstyle ':fzf-tab:*' switch-group '<' '>'
# # zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
#
# # if [[ ! $(tmux ls) ]] 2> /dev/null; then
# #   tmux new -s λ
# # fi
#
# if [ -f $ZDOTDIR/aliases ]; then
#     . $ZDOTDIR/aliases
# fi
#
#
#
#

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
