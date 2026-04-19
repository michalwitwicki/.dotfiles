## Description
This repository contains my dotfiles and configs.

## List of tools I am using
- git
- python
- [Tmux](https://github.com/tmux/tmux)
- [Neovim](https://github.com/neovim/neovim)
- [fff](https://github.com/dylanaraps/fff)
- [Trash-CLI](https://github.com/andreafrancia/trash-cli)
- [delta](https://github.com/dandavison/delta)
- [fzf](https://github.com/junegunn/fzf)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fd](https://github.com/sharkdp/fd)
- [bat](https://github.com/sharkdp/bat)
- [bear](https://github.com/rizsotto/Bear)
- [forgit](https://github.com/wfxr/forgit)
- [boxes](https://github.com/ascii-boxes/boxes)

## Installation steps
1. Git clone this repo: `git clone git@github.com:michalwitwicki/.dotfiles.git`
2. Getting the tools:
    For my current Fedora setup I am installing listed below with `dnf`:
    ```
    sudo dnf install -y \
        tmux \
        git \
        python \
        trash-cli \
        git-delta \
        ripgrep \
        fd-find \
        bat \
        bear \
        npm \
        lua \
        luarocks \
        tree-sitter-cli \
        boxes
    ```

    `npm` - some languege servers are using it
    `luarocks` - nvim plugin
    `boxes` - nvim script

    If another tools would be downloaded manually, for example `nvim`, make a sym link of its binary into `~/bin`

    Manual installs:

    neovim:
    ```
    cd ~/tools/neovim_0_12_1
    wget https://github.com/neovim/neovim/releases/download/v0.12.1/nvim-linux-x86_64.appimage
    chmod u+x nvim-linux-x86_64.appimage
    ln -svf /home/mwitwicki/tools/neovim_0_12_1/nvim-linux-x86_64.appimage /home/mwitwicki/bin/nvim
    ```

    fzf:
    ```
    cd ~/tools
    git clone --depth 1 https://github.com/junegunn/fzf.git ./fzf
    ./fzf/install --all
    ```

    fff:
    ```
    cd ~/tools
    git clone git@github.com:dylanaraps/fff.git
    cd fff
    sudo make install
    ```

    forgit (will be sourced from .bashrc):
    ```
    cd ~/tools
    git clone git@github.com:wfxr/forgit.git
    ```


    Opencode:
    ```
    curl -fsSL https://opencode.ai/install | bash
    opencode auth login
    opencode
    /theme
    gruvbox
    ```

3. run `install.sh`

4. To test terminal capabilities run:
```
./scripts/color_formatting_test.sh
```
and / or:
```
./scripts/test_terminal_capabilities.sh
```

## Miscellaneous
Other stuff:
1. `configs_for_remote`: minimal configs for working on temporary remote machine
2. `unsuded_stuff`: old / not finished scripts or configs

