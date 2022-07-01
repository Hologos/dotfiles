#   -----------------------------
#   0.  SHELL CONFIGURATION
#   -----------------------------

#   ___ failed to load shell detection ___
    FAILED_TO_LOAD_SHELL_MARKFILE_FILEPATH="${HOME}/.zsh_failed"
    export FAILED_TO_LOAD_SHELL_IGNOREFILE_FILEPATH="${HOME}/.zsh_failed_ignore"

    # to prevent false positive when restoring via tmux-resurrect,
    # tmux hook creates ignore file before restoration and deletes it after restoration
    if [[ ! -e "${FAILED_TO_LOAD_SHELL_IGNOREFILE_FILEPATH}" ]] && [[ -e "${FAILED_TO_LOAD_SHELL_MARKFILE_FILEPATH}" ]]; then
        >&2 echo
        >&2 echo "--------------------------------------------"
        >&2 echo "| An error detected last time zsh was run. |"
        >&2 echo "--------------------------------------------"
        >&2 echo
        >&2 echo "To prevent loosing access to shell, not loading anything."
        >&2 echo "Investigate the error and fix it."
        >&2 echo
        >&2 echo "To load everything, remove mark file '${FAILED_TO_LOAD_SHELL_MARKFILE_FILEPATH}' and run zsh."
        >&2 echo

        # stop this script
        return
    fi

    touch "${FAILED_TO_LOAD_SHELL_MARKFILE_FILEPATH}"

#   ___ configuration ___
    # setopt autocd                             # if a command is issued that can't be executed as a normal command, and the command is the name of a directory, perform the cd command to that directory
    setopt nomatch                              # if a pattern for filename generation has no matches, print an error, instead of leaving it unchanged in the argument list
    setopt notify                               # report the status of background jobs immediately, rather than waiting until just before printing a prompt
    setopt extendedglob                         # treat the '#', '~' and '^' characters as part of patterns for filename generation, etc (an initial unquoted '~' always produces named directory expansion)
    setopt correct                              # try to correct the spelling of commands
    setopt PROMPT_SUBST                         # do expansion on prompt
    setopt globdots                             # suggest files beginning with dot in completion

    bindkey -v                                  # vi mode

    zstyle :compinstall filename "${HOME}/.zshrc"

    autoload -Uz compinit
    compinit

#   -----------------------------
#   1.  UNDER THE HOOD STUFF
#   -----------------------------

    export DOTFILES_ROOT="${HOME}/.dotfiles"
    export DOTFILES_LIBS_ROOT="${DOTFILES_ROOT}/libs"
    export DOTFILES_MODULES_ROOT="${DOTFILES_ROOT}/modules"
    export DOTFILES_THEMES_ROOT="${DOTFILES_ROOT}/themes"
    export DOTFILES_INSTALLATION_ROOT="${DOTFILES_ROOT}/installation"

    . "${DOTFILES_LIBS_ROOT}/fidian/ansi/ansi"
    . "${DOTFILES_LIBS_ROOT}/formatting.sh"
    . "${DOTFILES_LIBS_ROOT}/helpers.sh"

    os_detection
    load_theme_colors

#   -----------------------------
#   8.  MODULE CONFIGS
#   -----------------------------

#   ___ load environmental variables from all envvars.zsh files ___
    for envvar_file in $(find "${DOTFILES_MODULES_ROOT}" -name "envvars.zsh"); do
        source "${envvar_file}"
    done

#   ___ load paths from all paths.zsh files ___
    for path_file in $(find "${DOTFILES_MODULES_ROOT}" -name "paths.zsh"); do
        source "${path_file}"
    done

#   ___ load aliases from all aliases.zsh files ___
    for alias_file in $(find "${DOTFILES_MODULES_ROOT}" -name "aliases.zsh"); do
        source "${alias_file}"
    done

#   ___ load history from all history.zsh files ___
    source "${DOTFILES_MODULES_ROOT}/zsh/history.zsh"

    for history_file in $(find "${DOTFILES_MODULES_ROOT}" -name "history.zsh" | grep -v -E 'zsh\/history\.zsh$'); do
        source "${history_file}"
    done

#   ___ load prompts from all prompt.zsh files ___
    source "${DOTFILES_MODULES_ROOT}/zsh/prompt.zsh"

    for prompt_file in $(find "${DOTFILES_MODULES_ROOT}" -name "prompt.zsh" | grep -v -E 'zsh\/prompt\.zsh$'); do
        source "${prompt_file}"
    done

#   -----------------------------
#   9.  LOAD LOCAL CONFIG
#   -----------------------------

#   ___ use .localrc for local configuration ___
    [[ -f "${HOME}/.localrc" ]] && . "${HOME}/.localrc"

#   -----------------------------
#   10.  RUN PROGRAMS / COMMANDS
#   -----------------------------

#   ___ display dotfiles version ___
    dotfiles_version

#   -----------------------------
#   11.  MODULE AUTORUN FILES
#   -----------------------------

#   ___ run all autorun.zsh files ___
    for autorun_file in $(find "${DOTFILES_MODULES_ROOT}" -name "autorun.zsh"); do
        source "${autorun_file}"
    done

    __prompt_set_shell_has_just_started_status

#   -----------------------------
#   99.  POST-LOAD ACTIONS
#   -----------------------------

#   ___ remove failed to load shell mark file ___
    rm -rf "${FAILED_TO_LOAD_SHELL_MARKFILE_FILEPATH}" &> /dev/null
