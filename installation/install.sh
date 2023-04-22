#! /usr/bin/env bash

echo
echo "Running generic installer"

find "${DOTFILES_MODULES_ROOT}" -name "install.sh" |
    while read -r module_install_file; do
        . "${module_install_file}"
    done
