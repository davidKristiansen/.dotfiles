# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# First prompt line
if type neofetch >/dev/null; then
    neofetch --off --disable packages --color_blocks off
    printf "---\n"
fi
if type fortune >/dev/null; then
    fortune
fi

# ZINIT
## Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
	print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma-continuum/zinit)…%f"
	command mkdir -p $HOME/.zinit
	command git clone https://github.com/zdharma-continuum/zinit $HOME/.zinit/bin && \
		print -P "%F{33}▓▒░ %F{34}Installation successful.%F" || \
		print -P "%F{160}▓▒░ The clone has failed.%F"
fi
source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit installer's chunk


# PLUGINS

zinit wait lucid for \
    MichaelAquilina/zsh-autoswitch-virtualenv \
	atinit'ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay' \
	zdharma-continuum/fast-syntax-highlighting \
	blockf \
	zsh-users/zsh-completions \
	atload'!_zsh_autosuggest_start' \
	zsh-users/zsh-autosuggestions \
	OMZP::command-not-found \
	OMZL::completion.zsh \
	OMZP::extract \
	OMZP::thefuck \
  OMZP::tmux \
	b4b4r07/enhancd \
	Aloxaf/fzf-tab \
    # OMZ::plugins/docker/_docker \

zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode


# zinit ice from"gh-r" as"program" atload'eval "$(starship init zsh)"'
# zinit load starship/starship

zinit ice wait'0a' lucid atload'bindkey "$terminfo[kcuu1]" history-substring-search-up; bindkey "$terminfo[kcud1]" history-substring-search-down'
zinit light zsh-users/zsh-history-substring-search

zinit ice wait'[[ -n ${ZLAST_COMMANDS[(r)fzf*]} ]]' ice from"gh-r" as"command"
zinit light junegunn/fzf

# export ENHANCD_FILTER=fzf:fzy:peco

export FZF_DEFAULT_OPTS='--bind=ctrl-k:up,ctrl-j:down'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

zinit ice pick'poetry.zsh'
zinit light sudosubin/zsh-poetry


zinit ice depth=1; zinit light romkatv/powerlevel10k

#####################
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zhistory"
HISTSIZE=290000
SAVEHIST=$HISTSIZE

VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
VI_MODE_SET_CURSOR=true

setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_all_dups   # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt inc_append_history     # add commands to HISTFILE in order of execution
setopt share_history          # share command history data
setopt always_to_end          # cursor moved to the end in full completion
setopt hash_list_all          # hash everything before completion
# setopt completealiases        # complete alisases
setopt always_to_end          # when completing from the middle of a word, move the cursor to the end of the word
setopt complete_in_word       # allow completion from within a word/phrase
setopt nocorrect                # spelling correction for commands
setopt list_ambiguous         # complete as much of a completion until it gets ambiguous.
setopt nolisttypes
setopt listpacked
setopt automenu
unsetopt BEEP
setopt vi

# chpwd() {
#  set -- "$(git rev-parse --show-toplevel)" 2>/dev/null
#  # If cd'ing into a git working copy and not within the same working copy
#  if [ -n "$1" ] && [ "$1" != "$vc_root" ]; then
#    vc_root="$1"
#    git fetch 2> /dev/null
#  fi
#  # ls inside folder after cd
#  exa --git --icons --classify --group-directories-first --time-style=long-iso --group --color-scale
#}

export BROWSER='firefox'
export EDITOR='nvim'
export MANPAGER='nvim +Man!'
export MANWIDTH=9999
export VISUAL=$EDITOR
export PAGER='less'
export BAT_THEME="gruvbox-dark"

# alias tmux="TERM=tmux-256color tmux"

# Homebrew
if [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
    export PATH=$PATH:/home/linuxbrew/.linuxbrew/bin
fi

# if [[ ! $(tmux ls) ]] 2> /dev/null; then
# 	tmux new -s λ
# fi


autoload colors && colors

alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias vim=$EDITOR
alias :e=$EDITOR
alias :q=exit
alias :Q=:q

if [ -f $HOME/.aliases ]; then
    source $HOME/.aliases
fi

export PATH=$PATH:$HOME/.local/bin

if [ -f $HOME/.cargo/env ]; then
	source $HOME/.cargo/env
elif [ -d $HOME/.cargo/bin ]; then
	export PATH=$PATH:$HOME/.cargo/bin
fi

if type trash >/dev/null; then
    alias rm=trash
fi
if type bat >/dev/null; then
    alias cat=bat
fi
# if type nala >/dev/null; then
#     alias apt=nala
# fi
if type exa >/dev/null; then
    alias ls='exa --color=auto'
    alias la='exa -a'
    alias ll='exa -lahb'
    alias l=ls
fi
if type clip.exe >/dev/null; then
    alias clip='clip.exe'
fi

dotenv () {
    set -a
    [ -f ./.env ] && export $(echo $(cat .env | sed 's/#.*//g'| xargs) | envsubst)
    set +a
}
dotenv
function cd () {
    builtin cd $@
    dotenv
}

# function e () {
#     if [[ $# -eq 0 ]]
#     then
#         nvim .
#     else
#         nvim $@
#     fi
# }

if [ -f "/mnt/c/Gitwrap/GitWrap.exe" ]; then
    alias git=/mnt/c/Gitwrap/GitWrap.exe
fi


bindkey -s '^T' 'uptime'

if [ -d /opt/python/bin ]; then
	export PATH=$PATH:/opt/python/bin
fi

if [ -d /opt/arm/armcc/bin ]; then
	export PATH=$PATH:/opt/arm/armcc/bin
fi

fpath+=(~/.zsh_completions.d)

export PYTHONPATH=/home/SONY/s7000026748/Work/Aurora/Devcontainer/70.Toolchain/10.Internal/10.Libraries/Python:$PYTHONPATH

###############################################################################
# WSL VPN Fix (using sakai135/wsl-vpnkit)
###############################################################################
# Start in background and ignore output
if [[ -n "$IS_WSL" || -n "$WSL_DISTRO_NAME" ]]; then
    {wsl.exe -d wsl-vpnkit service wsl-vpnkit start &> /dev/null} &!
fi

export PATH=$PATH:/ROOTDIR/TOOL/DS-5_Linux/bin:/opt/kanshi

# ## Podman
# if [[ -z "$XDG_RUNTIME_DIR" ]]; then
#   export XDG_RUNTIME_DIR=/run/user/$UID
#   if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
#     export XDG_RUNTIME_DIR=/tmp/$USER-runtime
#     if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
#       mkdir -m 0700 "$XDG_RUNTIME_DIR"
#     fi
#   fi
# fi
#
# bindkey -r '^F'
bindkey -s "^F" ':e "+Telescope find_files"^M'

autoload -Uz compinit
compinit

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
