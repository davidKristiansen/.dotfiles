XDG_CONFIG_HOME="${HOME}"/.config
XDG_CACHE_HOME="${HOME}"/.cache
XDG_BIN_HOME="${HOME}"/.local/bin
XDG_DATA_HOME="${HOME}"/.local/share

# DOT_DIR="${HOME}/dotfiles"

ZSH_CACHE_DIR="${XDG_CACHE_HOME}"/zsh

ASDF_DIR="${XDG_DATA_HOME}"/asdf
ASDF_DATA_DIR="${XDG_DATA_HOME}"/asdf_data
ASDF_CONFIG_FILE="${XDG_CONFIG_HOME}/config/asdf/config"

CARGO_HOME="${XDG_DATA_HOME}"/cargo
RUSTUP_HOME="${XDG_DATA_HOME}"/rustup
CUDA_CACHE_PATH="${XDG_CACHE_HOME}"/nv
DOCKER_CONFIG="${XDG_CONFIG_HOME}"/docker
DOTNET_CLI_HOME="${XDG_DATA_HOME}"/dotnet
GNUPGHOME="${XDG_DATA_HOME}"/gnupg
GOPATH="${XDG_DATA_HOME}"/go
NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}"/npm/npmrc
_JAVA_OPTIONS=-Djava.util.prefs.userRoot="${XDG_CONFIG_HOME}"/java
PYTHONSTARTUP="${XDG_CONFIG_HOME}"/python/pythonrc
VAGRANT_HOME="${XDG_DATA_HOME}"/vagrant
WORKON_HOME="${XDG_DATA_HOME}"/virtualenvs

HISTFILE="${HOME}"/.local/state/zsh/history

PYENV_ROOT="${XDG_DATA_HOME}"/pyenv
PATH="${PYENV_ROOT}"/bin:"${PATH}"

PATH="${XDG_DATA_HOME}"/npm/bin:"${PATH}"
PATH="${GOPATH}/bin:$PATH"
# PATH="${ASDF_DATA_DIR}"/shims:$PATH
PATH="${HOME}"/.local/bin:"${PATH}"


TERM='xterm-256color'

LS_COLORS=$LS_COLORS:'di=0;34:'

MAKEFLAGS='--jobs=4'

BROWSER='firefox'
EDITOR='nvim'
MANPAGER='nvim +Man!'
MANWIDTH=9999
VISUAL=$EDITOR
PAGER='less'
BAT_THEME="gruvbox-dark"
GCM_CREDENTIAL_STORE=secretservice
