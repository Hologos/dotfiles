    function update_tmux_histfile_variable() {
        export TMUX_HISTFILE_PREFIX="${TMUX_HISTDIR}/.zhistory_"
        export HISTFILE="${TMUX_HISTFILE_PREFIX}${TMUX_SWP_ID}"
    }

    # function reload_tmux_shell_history() {
    #     fc -R
    # }

    function update_tmux_shell_history_in_pane() {
        OLD_TMUX_SWP_ID="${TMUX_SWP_ID}"
        export TMUX_SWP_ID="$(get_tmux_swp_id)"

        update_tmux_histfile_variable
        __switcheroo_tmux_histfile "${OLD_TMUX_SWP_ID}" "${TMUX_SWP_ID}"
        #reload_tmux_shell_history
    }

    function update_tmux_shell_history_in_current_session() {
        local session_name swp_id

        swp_id="$(get_tmux_swp_id)"
        session_name="$(__get_tmux_swp_session_name "${swp_id}")"

        # BUG: neposílat to přes send-keys, ale přes environment, protože mi může něco běžet
        # BUG: pošle to i na SSH servery, co taky nechceš
        # tmux list-panes -F '#{pane_active} #{pane_pid}' přes všechny window a ověřit,
        #   co tam běží (ssh, less, etc.. prakticky by to mělo dovolit jen zsh/bash)
        #   pokud tam něco běží, tak to má udělat markfile a zobrazit prompt komponentu,
        #   že se neprovedlo nahrazení histfilu
        # po každém příkazu možná ověřit, jestli souhlasí SWP_ID a pokud ne, zobrazit prompt komponentu
        send_command_to_all_tmux_panes_in_session "${session_name}" "update_tmux_shell_history_in_pane"
    }

    function __tmux_create_histfile_markfile() {
        local swp_id="${1}"
        local markfile="${TMUX_HISTFILE_PREFIX}${swp_id}.markfile"

        touch "${markfile}"
    }

    function __tmux_remove_histfile_markfile() {
        local swp_id="${1}"
        local markfile="${TMUX_HISTFILE_PREFIX}${swp_id}.markfile"

        if [[ -e "${markfile}" ]]; then
            echo "deleting markfile [${markfile}]"
            rm -f "${markfile}"
        fi
    }

    function __tmux_exists_histfile_markfile() {
        local swp_id="${1}"

        if [[ -e "${TMUX_HISTFILE_PREFIX}${swp_id}.markfile" ]]; then
            return 0
        fi

        return 1
    }

    function __switcheroo_tmux_histfile() {
        local old_tmux_swp_id="${1}"
        local new_tmux_swp_id="${2}"

        # TODO: je nutné detekovat směr, jestli dopředu nebo dozadu

        # TODO: může se jedna o kill/create okna nebo kill/create pane

        # je tam hook, který se vyvolá, když aktivní proces skončí, to by šlo použít na ty panes, kde něco běží (např. ssh, less, atp)

        echo "Old TMUX_SWP_ID=[${old_tmux_swp_id}]"
        echo "New TMUX_SWP_ID=[${new_tmux_swp_id}]"

        if [[ "${old_tmux_swp_id}" == "${new_tmux_swp_id}" ]]; then
            echo "No need to do a switcheroo with hist files."
            return
        fi

        echo "Executing switcheroo"

        local old_histfile_filepath="${TMUX_HISTFILE_PREFIX}${old_tmux_swp_id}"
        local new_histfile_filepath="${TMUX_HISTFILE_PREFIX}${new_tmux_swp_id}"

        if __tmux_exists_histfile_markfile "${new_tmux_swp_id}"; then
            # skip switcheroo
            echo "Skipping switcheroo"
            __tmux_remove_histfile_markfile "${new_tmux_swp_id}"
        elif [[ -e "${new_histfile_filepath}" ]]; then
            echo "Doing switcheroo"
            local switcheroo_filepath="${new_histfile_filepath}.switcheroo"
            mv "${new_histfile_filepath}" "${switcheroo_filepath}"
            mv "${old_histfile_filepath}" "${new_histfile_filepath}"
            mv "${switcheroo_filepath}" "${old_histfile_filepath}"
            __tmux_create_histfile_markfile "${old_tmux_swp_id}"
        else
            echo "Just moving hist file"
            mv "${old_histfile_filepath}" "${new_histfile_filepath}"
        fi
    }


#echo $HISTFILE; echo; echo "==HISTFILE=="; cat $HISTFILE; echo; echo "==HISTORY=="; hist 1
