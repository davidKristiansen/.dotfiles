export FZF_DEFAULT_COMMAND='rg --files --follow --no-ignore-vcs --hidden -g "!{node_modules/*,.git/*,.venv/*}"'


function find_f () {
  nvim -c ':FzfLua files'
}

zvm_define_widget find_f

bindkey -M vicmd '^f' find_f

# bindkey '^e' find_f
