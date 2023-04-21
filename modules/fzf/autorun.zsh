#   -------------------------------
#   11.  MODULE AUTORUN FILES
#   -------------------------------

    if ! is_installed "fzf"; then
        return
    fi

    case "${DOTFILES_OS}" in
        "${DOTFILES_OS_MACOS}")
            [[ -f "${HOME}/.fzf.zsh" ]] && source "${HOME}/.fzf.zsh"
        ;;

        "${DOTFILES_OS_LINUX}")
            [[ -f /usr/share/zsh/site-functions/fzf ]] && source /usr/share/zsh/site-functions/fzf
            [[ -f /usr/share/fzf/shell/key-bindings.zsh ]] && source /usr/share/fzf/shell/key-bindings.zsh
        ;;
    esac
