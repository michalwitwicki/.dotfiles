## Description
This repository contains my dotfiles and configs:
- `.bashrc`
- `.inputrc`
- `.tmux.info`
- `.gitconfig`
- `nvim`

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
- [neofetch](https://github.com/dylanaraps/neofetch)

## Installation steps
1. Git clone this repo
2. Getting the tools:
    Many tools listed above can be installed from package manager. If for whatever reason you don't want to use package manager, you can also install them manually.
    For my current Fedora setup I am installing listed below with `dnf`:
    ```
    sudo dnf install -y \
    tmux \
    git \
    python \
    neovim \
    trash-cli \
    git-delta \
    ripgrep \
    fd-find \
    bat \
    bear \
    npm \
    luarocks
    ```

    `npm` is there because some languege servers are using it

    `*` And those I install manually by downloading and extracting them into `~/tools/`:
    - `fff`
    - `forgit`

    Manuall installation for above:
    - `fff`: run `make install`
    - `forgit`: will be sourced from `.bashrc`

    If another tools would be downloaded manually, for example `nvim`, make a sym link of its binary into `~/bin`

    `fzf` requires another approach if you want to have fuzzy auto-completion and additional key bindings.
    ```
    cd ~/tools
    git clone --depth 1 https://github.com/junegunn/fzf.git ./fzf
    ./fzf/install --all
    ```

3. `*` Create sym links
    - `/path/to/repo/.tmux.conf` -> `~/.tmux.conf`
    - `/path/to/repo/.inputrc` -> `~/.inputrc`
    - `/path/to/repo/nvim` -> `~/.config/nvim`
    - `/path/to/repo/.gdbinit` -> `~/.gdbinit`

4. `*` Modify current configs to source (include) my configs
    - to `~/.bashrc` add `[ -f /path/to/repo/.bashrc ] && source /path/to/repo/.bashrc`
    - to `~/.gitconfig` add
        ```
        [include]
            path = /path/to/repo/.gitconfig
        ```

5. Use `color_test.sh` script inside `tmux` session to check if colors are right
    Also this is nice alternative: curl -L https://bit.ly/3A5B3u3 | python3 | less -R

6. Run below to check if formatting works properly:
    ```
    echo -e "\e[1mbold\e[0m"
    echo -e "\e[3mitalic\e[0m"
    echo -e "\e[3m\e[1mbold italic\e[0m"
    echo -e "\e[4munderline\e[0m"
    echo -e "\e[9mstrikethrough\e[0m"
    echo -e "\x1B[31mred\e[0m"

    printf "\x1b[58:2::255:0:0m\x1b[4:1msingle\x1b[4:2mdouble\x1b[4:3mcurly\x1b[4:4mdotted\x1b[4:5mdashed\x1b[0m\n"
    ```

`*` Those steps are already automated in `install.py` script, you can use it by running `python install.py`

## Miscellaneous
Other stuff:
1. `configs_for_remote`: minimal configs for working on temporary remote machine
2. `unsuded_stuff`: old / not finished scripts or configs
3. `windows_terminal_settings.json`

