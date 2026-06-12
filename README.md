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
1. Clone the repo:
    ```
    git clone git@github.com:michalwitwicki/.dotfiles.git ~/repos/.dotfiles
    ```

2. Run the installer:
    ```
    ./install.sh
    ```
    This will:
    - Create symlinks for configs (`.tmux.conf`, `.inputrc`, `.gdbinit`, `~/.config/nvim`)
    - Inject `source`/`include` blocks into `~/.bashrc` and `~/.gitconfig`
    - Install dnf packages
    - Install **neovim** — latest stable AppImage downloaded to `~/tools/neovim_<version>/`,
        symlinked to `~/bin/nvim`
    - Install **fzf**, **fff**, **forgit** — cloned from GitHub into `~/tools/`
    - Install **opencode** via `curl -fsSL https://opencode.ai/install | bash`

3. *(Optional)* Authenticate and configure opencode:
    ```
    opencode auth login
    opencode
    /theme
    gruvbox
    ```

    To remove the symlinks created by the installer:
    ```
    ./install.sh --uninstall
    ```

4. To test terminal capabilities run:
    ```
    ./scripts/color_formatting_test.sh
    ```
    and / or:
    ```
    ./scripts/test_terminal_capabilities.sh
    ```

## Code Formatting

Formatting is enforced via a pre-commit git hook using:

| Language | Formatter | Config |
| -------- | --------- | ------ |
| Lua      | `stylua`  | `stylua.toml` |
| Shell    | `shfmt`   | `.editorconfig` |
| Markdown | `prettier` | `.prettierrc.yaml` |

### Setup (required after each fresh clone)

```
./install.sh --only git_hooks
```

This installs the formatters and activates the hook via `git config
core.hooksPath git-hooks`.

### Manual usage

Format all tracked files:

```
./scripts/format.sh
```

Check formatting without modifying files (exits non-zero on violations):

```
./scripts/format-check.sh
```

### Bypass

To commit without running the formatter:

```
git commit --no-verify
```

## Miscellaneous
Other stuff:
1. `configs_for_remote`: minimal configs for working on temporary remote machine
2. `unused_stuff`: old / not finished scripts or configs

