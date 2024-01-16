## Description
This repository contains my dotfiles and configs:
    - .bashrc
    - .inputrc
    - .tmux.info
    - .gitconfig
    - nvim

## List of tools
- [Neovim](https://github.com/neovim/neovim)
- [Tmux](https://github.com/tmux/tmux)
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

## Installation steps
1. Git clone this repo
2. Getting the tools:
    Many tools listed above can be installed from package manager. If for whatever reason you don't want to use package manager, you can also install them manually.
    For my current Fedora setup I am installing listed below with `dnf`:
    - sudo dnf install neovim tmux fzf trash-cli git-delta ripgrep fd-find bat bear neofetch -y

    And those I install manually by downloading and extracting them into `~/tools/`: *
    - fff
    - forgit

    Manuall installation for those two:
    - fff: run `make install`
    - forgit: will be sourced from bashrc

    If another tools would be downloaded manually, for example `nvim`, make a sym link of its binary into `~/bin`

3. Create sym links *
    - .tmux.conf -> ~/.tmux.conf
    - .inputrc -> ~/.inputrc
    - nvim -> ~/.config/nvim

4. Modify current configs to source (include) my configs *
    - .bashrc -> `[ -f /path/to/repo/.bashrc ] && source /path/to/repo/.bashrc`
    - .gitconfig ->
    ```
    [include]
        path = /path/to/repo/.gitconfig
    ```

5. Use color_test script inside tmux to check if colors are right

* Those steps can be handled by running `python install.py`

