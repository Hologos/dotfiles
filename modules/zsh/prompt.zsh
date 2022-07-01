#   -------------------------------
#   7.  PROMPT
#   -------------------------------

    DOTFILES_PROMPT_PRECMD_COMPONENTS=()
    DOTFILES_PROMPT_POSTEXEC_COMPONENTS=()
    DOTFILES_PROMPT_COMPONENT_LEFT="─["
    DOTFILES_PROMPT_COMPONENT_RIGHT="]"
    DOTFILES_PROMPT_SHOW_POSTCMD_COMPONENTS=1

#   ___ prompt generation ___
    function prompt_generate() {
        PS1=""

        # postexec components
        for component in ${DOTFILES_PROMPT_POSTEXEC_COMPONENTS[@]}; do
            PS1+="${component}"
        done

        # precmd components
        PS1+=$'\n'
        PS1+="┌──"

        for component in ${DOTFILES_PROMPT_PRECMD_COMPONENTS[@]}; do
            PS1+="${component}"
        done

        PS1+=$'\n'
        PS1+="└─▶ "

        PS2="└─▶ "
    }

#   ___ preexec prompt settings ___
    function __prompt_gen_layout_pre() {
        if ! __prompt_should_show_postcmd_components; then
            return
        fi

        echo " " # empty line
        echo "┬"
        echo -n "└──"
    }

    function __prompt_gen_layout_post() {
        if ! __prompt_should_show_postcmd_components; then
            return
        fi

        echo " " # empty line
        echo " " # empty line
        echo " " # empty line
        echo " " # empty line
    }

    function __prompt_last_command_rc() {
        if ! __prompt_should_show_postcmd_components; then
            return
        fi

        local last_rc="${?}"

        echo -n "${DOTFILES_PROMPT_COMPONENT_LEFT}"
        ansi --no-newline --bold "rc: "

        if [[ -z "${prompt_set_last_rc+_}" ]]; then
            ansi --no-newline --color="${FMT_ORANGE}" "no command executed"
        elif [[ ${last_rc} -ne 0 ]]; then
            ansi --no-newline --color="${FMT_RED}" "${last_rc}"
        else
            ansi --no-newline --color="${FMT_GREEN}" "${last_rc}"
        fi

        echo -n "${DOTFILES_PROMPT_COMPONENT_RIGHT}"
    }

    function __prompt_last_command_elapsed_time() {
        if ! __prompt_should_show_postcmd_components; then
            return
        fi

        if [[ -z "${prompt_elapsed_time+_}" ]]; then
            return
        fi

        echo -n "${DOTFILES_PROMPT_COMPONENT_LEFT}"
        ansi --no-newline --bold "start: "
        ansi --no-newline "${prompt_command_start_time}"
        echo -n "${DOTFILES_PROMPT_COMPONENT_RIGHT}"

        echo -n "${DOTFILES_PROMPT_COMPONENT_LEFT}"
        ansi --no-newline --bold "finish: "
        ansi --no-newline "${prompt_command_finish_time}"
        echo -n "${DOTFILES_PROMPT_COMPONENT_RIGHT}"

        echo -n "${DOTFILES_PROMPT_COMPONENT_LEFT}"
        ansi --no-newline --bold "runtime: "
        ansi --no-newline "${prompt_elapsed_time}"
        echo -n "${DOTFILES_PROMPT_COMPONENT_RIGHT}"
    }

    function __last_command_elapsed_time() {
        if [[ ! -z "${prompt_prexec_realtime+_}" ]]; then
            local -rF elapsed_realtime="$(( EPOCHREALTIME - prompt_prexec_realtime ))"
            local -rF s="$(( elapsed_realtime % 60 ))"
            local -ri elapsed_s="${elapsed_realtime}"
            local -ri m="$(( (elapsed_s / 60) % 60 ))"
            local -ri h="$(( elapsed_s / 3600 ))"

            if (( h > 0 )); then
                printf -v prompt_elapsed_time '%ih%im' "${h}" "${m}"
            elif (( m > 0 )); then
                printf -v prompt_elapsed_time '%im%is' "${m}" "${s}"
            elif (( s >= 10 )); then
                printf -v prompt_elapsed_time '%.2fs' "${s}" # 12.34s
            elif (( s >= 1 )); then
                printf -v prompt_elapsed_time '%.3fs' "${s}" # 1.234s
            else
                printf -v prompt_elapsed_time '%ims' "$(( s * 1000 ))"
            fi

            unset prompt_prexec_realtime
        else
            # clear previous result when hitting ENTER with no command to execute
            unset prompt_elapsed_time
        fi
    }

    function __last_command_rc() {
        if [[ ! -z "${prompt_last_command_executed+_}" ]]; then
            prompt_set_last_rc=1
            unset prompt_last_command_executed
        else
            unset prompt_set_last_rc
        fi
    }

    function __prompt_preexec() {
        prompt_last_command_executed=1
        prompt_prexec_realtime="${EPOCHREALTIME}"
        prompt_command_start_time="$(date +'%H:%M:%S - %d.%m.%Y')"
    }

    function __prompt_precmd() {
        local last_cmd

        __last_command_elapsed_time
        __last_command_rc

        prompt_command_finish_time="$(date +'%H:%M:%S - %d.%m.%Y')"
        last_cmd="$(fc -ln -1)"

        if __prompt_has_shell_just_started; then
            prompt_set_postcmd_components_visibility 0
        elif [[ "${last_cmd}" =~ clear[[:space:]]*$ ]]; then
            prompt_set_postcmd_components_visibility 0
        else
            prompt_set_postcmd_components_visibility 1
        fi
    }

    function __prompt_should_show_postcmd_components() {
        if [[ ${DOTFILES_PROMPT_SHOW_POSTCMD_COMPONENTS} -eq 0 ]]; then
            return 1
        else
            return 0
        fi
    }

    function __prompt_has_shell_just_started() {
        if [[ ${DOTFILES_PROMPT_SHOW_POSTCMD_COMPONENTS} -eq -1 ]]; then
            return 0
        fi

        return 1
    }

    function __prompt_set_shell_has_just_started_status() {
        prompt_set_postcmd_components_visibility -1
    }

