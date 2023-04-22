#! /usr/bin/env bash

function success() {
    local message="$(echo "${1}" | string_replace --global "${HOME}" "~")"

    printf "\r\033[2K  [  \033[00;32mOK\033[0m  ] %s\n" "${message}"
}

function fail() {
    local message="$(echo "${1}" | string_replace --global "${HOME}" "~")"

    printf "\r\033[2K  [ \033[0;31mFAIL\033[0m ] %s\n" "${message}"
}

function info() {
    local message="$(echo "${1}" | string_replace --global "${HOME}" "~")"

    printf "\r  [ \033[00;33mINFO\033[0m ] %s\n" "${message}"
}

function skipped() {
    local message="$(echo "${1}" | string_replace --global "${HOME}" "~")"

    printf "\r  [ \033[00;34mSKIP\033[0m ] %s\n" "${message}"
}

function report_status() {
    local rc_of_last_command="${?}" # ! has to be on the 1st line

    local message_success="${1}"
    local message_failure="${1}"

    if [[ ${#} -eq 2 ]]; then
        message_failure="${2}"
    fi

    if [[ ${rc_of_last_command} -eq 0 ]]; then
        success "${message_success}"
    else
        fail "${message_failure}"
    fi
}

function report_install() {
    local sw_name="${1}"

    ansi --no-newline "› "
    ansi --magenta "installing ${sw_name} module"
}

function string_replace() {
    local search=""
    local replace=""
    local subject=""
    local global=""

    local search_found=0
    local replace_found=0

    while [[ ${#} -ne 0 ]] && [[ "${1}" != "" ]]; do
        case ${1} in
            --global)
                global="g"
            ;;

            *)
                if [[ ${search_found} -eq 0 ]]; then
                    search="${1}"
                    search_found=1
                elif [[ ${replace_found} -eq 0 ]]; then
                    replace="${1}"
                    replace_found=1
                else
                    >&2 echo "Unknown input argument."
                    return 1
                fi
            ;;
        esac

        shift
    done

    read subject < /dev/stdin

    local search_quoted="$(printf '%s' "${search}" | sed 's/[#\]/\\\0/g')"
    local replace_quoted="$(printf '%s' "${replace}" | sed 's/[#\]/\\\0/g')"
    local subject_quoted="$(printf '%s' "${subject}" | sed 's/[#\]/\\\0/g')"

    if [[ "${search_quoted}" == "" ]]; then
        >&2 echo "Search cannot be empty."
        return 1
    elif [[ "${replace_quoted}" == "" ]]; then
        >&2 echo "Replace cannot be empty."
        return 1
    elif [[ "${subject_quoted}" == "" ]]; then
        >&2 echo "Subject cannot be empty."
        return 1
    fi

    echo "${subject_quoted}" | sed "s#${search_quoted}#${replace_quoted}#${global}"
}

function backup_file() {
    local backup_file="${1}"

    if [[ ! -e "${backup_file}" ]]; then
        info "no backup needed (${backup_file} doesn't exist)"
        return 0
    fi

    mv "${backup_file}" "${backup_file}.backup"
    report_status "backing up ${backup_file}"
}

function link_file() {
    local source="${1}"
    local target="${2}"

    if [[ "$(readlink "${target}")" == "${source}" ]]; then
        skipped "no need to link ${source}, it's already symlinked"
        return 0
    fi

    backup_file "${target}"

    local dirpath="$(dirname "${target}")"

    if [[ ! -d "${dirpath}" ]]; then
        mkdir -p "${dirpath}"
        report_status "creating directory ${dirpath} for target ${target}"
    fi

    ln -nfs "${source}" "${target}"
    report_status "linking ${source} to ${target}"
}

function os_detection() {
    export DOTFILES_OS="undefined"

    readonly DOTFILES_OS_MACOS="macos"
    readonly DOTFILES_OS_LINUX="linux"
    readonly DOTFILES_OS_AIX="aix"
    readonly DOTFILES_OS_WINDOWS="windows"

    export DOTFILES_OS_MACOS
    export DOTFILES_OS_LINUX
    export DOTFILES_OS_AIX
    export DOTFILES_OS_WINDOWS

    case "$(uname -s)" in
        Darwin) DOTFILES_OS="${DOTFILES_OS_MACOS}" ;;
         Linux) DOTFILES_OS="${DOTFILES_OS_LINUX}" ;;
           AIX) DOTFILES_OS="${DOTFILES_OS_AIX}" ;;
    esac
}

function macos_version() {
    sw_vers -productVersion
}

function is_installed() {
    command which "${1}" &> /dev/null && return 0

    # consider using -s flag
    # command which -s "${1}" && return 0

    return 1
}

function check_sw_prerequisites() {
    echo "› checking sw prerequisites"

    prerequisites_error=0

    for sw in "${@}"; do
        if ! is_installed "${sw}"; then
            prerequisites_error=1

            fail "${sw} is not installed"
        else
            success "${sw} is installed"
        fi
    done

    if [[ ${prerequisites_error} -ne 0 ]]; then
        fail "prerequisites are not met, aborting"
        return 1
    fi
}

function require_version() {
    local version_parts_count=4

    function _require_version::error() {
        local message="${1}"

        >&2 printf 'ERROR: %s.' "${message}"
    }

    function _require_version::check_format() {
        local version="${1}"

        if ! [[ "${version}" =~ ^[0-9]+(.[0-9]+){0,3}$ ]]; then
            return 1
        fi
    }

    function _require_version::process_version() {
        local version_string="${1}"

        local version_array=( $(printf '%s' "${version_string}" | tr "." " ") )

        if [[ "${#version_array[@]}" -ne "${version_parts_count}" ]]; then
            while [[ ${#version_array[@]} -ne "${version_parts_count}" ]]; do
                version_array+=( "0" )
            done
        fi

        printf '%s' "$(IFS="."; printf '%s' "${version_array[*]}")"
    }

    function _require_version::get_version_part() {
        local version_string="${1}"
        local part_nr="${2}"

        printf '%s' "${1}" | tr '.' "\n" | sed -n "${part_nr}p"
    }

    function _require_version::require_equal() {
        local version_part_index=1

        local current_version_part
        local required_version_part

        while [[ "${version_part_index}" -le "${version_parts_count}" ]]; do
            current_version_part="$(_require_version::get_version_part "${current_version}" "${version_part_index}")"
            required_version_part="$(_require_version::get_version_part "${required_version}" "${version_part_index}")"

            # not equal version = no need to check any further -> fail
            if [[ "${current_version_part}" -ne "${required_version_part}" ]]; then
                return 1
            fi

            version_part_index=$(( version_part_index + 1 ))
        done

        return 0
    }

    function _require_version::require_higher() {
        local version_part_index=1

        local current_version_part
        local required_version_part

        while [[ "${version_part_index}" -le "${version_parts_count}" ]]; do
            current_version_part="$(_require_version::get_version_part "${current_version}" "${version_part_index}")"
            required_version_part="$(_require_version::get_version_part "${required_version}" "${version_part_index}")"

            # greater version = no need to check any further -> success
            if [[ "${current_version_part}" -gt "${required_version_part}" ]]; then
                return 0
            # lower version = no need to check any further -> fail
            elif [[ "${current_version_part}" -lt "${required_version_part}" ]]; then
                return 1
            fi

            version_part_index=$(( version_part_index + 1 ))
        done

        return 2
    }

    function _require_version::require_higher_or_equal() {
        _require_version::require_higher
        local rc="${?}"

        if [[ "${rc}" -eq 1 ]]; then
            return 1
        fi

        return 0
    }

    function _require_version::require_lower() {
        _require_version::require_higher_or_equal && return 1
    }

    function _require_version::require_lower_or_equal() {
        _require_version::require_higher && return 1
    }

    function _require_version::require_not_equal() {
        _require_version::require_equal && return 1
    }

    if [[ "${#}" -ne 3 ]]; then
        _require_version::error "Incorrect number of arguments, required [3], given [${#}]."
        return 1
    fi

    local current_version="${1}"
    local comparison="${2}"
    local required_version="${3}"

    if ! _require_version::check_format "${current_version}"; then
        _require_version::error "Unsupported current version format [${current_version}]."
    fi

    if ! _require_version::check_format "${required_version}"; then
        _require_version::error "Unsupported required version format [${required_version}]."
    fi

    current_version="$(_require_version::process_version "${current_version}")"
    required_version="$(_require_version::process_version "${required_version}")"

    case "${comparison}" in
        "="  ) _require_version::require_equal ;;
        ">"  ) _require_version::require_higher ;;
        ">=" ) _require_version::require_higher_or_equal ;;
        "!=" ) _require_version::require_not_equal ;;
        "<"  ) _require_version::require_lower ;;
        "<=" ) _require_version::require_lower_or_equal ;;

        * )
            _require_version::error "Unknown comparison [${comparison}]."
            return 1
    esac
}

