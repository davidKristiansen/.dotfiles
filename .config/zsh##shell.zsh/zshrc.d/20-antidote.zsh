
export ANTIDOTE_HOME="${XDG_DATA_HOME}"/antidote/data
ANTIDOTE_CLONE="${XDG_DATA_HOME}"/antidote/clone


# Clone antidote if necessary.
if [[ ! -d "${ANTIDOTE_CLONE}" ]]; then
  git clone https://github.com/mattmc3/antidote "${ANTIDOTE_CLONE}"
fi

# Lazy-load antidote and generate the static load file only when needed
zsh_plugins=${ZDOTDIR:-$HOME}/zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  (
    source "${ANTIDOTE_CLONE}"/antidote.zsh
    antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
  )
fi

source ${zsh_plugins}.zsh
