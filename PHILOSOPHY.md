# PHILOSOPHY

This document explains some decisions I made, rules that should be followed, etc.

## Credits

These dotfiles were heavily influenced by [carlos' dotfiles](https://github.com/caarlos0/dotfiles). As time went by, I changed some things and diverged.

## Decisions

### Modules

Everything is built around modules. If you're adding a new area to your forked dotfiles — say, "Erlang" — you can simply add a `erlang` directory and put files in there.

### Naming conventions

There are a few special files in the hierarchy:

- **bin/**: Anything in `bin/` will get added to your `${PATH}` and be made available everywhere.

- **module/aliases.zsh**: This file is loaded automatically and contains aliases and functions for that module.

- **module/envvars.zsh**: This file is loaded automatically and contains environmental variables for that module.

- **module/paths.zsh**: This file is loaded automatically and sets up `${PATH}` for that module.

- **module/prompt.zsh**: This file is loaded automatically and sets up prompt for that module.

- **module/history.zsh**: This file is loaded automatically and sets up shell history for that module.

- **module/autorun.zsh**: This file is loaded automatically after everything else is loaded.

- **module/install.sh**: This file will be run at `installation/bootstrap` and `bin/dot_update` phase, and is expected to link necessary files and do post-installation actions (such as restart an agent, etc).

- **themes/**: This folder contains theme palette files which are used by programs (such as `tmux`, `fzf`, etc).

### Creating new module

To create new module, you have to create new directory in modules directory. Every module should contain an installation script called `install.sh`. All installation logic should be there. If nothing has to be done, it's a good practice to at least inform the user about the module.

The installation script will be called automatically from the `installation/bootstrap` and every time `bin/dot_update` is called.

These files will be loaded automatically by ZSH itself:

- `autorun.zsh`
- `aliases.zsh`
- `envvars.zsh`
- `paths.zsh`
- `prompt.zsh`
- `history.zsh`

Other files have to be managed by the installation script.

#### Helper functions

These helper functions are available to you by default:

- success()
- fail()
- info()
- skipped()
- report_status()
- string_replace()
- backup_file()
- link_file()
- os_detection()
- macos_version()
- is_installed()
- check_sw_prerequisites()
- prompt_component_precmd_append()
- prompt_component_postexec_append()
- prompt_set_postcmd_components_visibility()
- is_dark_mode_on()
- load_theme_colors()
- require_version()

### Compatibility

I try to keep it working in both macOS, Linux and AIX, mostly because I use macOS at home and Linux/AIX at work.
