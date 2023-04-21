#   -------------------------------
#   11.  MODULE AUTORUN FILES
#   -------------------------------

    if ! is_installed "fzf"; then
        return
    fi

    case "${DOTFILES_OS}" in
        "${DOTFILES_OS_MACOS}")
            # shellcheck disable=SC1091
            [[ -f "${HOME}/.fzf.zsh" ]] && source "${HOME}/.fzf.zsh"
        ;;

        "${DOTFILES_OS_LINUX}")
            # shellcheck disable=SC1091
            [[ -f /usr/share/zsh/site-functions/fzf ]] && source /usr/share/zsh/site-functions/fzf
            # shellcheck disable=SC1091
            [[ -f /usr/share/fzf/shell/key-bindings.zsh ]] && source /usr/share/fzf/shell/key-bindings.zsh
        ;;
    esac
