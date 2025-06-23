#compdef reconstruct_tmux_resurrect

_reconstruct_tmux_resurrect() {
  local context state state_descr line
  typeset -A opt_args

  local -a actions
  actions=(build analyse compare)

  _arguments -C \
    '1:action:(build analyse compare)' \
    '2::first file:->first_file' \
    '3::second file:->second_file'

  case $state in
    first_file)
      case $words[2] in
        build|analyse|compare)
          _path_files -g "*.txt" -/
          ;;
      esac
      ;;
    second_file)
      if [[ $words[2] == compare ]]; then
        _path_files -g "*.txt" -/
      fi
      ;;
  esac
}

_reconstruct_tmux_resurrect "$@"
