#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/configs"
TOOLS_DIR="$HOME/tools"
BIN_DIR="$HOME/bin"

# Parse flags
UNINSTALL=0
for arg in "$@"; do
    case "$arg" in
        --uninstall) UNINSTALL=1 ;;
        --help|-h)
            cat <<EOF
Usage: $(basename "$0") [OPTION]

Set up dotfiles and install tools for the current user.

Options:
  (none)       Run the full installation:
                 - Create symlinks for configs (.tmux.conf, .inputrc, .gdbinit, nvim)
                 - Inject source/include blocks into ~/.bashrc and ~/.gitconfig
                 - Install dnf packages (tmux, ripgrep, bat, delta, ...)
                 - Install neovim (latest stable AppImage -> ~/tools/, symlink in ~/bin/)
                 - Install fzf, fff, forgit, opencode into ~/tools/

  --uninstall  Remove symlinks created by this script
                 (only symlinks that still point into this repo are removed)

  --help, -h   Show this help message and exit

EOF
            exit 0
            ;;
    esac
done

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

create_symlink() {
    local target="$1"
    local link_name="$2"
    local link_dir
    link_dir="$(dirname "$link_name")"

    if [ ! -d "$link_dir" ]; then
        mkdir -p "$link_dir"
        echo "[ ok ] Created directory: $link_dir"
    fi

    if [ -L "$link_name" ]; then
        local existing_target
        existing_target="$(readlink "$link_name")"
        if [ "$existing_target" = "$target" ]; then
            echo "[skip] Symlink already exists: $link_name -> $target"
            return
        fi
        echo "[warn] Symlink $link_name points to $existing_target, replacing with $target"
        rm "$link_name"
    elif [ -e "$link_name" ]; then
        echo "[warn] $link_name already exists and is not a symlink, skipping"
        return
    fi

    ln -s "$target" "$link_name"
    echo "[ ok ] Symlink created: $link_name -> $target"
}

# Remove a symlink only if it points to the expected target.
# Args: target, link_name
remove_symlink_if_ours() {
    local target="$1"
    local link_name="$2"

    if [ ! -L "$link_name" ]; then
        echo "[skip] $link_name does not exist or is not a symlink"
        return
    fi

    local existing_target
    existing_target="$(readlink "$link_name")"
    if [ "$existing_target" != "$target" ]; then
        echo "[skip] Symlink $link_name points to $existing_target (not ours), skipping"
        return
    fi

    rm "$link_name"
    echo "[ ok ] Removed symlink: $link_name"
}

# Append a block to a file if a marker comment is not already present.
# The marker is auto-generated from the config name.
# Args: file, config_name, block
add_to_file_if_not_present() {
    local file="$1"
    local config_name="$2"
    local block="$3"
    local marker="Added by .dotfiles/install.sh - $config_name"

    if [ ! -f "$file" ]; then
        echo "[warn] File $file does not exist, creating it"
        touch "$file"
    fi

    if grep -qF "$marker" "$file"; then
        echo "[skip] $config_name already present in $file"
    else
        printf '\n%s\n' "$block" >> "$file"
        echo "[ ok ] $config_name appended to $file"
    fi
}

# Query the GitHub releases API and return the latest stable (non-prerelease,
# non-draft) tag name for a given repo.
# Args: owner/repo  (e.g. "neovim/neovim")
get_latest_github_release() {
    local repo="$1"
    curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
        | grep -oP '"tag_name":\s*"\K[^"]+'
}

# ---------------------------------------------------------------------------
# Install functions
# ---------------------------------------------------------------------------

install_dnf_packages() {
    if ! command -v dnf &>/dev/null; then
        echo "[skip] dnf not found, skipping package install"
        return
    fi

    local packages=(
        tmux            # terminal multiplexer
        git             # version control
        python          # scripting / tooling
        trash-cli       # safe rm replacement
        git-delta       # better git diffs
        ripgrep         # fast grep (rg)
        fd-find         # fast find (fd)
        bat             # better cat
        bear            # generates compile_commands.json for LSP
        npm             # required by some LSP servers
        lua             # scripting
        luarocks        # nvim plugin support
        tree-sitter-cli # nvim treesitter
        boxes           # used by nvim script
    )

    local to_install=()
    for pkg in "${packages[@]}"; do
        if dnf list --installed "$pkg" &>/dev/null 2>&1; then
            echo "[skip] dnf package already installed: $pkg"
        else
            to_install+=("$pkg")
        fi
    done

    if [ "${#to_install[@]}" -eq 0 ]; then
        echo "[skip] All dnf packages already installed"
        return
    fi

    echo "[ ok ] Installing dnf packages: ${to_install[*]}"
    sudo dnf install -y "${to_install[@]}"
}

