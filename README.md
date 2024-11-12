# hologos' dotfiles

*Based on idea of [carlos' dotfiles](https://github.com/caarlos0/dotfiles).*

> Config files for ZSH, vim, git and more.

## Installation

### Requirements

If installing on macOS, this version requires macOS 12.

### Dependencies

First, make sure you have all those things installed:

- `git`: to clone the repo
- `zsh`: to actually run the dotfiles

### Install

Then, run these steps:

```bash
git clone https://github.com/Hologos/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./installation/bootstrap
zsh # or just close and open your terminal again.
```

> All changed files will be backed up with a `.backup` suffix.

## Post-install configuration

TODO: přesunout do sekce DOCS
**Note:** If you want to adopt these dotfiles for yourself, check `ADOPTION.md` file for instructions.

Personal and device specific configuration should be located in `~/.localrc`.

**Examples:**

```bash
#   -----------------------------
#   my personal SW dir
#   -----------------------------
    ISW_SW_DIRPATH="${HOME}/Software"
```

```bash
#   -----------------------------
#   git
#   -----------------------------
    GIT_IDENTITY_LIST+=("<git-author-name>:<git-author-email>:<gpg-signature-key>")
    # or
    GIT_IDENTITY_LIST+=("<git-author-name>:<git-author-email>")
```

```bash
#   -----------------------------
#   ssh keys for this machine
#   -----------------------------
    SSH_KEYS_LIST+=("${HOME}/.ssh/keys/<private-key-filepath>")
```

```bash
 #   -----------------------------
 #   ssh
 #   -----------------------------
     alias _="TERM=\"xterm-256color\" ssh_cez"
     alias sshi='ssh -o StrictHostKeyChecking=no'

     export CEZ_USERNAME="<company-username>"
```

doplnit info a constatnts souboru

## Docs

If you are interested why I made some decisions or if you want to create your own module, you should read [PHILOSOPHY.md](PHILOSOPHY.md) document.

TODO: doplnit link na adoption
