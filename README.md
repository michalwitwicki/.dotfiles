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

Best option to install above software is to download latest release and sm link to ~/bin directory 

FZF should be installed with provided installation scriptt, check FZF README

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

FZF should be installed using built-in script