install_neovim() {
    mkdir -p "$BIN_DIR"

    local nvim_bin="$BIN_DIR/nvim"

    if [ -L "$nvim_bin" ]; then
        echo "[skip] nvim symlink already exists at $nvim_bin"
        return
    fi

    echo "[ .. ] Fetching latest stable neovim release..."
    local version
    version="$(get_latest_github_release "neovim/neovim")"
    if [ -z "$version" ]; then
        echo "[fail] Could not determine latest neovim version"
        return 1
    fi
    echo "[ ok ] Latest neovim: $version"

    # Strip leading 'v' to build directory name, e.g. v0.10.4 -> 0.10.4
    local version_num="${version#v}"
    local install_dir="$TOOLS_DIR/neovim_${version_num}"
    local appimage="nvim-linux-x86_64.appimage"
    local appimage_path="$install_dir/$appimage"

    mkdir -p "$install_dir"

    if [ -f "$appimage_path" ]; then
        echo "[skip] AppImage already downloaded: $appimage_path"
    else
        local url="https://github.com/neovim/neovim/releases/download/${version}/${appimage}"
        echo "[ .. ] Downloading $url"
        wget -q -O "$appimage_path" "$url"
        echo "[ ok ] Downloaded neovim AppImage"
    fi

    chmod u+x "$appimage_path"
    create_symlink "$appimage_path" "$nvim_bin"
    echo "[ ok ] nvim installed: $nvim_bin -> $appimage_path"
    echo "       version: $version"
}

install_fzf() {
    local fzf_dir="$TOOLS_DIR/fzf"

    if [ -d "$fzf_dir" ]; then
        echo "[skip] fzf already cloned at $fzf_dir"
        return
    fi

    mkdir -p "$TOOLS_DIR"
    echo "[ .. ] Cloning fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$fzf_dir"
    echo "[ .. ] Running fzf installer..."
    "$fzf_dir/install" --all
    echo "[ ok ] fzf installed"
}

install_fff() {
    local fff_dir="$TOOLS_DIR/fff"

    if command -v fff &>/dev/null; then
        echo "[skip] fff already in PATH"
        return
    fi

    mkdir -p "$TOOLS_DIR"
    echo "[ .. ] Cloning fff..."
    git clone https://github.com/dylanaraps/fff.git "$fff_dir"
    echo "[ .. ] Installing fff (sudo make install)..."
    make -C "$fff_dir" install
    echo "[ ok ] fff installed"
}

install_forgit() {
    local forgit_dir="$TOOLS_DIR/forgit"

    if [ -d "$forgit_dir" ]; then
        echo "[skip] forgit already cloned at $forgit_dir"
        return
    fi

    mkdir -p "$TOOLS_DIR"
    echo "[ .. ] Cloning forgit..."
    git clone https://github.com/wfxr/forgit.git "$forgit_dir"
    echo "[ ok ] forgit cloned to $forgit_dir"
}

install_opencode() {
    if command -v opencode &>/dev/null; then
        echo "[skip] opencode already in PATH"
        return
    fi

    echo "[ .. ] Installing opencode..."
    local tmp_installer
    tmp_installer="$(mktemp)"
    curl -fsSL https://opencode.ai/install -o "$tmp_installer"
    bash "$tmp_installer"
    rm -f "$tmp_installer"
    echo "[ ok ] opencode installed"
    echo "[info] Run 'opencode auth login' to authenticate"
}

# ---------------------------------------------------------------------------
# Uninstall function
# ---------------------------------------------------------------------------

uninstall() {
    echo "--- Remove symbolic links ---"
    remove_symlink_if_ours "$CONFIGS_DIR/.tmux.conf" "$HOME/.tmux.conf"
    remove_symlink_if_ours "$CONFIGS_DIR/.inputrc"   "$HOME/.inputrc"
    remove_symlink_if_ours "$CONFIGS_DIR/.gdbinit"   "$HOME/.gdbinit"
    remove_symlink_if_ours "$SCRIPT_DIR/nvim"        "$HOME/.config/nvim"
    echo ""
    echo "--- Done ---"
}

# ---------------------------------------------------------------------------
# Install function
# ---------------------------------------------------------------------------

install() {
    # Create symbolic links
    echo "--- Create symbolic links ---"
    create_symlink "$CONFIGS_DIR/.tmux.conf" "$HOME/.tmux.conf"
    create_symlink "$CONFIGS_DIR/.inputrc"   "$HOME/.inputrc"
    create_symlink "$CONFIGS_DIR/.gdbinit"   "$HOME/.gdbinit"
    create_symlink "$SCRIPT_DIR/nvim"        "$HOME/.config/nvim"

    # Include configs
    echo ""
    echo "--- Include configs ---"

    add_to_file_if_not_present "$HOME/.bashrc" "source custom bashrc" \
        "# Added by .dotfiles/install.sh - source custom bashrc
[ -f \"$CONFIGS_DIR/.bashrc\" ] && source \"$CONFIGS_DIR/.bashrc\""

    add_to_file_if_not_present "$HOME/.gitconfig" "include custom gitconfig" \
        "; Added by .dotfiles/install.sh - include custom gitconfig
[include]
    path = $CONFIGS_DIR/.gitconfig"

    # Install dnf packages
    echo ""
    echo "--- Install dnf packages ---"
    install_dnf_packages

    # Install tools manually
    echo ""
    echo "--- Install tools manually ---"

    mkdir -p "$BIN_DIR"
    mkdir -p "$TOOLS_DIR"

    echo ""
    echo "[ .. ] neovim"
    install_neovim

    echo ""
    echo "[ .. ] fzf"
    install_fzf

    echo ""
    echo "[ .. ] fff"
    install_fff

    echo ""
    echo "[ .. ] forgit"
    install_forgit

    echo ""
    echo "[ .. ] opencode"
    install_opencode

    echo ""
    echo "--- Done ---"
}

# ---------------------------------------------------------------------------
# Main — only runs when script is executed directly, not sourced
# ---------------------------------------------------------------------------

main() {
    if [[ "$UNINSTALL" -eq 1 ]]; then
        uninstall
    else
        install
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
