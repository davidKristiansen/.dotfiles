export FZF_LUA_CLI="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/pack/core/opt/fzf-lua/scripts/cli.lua"

FzfLua() { ${NVIM:-nvim} -l "$FZF_LUA_CLI" $@ </dev/tty | jq -r ".[] | .path" }
eval_widget() {
    eval "${1}() {
        local res=\$(FzfLua ${2} | while read -r line; do; echo -n -E \"\${(q)line} \"; done);
        zle reset-prompt;
        LBUFFER+=\$res
    }"
    eval "zle -N ${1}"
}
typeset -A git_prefix
typeset -A fzf_widgets
git_prefix=(g git y yadm)
fzf_widgets=(l lgrep s status c commits b branches h hunks)
for k_prefix cmd_prefix in "${(@kv)git_prefix}"; do
    local prefix="^${k_prefix}"
    eval "bindkey -r '$prefix'"
    for k v in "${(@kv)fzf_widgets}"; do
        local cmd="${cmd_prefix}_${v}"
        local wn="_fzf_${cmd}"
        eval_widget ${wn} ${cmd}
        for m in emacs vicmd viins; do
            eval "bindkey -M $m '$prefix^${k}' ${wn}"
            eval "bindkey -M $m '$prefix${k}' ${wn}"
        done
    done
done

function _fzf_files_open_nvim() {
    ${NVIM:-nvim} -l "$FZF_LUA_CLI" files </dev/tty
    zle reset-prompt
}
zle -N _fzf_files_open_nvim
for m in emacs vicmd viins; do
    eval "bindkey -M $m '^f' _fzf_files_open_nvim"
done

fzf_widgets=(p files g live_grep)
for key cmd in "${(@kv)fzf_widgets}"; do
    local wn="_fzf_${cmd}"
    eval_widget ${wn} ${cmd}
    for m in emacs vicmd viins; do
        eval "bindkey -M $m '^${key}' ${wn}"
    done
done
function _fzf_zoxide() {
    local res; res="$(FzfLua zoxide $@)" && __zoxide_cd "${res}";
    zle accept-line;
}
zle -N _fzf_zoxide
for m in emacs vicmd viins; do
    eval "bindkey -M $m '^K' _fzf_zoxide"
done