#   ___ setting preexec & precmd hooks ___
    zmodload zsh/datetime

    setopt nopromptbang prompt{cr,percent,sp,subst}

    autoload -Uz add-zsh-hook
    add-zsh-hook preexec __prompt_preexec
    add-zsh-hook precmd __prompt_precmd

#   ___ username + hostname ___
    dotfiles_prompt_username_hostname=""
    dotfiles_prompt_username_hostname+="${DOTFILES_PROMPT_COMPONENT_LEFT}"

    # highlight the username when logged in as root
    if [[ "${UID}" -eq 0 ]]; then
        dotfiles_prompt_username_hostname+="$(ansi --no-newline --bold --color=${FMT_RED} "%n")"
    else
        dotfiles_prompt_username_hostname+="$(ansi --no-newline --bold "%n")"
    fi

    dotfiles_prompt_username_hostname+="$(ansi --no-newline --bold "@")"
    dotfiles_prompt_username_hostname+="$(ansi --no-newline --bold "%m")"
    dotfiles_prompt_username_hostname+="${DOTFILES_PROMPT_COMPONENT_RIGHT}"

    prompt_component_precmd_append "${dotfiles_prompt_username_hostname}"

#   ___ working directory full path ___
    dotfiles_prompt_pwd=""
    dotfiles_prompt_pwd+="${DOTFILES_PROMPT_COMPONENT_LEFT}"
    dotfiles_prompt_pwd+="$(ansi --no-newline --bold "%~")"
    dotfiles_prompt_pwd+="${DOTFILES_PROMPT_COMPONENT_RIGHT}"

    prompt_component_precmd_append "${dotfiles_prompt_pwd}"

#   ___ postexec components ___
    prompt_postexec_component_append '$(__prompt_gen_layout_pre)'
    prompt_postexec_component_append '$(__prompt_last_command_rc)'
    prompt_postexec_component_append '$(__prompt_last_command_elapsed_time)'
    prompt_postexec_component_append '$(__prompt_gen_layout_post)'

#   ___ generate the prompt ___
    prompt_generate
