# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


. "$HOME/.asdf/asdf.sh"

fpath+=($ZDOTDIR/zsh_completions.d)

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


[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zhistory"
HISTSIZE=290000
SAVEHIST=$HISTSIZE

# Lazy-load antidote and generate the static load file only when needed
zsh_plugins=${ZDOTDIR:-$HOME}/zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  (
    source $ZDOTDIR/antidote/antidote.zsh
    antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
  )
fi
source ${zsh_plugins}.zsh


export BROWSER='firefox'
export EDITOR='nvim'
export MANPAGER='nvim +Man!'
export MANWIDTH=9999
export VISUAL=$EDITOR
export PAGER='less'
export BAT_THEME="gruvbox-dark"
export GCM_CREDENTIAL_STORE=secretservice

export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.asdf/shims:$PATH

if [ -d /opt/python/bin ]; then
	export PATH=/opt/python/bin:$PATH
fi

if [ -d /opt/arm/armcc/bin ]; then
	export PATH=/opt/arm/armcc/bin:$PATH
fi
if [ -d /opt/arm/armds/bin ]; then
	export PATH=/opt/arm/armds/bin:$PATH
fi
if [ -d $HOME/go/bin ]; then
	export PATH=$HOME/go/bin:$PATH
fi

if [ -f $ZDOTDIR/aliases ]; then
    . $ZDOTDIR/aliases
fi
if [ -f ~/.fzf.zsh ]; then
  . ~/.fzf.zsh
fi

eval "$($HOME/.asdf/shims/zoxide init zsh --cmd cd)"

export LC_ALL="en_US.UTF-8"


if [[ ! $(tmux ls) ]] 2> /dev/null; then
  tmux new -s λ
fi

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
