    function update_tmux_histfile_variable() {
        export TMUX_HISTFILE_PREFIX="${TMUX_HISTDIR}/.zhistory_"
        export HISTFILE="${TMUX_HISTFILE_PREFIX}${TMUX_SWP_ID}"
    }
