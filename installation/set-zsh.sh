#! /usr/bin/env bash

echo
echo "Setting ZSH as default shell"

# check prerequisites
echo "› checking prerequisites"

if ! is_installed "chsh"; then
    fail "chsh (change-shell) is not installed, aborting"
    exit 1
else
    success "chsh (change-shell) is installed"
fi

echo "› setting path to zsh"

case "${DOTFILES_OS}" in
    "${DOTFILES_OS_MACOS}")
        DOTFILES_SHELL="/opt/homebrew/bin/zsh"
    ;;

    "${DOTFILES_OS_LINUX}")
        DOTFILES_SHELL="/bin/zsh"
    ;;

    "${DOTFILES_OS_AIX}")
        DOTFILES_SHELL="/usr/bin/zsh"
    ;;

    *)
        fail "this OS is not supported"
        return 1
esac

if ! is_installed "${DOTFILES_SHELL}"; then
    skipped "${DOTFILES_SHELL} is not installed"
    return 1
fi

echo "› setting ${DOTFILES_SHELL} as default shell"

case "${DOTFILES_OS}" in
    "${DOTFILES_OS_MACOS}"|"${DOTFILES_OS_LINUX}")
        echo
        chsh -s "${DOTFILES_SHELL}" "${USER}" 1>/dev/null
    ;;

    "${DOTFILES_OS_AIX}")
        echo
        chsh "${USER}" "${DOTFILES_SHELL}" 1>/dev/null
    ;;

    *)
        fail "this OS is not supported"
        return 1
esac

report_status "default shell set to ${DOTFILES_SHELL}" \
              "default shell couldn't be set to ${DOTFILES_SHELL}"
