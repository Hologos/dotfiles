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

    function __is_valid_tmux_swp_id() {
        local swp_id="${1}"

        if [[ "${swp_id}" =~ ^[^:]+:[^:]+:[^:]+$ ]]; then
            return 0
        fi

        >&2 echo "SWP_ID is not in valid format."
        return 1
    }

    function __get_tmux_swp_session_name() {
        local swp_id="${1}"

        if ! __is_valid_tmux_swp_id "${swp_id}"; then
            printf 'invalid_swp_id'
            return 1
        fi

        printf '%s' "${swp_id}" | cut -d: -f1
    }

    function __get_tmux_swp_window_index() {
        local swp_id="${1}"

        if ! __is_valid_tmux_swp_id "${swp_id}"; then
            printf 'invalid_swp_id'
            return 1
        fi

        printf '%s' "${swp_id}" | cut -d: -f2
    }

    function __get_tmux_swp_pane_index() {
        local swp_id="${1}"

        if ! __is_valid_tmux_swp_id "${swp_id}"; then
            printf 'invalid_swp_id'
            return 1
        fi

        printf '%s' "${swp_id}" | cut -d: -f3
    }

    function send_command_to_all_tmux_panes_in_window() {
        local session_name="${1}"
        local window_index="${2}"
        local command="${3}"

        echo "=== ${session_name}:${window_index} ==="
        tmux list-panes -t "${session_name}:${window_index}" -F '#P' | sort -rn | # reverse on purpose
            while IFS=$'\n' read -r pane_index; do
                echo "=== ${session_name}:${window_index}.${pane_index} ==="
                tmux send-keys -t "${session_name}:${window_index}.${pane_index}" "${command}" C-m
            done
    }

    function send_command_to_all_tmux_panes_in_session() {
        local session_name="${1}"
        local command="${2}"

        echo "=== ${session_name} ==="
        tmux list-windows -t "${session_name}" -F '#I' | sort -rn | # reverse on purpose
            while IFS=$'\n' read -r window_index; do
                send_command_to_all_tmux_panes_in_window "${session_name}" "${window_index}" "${command}"
            done
    }
