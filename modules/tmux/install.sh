#! /usr/bin/env bash

report_install "tmux"

link_file "${DOTFILES_MODULES_ROOT}/tmux/.tmux.conf" "${HOME}/.tmux.conf"

if [[ ! -d "${HOME}/.tmux" ]]; then
    mkdir -p "${HOME}/.tmux"
    report_status "creating directory ${HOME}/.tmux"
fi

link_file "${DOTFILES_MODULES_ROOT}/tmux/conf" "${HOME}/.tmux/conf"

success "installation complete"

if ! is_installed "tmux"; then
    skipped "tmux is not installed, post-installation steps won't be run"
    return
fi

# TODO: změnit user za dotfiles_user
# TODO: myslet, že někdo může migrovat ze starší verze!
crontab_apply \
    "* * * * * '${DOTFILES_ROOT}/bin/tmux_set_theme' cron >> /tmp/tmux_set_theme.${USER}.log 2>&1" \
    "tmux_set_theme"

report_status "applying crontab job"

if [[ -x "${HOME}/.tmux/plugins/tpm/bin/install_plugins" ]]; then
    "${HOME}/.tmux/plugins/tpm/bin/install_plugins"
    report_status "installing plugins"
else
    skipped "installing plugin (tpm is not installed)"
fi

# reload config
tmux source-file ~/.tmux.conf
report_status "reloading configuration"

success "post-installation steps completed"
