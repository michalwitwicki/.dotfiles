#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/configs"

# --- Helper functions ---

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

# --- Create symbolic links ---

echo "--- Create symbolic links ---"
create_symlink "$CONFIGS_DIR/.tmux.conf" "$HOME/.tmux.conf"
create_symlink "$CONFIGS_DIR/.inputrc"   "$HOME/.inputrc"
create_symlink "$CONFIGS_DIR/.gdbinit"   "$HOME/.gdbinit"
create_symlink "$SCRIPT_DIR/nvim"        "$HOME/.config/nvim"

# --- Include configs ---

echo ""
echo "--- Include configs ---"

add_to_file_if_not_present "$HOME/.bashrc" "source custom bashrc" \
    "# Added by .dotfiles/install.sh - source custom bashrc
[ -f \"$CONFIGS_DIR/.bashrc\" ] && source \"$CONFIGS_DIR/.bashrc\""

add_to_file_if_not_present "$HOME/.gitconfig" "include custom gitconfig" \
    "; Added by .dotfiles/install.sh - include custom gitconfig
[include]
    path = $CONFIGS_DIR/.gitconfig"
