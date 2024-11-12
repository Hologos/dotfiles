#! /usr/bin/env bash

if ! __is_unattended_installation; then
    fail "Installation cannot be run unattended, please run it manually."
    exit 1
fi

find "${DOTFILES_MODULES_ROOT}" -name "install.sh" |
    while read -r module_install_file; do
        . "${module_install_file}"
    done
