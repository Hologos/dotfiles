_reconstruct_tmux_resurrect_completions() {
    local cur prev words cword
    _init_completion || return

    local actions="build analyse compare"

    case "${COMP_CWORD}" in
        1)
            COMPREPLY=( $(compgen -W "${actions}" -- "$cur") )
            return
            ;;
        2)
            # After action, suggest filepaths
            case "${COMP_WORDS[1]}" in
                build|analyse)
                    _filedir
                    return
                    ;;
                compare)
                    _filedir
                    return
                    ;;
            esac
            ;;
        3)
            if [[ "${COMP_WORDS[1]}" == "compare" ]]; then
                _filedir
                return
            fi
            ;;
    esac
}

complete -F _reconstruct_tmux_resurrect_completions reconstruct_tmux_resurrect
