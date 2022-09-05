#   -----------------------------
#   4.  ALIASES
#   -----------------------------

#   -----------------------------
#   5.  FUNCTIONS
#   -----------------------------

    function is_inside_tmux() {
        if [[ -z ${TMUX+x} ]]; then
            return 1
        fi

        return 0
    }

    function get_tmux_swp_id() {
        if ! is_installed "tmux"; then
            return
        fi

        if ! is_inside_tmux; then
            return;
        fi

        tmux display -pt "${TMUX_PANE:?}" '#{session_name}:#{window_index}:#{pane_index}'
    }
