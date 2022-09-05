#   -----------------------------
#   6.  HISTORY
#   -----------------------------

    if ! is_installed "tmux"; then
        return
    fi

    if ! is_inside_tmux; then
        return;
    fi

    source "${DOTFILES_MODULES_ROOT}/tmux/history-functions.zsh"

    export TMUX_HISTDIR="${HOME}/.zhist"

    if [[ ! -d "${TMUX_HISTDIR}" ]]; then
        mkdir "${TMUX_HISTDIR}"
    fi

    export TMUX_SWP_ID="$(get_tmux_swp_id)"

    echo "Recovering shell history for pane ID ${TMUX_SWP_ID}..."
    update_tmux_histfile_variable
    __tmux_remove_histfile_markfile
    #reload_tmux_shell_history
