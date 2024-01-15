## Description
This repository contains my `.bashrc` and configs for various software:
- [Neovim](https://github.com/neovim/neovim)
- [Tmux](https://github.com/tmux/tmux)

To leave as a note - I am also using:
- [fff](https://github.com/dylanaraps/fff)
- [Trash-CLI](https://github.com/andreafrancia/trash-cli)
- [delta](https://github.com/dandavison/delta)
- [fzf](https://github.com/junegunn/fzf)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fd](https://github.com/sharkdp/fd)
- [bat](https://github.com/sharkdp/bat)
- [bear](https://github.com/rizsotto/Bear)
- [forgit](https://github.com/wfxr/forgit)
- [neofetch](https://github.com/dylanaraps/neofetch)

My approach is to download latest releases of above to '~/tools' directory and then symlink bins to '~/bin' directory

FZF should be installed with provided installation scriptt, check FZF README

Forgit should be installed by sourcing proper file, check my bashrc

## Installation
To use those best option would be just to make sym links into proper paths.

example:
```
cd
ln -s /path/to/repo/.inputrc ./.inputrc
```

In case of .bashrc also good idea is to source my bashrc from currenlty available on the system.
```
[ -f /path/to/repo/.bashrc ] && source /path/to/repo/.bashrc
```

In ~/.gitconfig add lines following lines to include config from repo:
```
[include]
    path = /path/to/repo/.gitconfig
```

Neovim
```
cd ~/.config
ln -s /path/to/repo/nvim ./nvim
```

## Installation steps
1. Tools from package manager:
    - sudo dnf install neovim tmux fzf trash-cli git-delta ripgrep fd-find bat bear neofetch -y

2. Download to `~/tools/` and install:
    - fff: run `make install`
    - forgit: will be sourced from bashrc

3. Git clone this repo
4. Create sym links:
    - .tmux.conf
    - .inputrc
    - neovim config
5. Modify current configs to source (include) my stuff
    - .bashrc
    - .gitconfig
6. Use color_test script to check if colors are right