function prompt_component_precmd_append() {
    local component="${1}"

    DOTFILES_PROMPT_PRECMD_COMPONENTS+=("${component}")
}

function prompt_postexec_component_append() {
    local component="${1}"

    DOTFILES_PROMPT_POSTEXEC_COMPONENTS+=("${component}")
}


function prompt_set_postcmd_components_visibility() {
    local prompt_status="${1}"

    DOTFILES_PROMPT_SHOW_POSTCMD_COMPONENTS="${prompt_status}"
}


function crontab_apply() {
    if ! is_installed "crontab"; then
        fail "crontab is not installed, aborting"
        return 1
    fi

    local crontab_command="${1}"
    local grep_match="${2}"

    (
        crontab -l | grep -v "${grep_match}"
        echo "${crontab_command}"
    ) | crontab -
}

function is_dark_mode_on() {
    case "${DOTFILES_OS}" in
        "${DOTFILES_OS_MACOS}")
            defaults read -g AppleInterfaceStyle &> /dev/null
        ;;

        *)
            return 1
    esac
}

function load_theme_colors() {
    # in case color palette is not found, set a horrible one to notice
    local theme_fg="#ffffff"
    local theme_bg="#ff0000"
    local theme_primary_fg="#000000"
    local theme_primary_bg="#00ff00"
    local theme_secondary_fg="#ffffff"
    local theme_secondary_bg="#000000"
    local theme_tertiary_fg="#ffffff"
    local theme_tertiary_bg="#0000ff"

    local has_loading_failed=0

    # TODO: use constants
    local theme="light"

    if is_dark_mode_on; then
        theme="dark";
    fi

    local theme_filepath="${DOTFILES_THEMES_ROOT}/palette.${theme}.conf"

    if [[ -r "${theme_filepath}" ]]; then
        source "${theme_filepath}" &> /dev/null || has_loading_failed=1
    fi

    export DOTFILES_THEME_FG="${theme_fg}"
    export DOTFILES_THEME_BG="${theme_bg}"
    export DOTFILES_THEME_PRIMARY_FG="${theme_primary_fg}"
    export DOTFILES_THEME_PRIMARY_BG="${theme_primary_bg}"
    export DOTFILES_THEME_SECONDARY_FG="${theme_secondary_fg}"
    export DOTFILES_THEME_SECONDARY_BG="${theme_secondary_bg}"
    export DOTFILES_THEME_TERTIARY_FG="${theme_tertiary_fg}"
    export DOTFILES_THEME_TERTIARY_BG="${theme_tertiary_bg}"

    return ${has_loading_failed}
}
