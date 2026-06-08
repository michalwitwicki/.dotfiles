#!/usr/bin/env bash
# =============================================================================
# install.sh — dotfiles installer
# =============================================================================
#
# HOW TO ADD A NEW MODULE
# -----------------------
# 1. Define a function  module_<name>()  with three subcommands (see template).
# 2. Call  register_module "name" "description"  immediately after.
#    The module will automatically appear in --list, the install loop, etc.
#    No other changes needed.
#
# Template:
#
#   module_myapp() {
#       local action="${1:-install}"
#       case "$action" in
#           info)
#               echo "myapp"
#               echo "One-line description shown in --list and prompts"
#               ;;
#           install)
#               # --- dnf dependencies (optional) ---
#               # run_cmd sudo dnf install -y libfoo libbar
#
#               # --- install the tool (pick one) ---
#               # git clone:
#               #   run_cmd git clone https://github.com/user/myapp "$TOOLS_DIR/myapp"
#               # GitHub release binary / AppImage:
#               #   local ver; ver="$(get_latest_github_release owner/myapp)"
#               #   run_cmd wget -q -O "$TOOLS_DIR/myapp" \
#               #       "https://github.com/owner/myapp/releases/download/${ver}/myapp"
#               # Custom installer script:
#               #   local tmp; tmp="$(mktemp)"
#               #   run_cmd curl -fsSL https://example.com/install -o "$tmp"
#               #   run_cmd bash "$tmp"; rm -f "$tmp"
#               # npm global package:
#               #   run_cmd npm install -g myapp
#
#               # --- config (pick one or more) ---
#               # Symlink a config file:
#               #   create_symlink "$CONFIGS_DIR/myapp.conf" "$HOME/.myapp.conf"
#               # Inject a block into an arbitrary file (default comment char "#"):
#               #   add_to_file_if_not_present "$HOME/.somerc" "myapp" "...content..."
#               # Inject into .gitconfig (uses ";" as comment char):
#               #   add_to_file_if_not_present "$HOME/.gitconfig" "myapp" "...content..." ";"
#               ;;
#           uninstall)
#               # Reverse of install
#               # remove_symlink_if_ours "$CONFIGS_DIR/myapp.conf" "$HOME/.myapp.conf"
#               # run_cmd rm -rf "$TOOLS_DIR/myapp"
#               ;;
#       esac
#   }
#   register_module "myapp" "One-line description"
#
# =============================================================================
# HELPER REFERENCE
# =============================================================================
#
#   install_dnf_packages LABEL PKG [PKG ...]
#       Install dnf packages in one batch, skipping already-installed ones.
#       No-op with a skip message when dnf is not available.
#
#   run_cmd CMD [ARGS...]
#       Execute CMD normally, or log "[dry ]" and skip when --dry-run is active.
#
#   log_ok | log_skip | log_warn | log_fail | log_info | log_dry  MSG
#       Print a colour-prefixed log line (colours only when stdout is a tty).
#       Prefixes: "[ ok ]", "[skip]", "[warn]", "[fail]", "[info]", "[dry ]"
#
#   create_symlink TARGET LINK
#       Create LINK -> TARGET.  Creates parent dirs.  Skips if already correct.
#       Replaces a wrong symlink (with warning).  Skips a regular file (warning).
#
#   remove_symlink_if_ours TARGET LINK
#       Remove LINK only if it is a symlink pointing exactly to TARGET.
#
#   add_to_file_if_not_present FILE NAME BLOCK [COMMENT_CHAR="#"]
#       Append BLOCK to FILE wrapped in tagged BEGIN/END markers:
#         <COMMENT_CHAR> === install.sh: NAME BEGIN ===
#         ...BLOCK...
#         <COMMENT_CHAR> === install.sh: NAME END ===
#       Idempotent (skips if BEGIN marker already present).
#       Use COMMENT_CHAR=";" for .gitconfig; default "#" for shell files.
#
#   remove_from_file_section FILE NAME [COMMENT_CHAR="#"]
#       Delete the tagged section for NAME from FILE (BEGIN line through END line).
#       COMMENT_CHAR must match what was used in add_to_file_if_not_present.
#
#   get_latest_github_release OWNER/REPO
#       Return the latest stable tag name (e.g. "v1.2.3") via the GitHub API.
#
#   prompt_proceed NAME DESC [VERB="Proceed"]
#       Show an interactive [Y/s/q] prompt for a module.
#       VERB is the action label shown: "Proceed? [Y/s/q]" or "Uninstall? [Y/s/q]".
#       Returns 0=proceed, 1=skip.  Q quits immediately (prints summary first).
#       Automatically proceeds (no prompt) when --all or --uninstall-all is active.
#
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/configs"
TOOLS_DIR="$HOME/tools"
BIN_DIR="$HOME/bin"

# ---------------------------------------------------------------------------
# Flags  (populated by _parse_args; set here so sourcing scripts see defaults)
# ---------------------------------------------------------------------------

DRY_RUN=0
FLAG_ALL=0
FLAG_UNINSTALL=0
FLAG_UNINSTALL_ALL=0
FLAG_ONLY=""
FLAG_UNINSTALL_ONLY=""
FLAG_LIST=0
FLAG_TEST=0

# ---------------------------------------------------------------------------
# Colours (only when stdout is a tty — keeps piped/test output clean)
# ---------------------------------------------------------------------------

if [[ -t 1 ]]; then
    C_GREEN='\033[0;32m'
    C_YELLOW='\033[1;33m'
    C_RED='\033[0;31m'
    C_CYAN='\033[0;36m'
    C_BLUE='\033[0;34m'
    C_BOLD='\033[1m'
    C_RESET='\033[0m'
else
    C_GREEN='' C_YELLOW='' C_RED='' C_CYAN='' C_BLUE='' C_BOLD='' C_RESET=''
fi

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

_parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                DRY_RUN=1; shift ;;
            --all)
                FLAG_ALL=1; shift ;;
            --uninstall)
                FLAG_UNINSTALL=1; shift ;;
            --uninstall-all)
                FLAG_UNINSTALL_ALL=1; shift ;;
            --only)
                [[ $# -ge 2 ]] || { printf 'Error: --only requires a module name\n' >&2; exit 1; }
                FLAG_ONLY="$2"; shift 2 ;;
            --uninstall-only)
                [[ $# -ge 2 ]] || { printf 'Error: --uninstall-only requires a module name\n' >&2; exit 1; }
                FLAG_UNINSTALL_ONLY="$2"; shift 2 ;;
            --list)
                FLAG_LIST=1; shift ;;
            --test)
                FLAG_TEST=1; shift ;;
            --help|-h)
                _print_help; exit 0 ;;
            *)
                printf 'Unknown option: %s\nRun %s --help for usage.\n' "$1" "$(basename "$0")" >&2
                exit 1 ;;
        esac
    done
}

_print_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Set up dotfiles and install tools for the current user.

Options:
  (none)                    Interactive install: prompt [Y/s/q] for each module
  --all                     Install all modules without prompting
  --only <name>             Install only the named module
  --uninstall               Interactive uninstall: prompt [Y/s/q] for each module
  --uninstall-all           Uninstall all modules without prompting
  --uninstall-only <name>   Uninstall only the named module
  --list                    List all available modules and exit
  --dry-run                 Print what would be done, without executing anything
  --test                    Run the test suite (tests/test_install.sh)
  --help, -h                Show this help message and exit

Prompt keys (interactive mode):
  Enter / Y   Proceed with module installation
  S           Skip this module
  Q           Quit immediately (prints summary of completed modules first)

Examples:
  $(basename "$0") --all
  $(basename "$0") --only forgit
  $(basename "$0") --uninstall
  $(basename "$0") --uninstall-all
  $(basename "$0") --uninstall-only neovim
  $(basename "$0") --dry-run --all

Run  $(basename "$0") --list  to see all available modules with descriptions.
EOF
}

# ---------------------------------------------------------------------------
# Helpers: log functions
# ---------------------------------------------------------------------------

log_ok()   { printf "${C_GREEN}[ ok ]${C_RESET} %s\n" "$*"; }
log_skip() { printf "${C_CYAN}[skip]${C_RESET} %s\n" "$*"; }
log_warn() { printf "${C_YELLOW}[warn]${C_RESET} %s\n" "$*"; }
log_fail() { printf "${C_RED}[fail]${C_RESET} %s\n" "$*" >&2; }
log_info() { printf "${C_BLUE}[info]${C_RESET} %s\n" "$*"; }
log_dry()  { printf "${C_YELLOW}[dry ]${C_RESET} %s\n" "$*"; }

# ---------------------------------------------------------------------------
# Helper: run_cmd — dry-run-aware command executor
# ---------------------------------------------------------------------------

# Run a command normally, or log and skip it when --dry-run is active.
run_cmd() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        log_dry "Would run: $*"
        return 0
    fi
    "$@"
}

# ---------------------------------------------------------------------------
# Helper: create_symlink TARGET LINK_NAME
# ---------------------------------------------------------------------------

create_symlink() {
    local target="$1"
    local link_name="$2"
    local link_dir
    link_dir="$(dirname "$link_name")"

    if [[ ! -d "$link_dir" ]]; then
        run_cmd mkdir -p "$link_dir"
        log_ok "Created directory: $link_dir"
    fi

    if [[ -L "$link_name" ]]; then
        local existing_target
        existing_target="$(readlink "$link_name")"
        if [[ "$existing_target" = "$target" ]]; then
            log_skip "Symlink already exists: $link_name -> $target"
            return
        fi
        log_warn "Symlink $link_name points to $existing_target, replacing with $target"
        run_cmd rm "$link_name"
    elif [[ -e "$link_name" ]]; then
        log_warn "$link_name already exists and is not a symlink, skipping"
        return
    fi

    run_cmd ln -s "$target" "$link_name"
    log_ok "Symlink created: $link_name -> $target"
}

# ---------------------------------------------------------------------------
# Helper: remove_symlink_if_ours TARGET LINK_NAME
# ---------------------------------------------------------------------------

# Remove LINK_NAME only if it is a symlink pointing to TARGET.
remove_symlink_if_ours() {
    local target="$1"
    local link_name="$2"

    if [[ ! -L "$link_name" ]]; then
        log_skip "$link_name does not exist or is not a symlink"
        return
    fi

    local existing_target
    existing_target="$(readlink "$link_name")"
    if [[ "$existing_target" != "$target" ]]; then
        log_skip "Symlink $link_name points to $existing_target (not ours), skipping"
        return
    fi

    run_cmd rm "$link_name"
    log_ok "Removed symlink: $link_name"
}

# ---------------------------------------------------------------------------
# Helper: add_to_file_if_not_present FILE NAME BLOCK [COMMENT_CHAR]
# ---------------------------------------------------------------------------

# Append BLOCK to FILE, wrapped in tagged BEGIN/END markers.
# COMMENT_CHAR defaults to "#"; use ";" for .gitconfig.
add_to_file_if_not_present() {
    local file="$1"
    local config_name="$2"
    local block="$3"
    local comment_char="${4:-#}"
    local begin_marker="${comment_char} === install.sh: ${config_name} BEGIN ==="
    local end_marker="${comment_char} === install.sh: ${config_name} END ==="

    if [[ ! -f "$file" ]]; then
        log_warn "File $file does not exist, creating it"
        if [[ "$DRY_RUN" -eq 0 ]]; then
            touch "$file"
        fi
    fi

    if grep -qF "$begin_marker" "$file" 2>/dev/null; then
        log_skip "$config_name already present in $file"
        return
    fi

    if [[ "$DRY_RUN" -eq 1 ]]; then
        log_dry "Would append $config_name to $file"
        return
    fi

    printf '\n%s\n%s\n%s\n' "$begin_marker" "$block" "$end_marker" >> "$file"
    log_ok "$config_name appended to $file"
}

# ---------------------------------------------------------------------------
# Helper: remove_from_file_section FILE NAME [COMMENT_CHAR]
# ---------------------------------------------------------------------------

# Delete the tagged BEGIN/END section for NAME from FILE.
# Uses fixed-string grep to find line numbers, then sed to delete the range.
remove_from_file_section() {
    local file="$1"
    local config_name="$2"
    local comment_char="${3:-#}"
    local begin_marker="${comment_char} === install.sh: ${config_name} BEGIN ==="
    local end_marker="${comment_char} === install.sh: ${config_name} END ==="

    if [[ ! -f "$file" ]]; then
        log_skip "$file does not exist, nothing to remove"
        return
    fi

    if ! grep -qF "$begin_marker" "$file"; then
        log_skip "$config_name not found in $file"
        return
    fi

    if [[ "$DRY_RUN" -eq 1 ]]; then
        log_dry "Would remove $config_name section from $file"
        return
    fi

    local begin_line end_line
    begin_line="$(grep -nF "$begin_marker" "$file" | head -1 | cut -d: -f1)"
    end_line="$(grep -nF "$end_marker" "$file" | head -1 | cut -d: -f1)"

    if [[ -z "$begin_line" || -z "$end_line" ]]; then
        log_warn "Incomplete markers for $config_name in $file, skipping"
        return
    fi

    sed -i "${begin_line},${end_line}d" "$file"
    log_ok "Removed $config_name section from $file"
}

# ---------------------------------------------------------------------------
# Helper: get_latest_github_release OWNER/REPO
# ---------------------------------------------------------------------------

# Query the GitHub releases API and return the latest stable tag name.
get_latest_github_release() {
    local repo="$1"
    curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
        | grep -oP '"tag_name":\s*"\K[^"]+'
}

# ---------------------------------------------------------------------------
# Helper: install_dnf_packages LABEL PKG [PKG ...]
# ---------------------------------------------------------------------------

# Install dnf packages, skipping any that are already present.
# Prints skip for already-installed packages; installs the rest in one batch.
install_dnf_packages() {
    local label="$1"; shift
    local packages=("$@")

    if ! command -v dnf &>/dev/null; then
        log_skip "dnf not found, skipping $label package install"
        return
    fi

    local to_install=()
    for pkg in "${packages[@]}"; do
        if dnf list --installed "$pkg" &>/dev/null 2>&1; then
            log_skip "already installed: $pkg"
        else
            to_install+=("$pkg")
        fi
    done

    if [[ "${#to_install[@]}" -eq 0 ]]; then
        log_skip "All $label packages already installed"
        return
    fi

    log_info "Installing $label packages: ${to_install[*]}"
    run_cmd sudo dnf install -y "${to_install[@]}"
    log_ok "$label packages installed"
}

# ---------------------------------------------------------------------------
# Helper: prompt_proceed NAME DESC [VERB]
# ---------------------------------------------------------------------------

# Prompt [Y/s/q] for a module.  Returns 0=proceed, 1=skip.  Q exits.
# VERB is the action label shown in the prompt (default "Proceed").
# Automatically proceeds without prompting when --all or --uninstall-all is active.
prompt_proceed() {
    local name="$1"
    local desc="$2"
    local verb="${3:-Proceed}"

    if [[ "$FLAG_ALL" -eq 1 || "$FLAG_UNINSTALL_ALL" -eq 1 ]]; then
        printf "\n${C_BOLD}[ %s ]${C_RESET} %s\n" "$name" "$desc"
        return 0
    fi

    printf "\n${C_BOLD}Module: %s${C_RESET}\n" "$name"
    printf "  %s\n" "$desc"
    printf "%s? [Y/s/q] " "$verb"

    local reply
    IFS= read -r reply </dev/tty 2>/dev/null || reply="y"
    reply="${reply,,}"   # to lower-case

    case "$reply" in
        s|skip)
            log_info "Skipping $name"
            return 1
            ;;
        q|quit)
            printf "\n"
            print_summary
            exit 0
            ;;
        *)
            return 0
            ;;
    esac
}

# ---------------------------------------------------------------------------
# Module framework
# ---------------------------------------------------------------------------

MODULES=()
declare -A MODULE_DESCS
declare -A MODULE_RESULTS

# Register a module so it appears in --list and is included in the install loop.
register_module() {
    local name="$1"
    local desc="$2"
    MODULES+=("$name")
    MODULE_DESCS["$name"]="$desc"
}

# Dispatch an action (install|uninstall|info) to a module function.
run_module() {
    local action="$1"
    local name="$2"
    local fn="module_${name}"

    if ! declare -F "$fn" > /dev/null 2>&1; then
        log_fail "Unknown module: $name"
        return 1
    fi

    "$fn" "$action"
}

record_result() {
    local name="$1"
    local result="$2"
    MODULE_RESULTS["$name"]="$result"
}

print_summary() {
    local installed=0 skipped=0 failed=0
    printf "\n${C_BOLD}=== Summary ===${C_RESET}\n"
    for name in "${MODULES[@]}"; do
        local result="${MODULE_RESULTS[$name]:-}"
        [[ -z "$result" ]] && continue
        case "$result" in
            installed|uninstalled)
                printf "  ${C_GREEN}✓${C_RESET} %-20s %s\n" "$name" "$result"
                installed=$(( installed + 1 ))
                ;;
            skipped)
                printf "  ${C_YELLOW}~${C_RESET} %-20s %s\n" "$name" "$result"
                skipped=$(( skipped + 1 ))
                ;;
            failed)
                printf "  ${C_RED}✗${C_RESET} %-20s %s\n" "$name" "$result"
                failed=$(( failed + 1 ))
                ;;
        esac
    done
    printf "${C_BOLD}===============${C_RESET}\n"
    printf "%d done, %d skipped, %d failed\n" "$installed" "$skipped" "$failed"
}

# =============================================================================
# MODULES
# =============================================================================

# ---------------------------------------------------------------------------
# Module: base
# ---------------------------------------------------------------------------

module_base() {
    local action="${1:-install}"
    case "$action" in
        info)
            echo "base"
            echo "Shell foundation: sources configs/.bashrc from ~/.bashrc, symlinks ~/.inputrc"
            ;;
        install)
            log_info "Injecting ~/.bashrc source block..."
            add_to_file_if_not_present "$HOME/.bashrc" "bashrc" \
                "[ -f \"$CONFIGS_DIR/.bashrc\" ] && source \"$CONFIGS_DIR/.bashrc\""
            create_symlink "$CONFIGS_DIR/.inputrc" "$HOME/.inputrc"
            ;;
        uninstall)
            remove_from_file_section "$HOME/.bashrc" "bashrc"
            remove_symlink_if_ours "$CONFIGS_DIR/.inputrc" "$HOME/.inputrc"
            ;;
    esac
}
register_module "base" "Shell foundation: sources configs/.bashrc from ~/.bashrc, symlinks ~/.inputrc"

# ---------------------------------------------------------------------------
# Module: cli_tools
# ---------------------------------------------------------------------------

module_cli_tools() {
    local action="${1:-install}"
    case "$action" in
        info)
            echo "cli_tools"
            echo "General CLI utilities without config"
            ;;
        install)
            install_dnf_packages "cli_tools" \
                python trash-cli ripgrep fd-find bat \
                lua luarocks tree-sitter-cli boxes bear npm
            ;;
        uninstall)
            log_info "cli_tools packages are not automatically removed by this script"
            log_info "To remove manually: sudo dnf remove python trash-cli ripgrep fd-find bat lua luarocks tree-sitter-cli boxes bear npm"
            ;;
    esac
}
register_module "cli_tools" "General CLI utilities without config"

# ---------------------------------------------------------------------------
# Module: neovim
# ---------------------------------------------------------------------------

module_neovim() {
    local action="${1:-install}"
    case "$action" in
        info)
            echo "neovim"
            echo "Neovim: latest stable AppImage + ~/.config/nvim symlink"
            ;;
        install)
            create_symlink "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"

            run_cmd mkdir -p "$BIN_DIR"
            local nvim_bin="$BIN_DIR/nvim"

            if [[ -L "$nvim_bin" ]]; then
                log_skip "nvim symlink already exists at $nvim_bin"
                return
            fi

            log_info "Fetching latest stable neovim release..."
            local version
            version="$(get_latest_github_release "neovim/neovim")"
            if [[ -z "$version" ]]; then
                log_fail "Could not determine latest neovim version"
                return 1
            fi
            log_ok "Latest neovim: $version"

            local version_num="${version#v}"
            local install_dir="$TOOLS_DIR/neovim_${version_num}"
            local appimage="nvim-linux-x86_64.appimage"
            local appimage_path="$install_dir/$appimage"

            run_cmd mkdir -p "$install_dir"

            if [[ -f "$appimage_path" ]]; then
                log_skip "AppImage already downloaded: $appimage_path"
            else
                local url="https://github.com/neovim/neovim/releases/download/${version}/${appimage}"
                log_info "Downloading $url"
                run_cmd wget -q -O "$appimage_path" "$url"
                log_ok "Downloaded neovim AppImage"
            fi

            if [[ "$DRY_RUN" -eq 0 ]]; then
                chmod u+x "$appimage_path"
            fi
            create_symlink "$appimage_path" "$nvim_bin"
            log_ok "nvim installed: $nvim_bin -> $appimage_path (version: $version)"
            ;;
        uninstall)
            remove_symlink_if_ours "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"

            local nvim_bin="$BIN_DIR/nvim"
            if [[ -L "$nvim_bin" ]]; then
                local target
                target="$(readlink "$nvim_bin")"
                if [[ "$target" == "$TOOLS_DIR/neovim_"* ]]; then
                    run_cmd rm "$nvim_bin"
                    log_ok "Removed nvim symlink: $nvim_bin"
                else
                    log_skip "nvim symlink does not point into our tools dir, skipping"
                fi
            else
                log_skip "No nvim symlink found at $nvim_bin"
            fi

            local removed=0
            for dir in "$TOOLS_DIR"/neovim_*/; do
                [[ -d "$dir" ]] || continue
                run_cmd rm -rf "$dir"
                log_ok "Removed: $dir"
                removed=$(( removed + 1 ))
            done
            if [[ "$removed" -eq 0 ]]; then
                log_skip "No neovim install directories found in $TOOLS_DIR"
            fi
            ;;
    esac
}
register_module "neovim" "Neovim: latest stable AppImage + ~/.config/nvim symlink"

# ---------------------------------------------------------------------------
# Module: tmux
# ---------------------------------------------------------------------------

module_tmux() {
    local action="${1:-install}"
    case "$action" in
        info)
            echo "tmux"
            echo "tmux terminal multiplexer + ~/.tmux.conf symlink"
            ;;
        install)
            install_dnf_packages "tmux" tmux
            create_symlink "$CONFIGS_DIR/.tmux.conf" "$HOME/.tmux.conf"
            ;;
        uninstall)
            remove_symlink_if_ours "$CONFIGS_DIR/.tmux.conf" "$HOME/.tmux.conf"
            log_info "tmux package is not automatically removed by this script"
            ;;
    esac
}
register_module "tmux" "tmux terminal multiplexer + ~/.tmux.conf symlink"

# ---------------------------------------------------------------------------
# Module: git
# ---------------------------------------------------------------------------

module_git() {
    local action="${1:-install}"
    case "$action" in
        info)
            echo "git"
            echo "git + git-delta (better diffs), injects include block into ~/.gitconfig"
            ;;
        install)
            install_dnf_packages "git" git git-delta
            log_info "Injecting ~/.gitconfig include block..."
            add_to_file_if_not_present "$HOME/.gitconfig" "gitconfig" \
                "[include]
    path = $CONFIGS_DIR/.gitconfig" ";"
            ;;
        uninstall)
            remove_from_file_section "$HOME/.gitconfig" "gitconfig" ";"
            log_info "git/git-delta packages are not automatically removed by this script"
            ;;
    esac
}
register_module "git" "git + git-delta (better diffs), injects include block into ~/.gitconfig"

# ---------------------------------------------------------------------------
# Module: forgit
# ---------------------------------------------------------------------------

module_forgit() {
    local action="${1:-install}"
    local forgit_dir="$TOOLS_DIR/forgit"
    case "$action" in
        info)
            echo "forgit"
            echo "forgit — interactive git commands via fzf (git clone)"
            ;;
        install)
            if [[ -d "$forgit_dir" ]]; then
                log_skip "forgit already cloned at $forgit_dir"
                return
            fi
            run_cmd mkdir -p "$TOOLS_DIR"
            log_info "Cloning forgit..."
            run_cmd git clone https://github.com/wfxr/forgit.git "$forgit_dir"
            log_ok "forgit cloned to $forgit_dir"
            ;;
        uninstall)
            if [[ -d "$forgit_dir" ]]; then
                run_cmd rm -rf "$forgit_dir"
                log_ok "Removed forgit directory: $forgit_dir"
            else
                log_skip "forgit directory not found: $forgit_dir"
            fi
            ;;
    esac
}
register_module "forgit" "forgit — interactive git commands via fzf (git clone)"

# ---------------------------------------------------------------------------
# Module: gdb
# ---------------------------------------------------------------------------

module_gdb() {
    local action="${1:-install}"
    case "$action" in
        info)
            echo "gdb"
            echo "GDB debugger + ~/.gdbinit symlink"
            ;;
        install)
            install_dnf_packages "gdb" gdb
            create_symlink "$CONFIGS_DIR/.gdbinit" "$HOME/.gdbinit"
            ;;
        uninstall)
            remove_symlink_if_ours "$CONFIGS_DIR/.gdbinit" "$HOME/.gdbinit"
            log_info "gdb package is not automatically removed by this script"
            ;;
    esac
}
register_module "gdb" "GDB debugger + ~/.gdbinit symlink"

# ---------------------------------------------------------------------------
# Module: fzf
# ---------------------------------------------------------------------------

module_fzf() {
    local action="${1:-install}"
    local fzf_dir="$TOOLS_DIR/fzf"
    case "$action" in
        info)
            echo "fzf"
            echo "fzf — fuzzy finder (git clone + installer)"
            ;;
        install)
            if [[ -d "$fzf_dir" ]]; then
                log_skip "fzf already cloned at $fzf_dir"
                return
            fi
            run_cmd mkdir -p "$TOOLS_DIR"
            log_info "Cloning fzf..."
            run_cmd git clone --depth 1 https://github.com/junegunn/fzf.git "$fzf_dir"
            log_info "Running fzf installer..."
            run_cmd "$fzf_dir/install" --all
            log_ok "fzf installed"
            ;;
        uninstall)
            if [[ -d "$fzf_dir" ]]; then
                run_cmd rm -rf "$fzf_dir"
                log_ok "Removed fzf directory: $fzf_dir"
            else
                log_skip "fzf directory not found: $fzf_dir"
            fi
            ;;
    esac
}
register_module "fzf" "fzf — fuzzy finder (git clone + installer)"

# ---------------------------------------------------------------------------
# Module: fff
# ---------------------------------------------------------------------------

module_fff() {
    local action="${1:-install}"
    local fff_dir="$TOOLS_DIR/fff"
    case "$action" in
        info)
            echo "fff"
            echo "fff — terminal file manager (git clone + make install)"
            ;;
        install)
            if command -v fff &>/dev/null; then
                log_skip "fff already in PATH"
                return
            fi
            run_cmd mkdir -p "$TOOLS_DIR"
            log_info "Cloning fff..."
            run_cmd git clone https://github.com/dylanaraps/fff.git "$fff_dir"
            log_info "Installing fff (sudo make install)..."
            run_cmd make -C "$fff_dir" install
            log_ok "fff installed"
            ;;
        uninstall)
            if [[ -d "$fff_dir" ]]; then
                run_cmd make -C "$fff_dir" uninstall 2>/dev/null || true
                run_cmd rm -rf "$fff_dir"
                log_ok "Removed fff"
            else
                log_skip "fff directory not found: $fff_dir"
            fi
            ;;
    esac
}
register_module "fff" "fff — terminal file manager (git clone + make install)"

# ---------------------------------------------------------------------------
# Module: opencode
# ---------------------------------------------------------------------------

module_opencode() {
    local action="${1:-install}"
    local opencode_config_dir="$HOME/.config/opencode"
    local src_dir="$CONFIGS_DIR/opencode"
    case "$action" in
        info)
            echo "opencode"
            echo "opencode — AI coding assistant (curl installer + config symlinks)"
            ;;
        install)
            if ! command -v opencode &>/dev/null; then
                log_info "Installing opencode..."
                local tmp_installer
                tmp_installer="$(mktemp)"
                run_cmd curl -fsSL https://opencode.ai/install -o "$tmp_installer"
                run_cmd bash "$tmp_installer"
                rm -f "$tmp_installer"
                log_ok "opencode installed"
                log_info "Run 'opencode auth login' to authenticate"
            else
                log_skip "opencode already in PATH"
            fi

            run_cmd mkdir -p "$opencode_config_dir"
            create_symlink "$src_dir/opencode.json" "$opencode_config_dir/opencode.json"
            create_symlink "$src_dir/tui.json"      "$opencode_config_dir/tui.json"
            create_symlink "$src_dir/agents"        "$opencode_config_dir/agents"
            ;;
        uninstall)
            remove_symlink_if_ours "$src_dir/opencode.json" "$opencode_config_dir/opencode.json"
            remove_symlink_if_ours "$src_dir/tui.json"      "$opencode_config_dir/tui.json"
            remove_symlink_if_ours "$src_dir/agents"        "$opencode_config_dir/agents"
            log_info "opencode binary is not removed (installed system-wide)"
            ;;
    esac
}
register_module "opencode" "opencode — AI coding assistant (curl installer + config symlinks)"

# ---------------------------------------------------------------------------
# Module: caveman
# ---------------------------------------------------------------------------

module_caveman() {
    local action="${1:-install}"
    local skill_file="$HOME/.config/opencode/skills/caveman/SKILL.md"
    case "$action" in
        info)
            echo "caveman"
            echo "caveman skill for opencode (npx install)"
            ;;
        install)
            if [[ -f "$skill_file" ]]; then
                log_skip "caveman skill already installed at $skill_file"
                return
            fi
            if ! command -v npx &>/dev/null; then
                log_skip "npx not found, skipping caveman skill install"
                return
            fi
            log_info "Installing caveman skill via npx..."
            run_cmd npx skills add JuliusBrussee/caveman -a opencode -g -y
            log_ok "caveman skill installed"
            ;;
        uninstall)
            if [[ -f "$skill_file" ]]; then
                run_cmd rm -f "$skill_file"
                log_ok "Removed caveman skill: $skill_file"
                local skill_dir
                skill_dir="$(dirname "$skill_file")"
                [[ -d "$skill_dir" ]] && { run_cmd rmdir "$skill_dir" 2>/dev/null || true; }
            else
                log_skip "caveman skill not found at $skill_file"
            fi
            ;;
    esac
}
register_module "caveman" "caveman skill for opencode (npx install)"

# =============================================================================
# MAIN
# =============================================================================

_run_single_module() {
    local action="$1"
    local name="$2"

    if ! declare -F "module_${name}" > /dev/null 2>&1; then
        log_fail "Unknown module: '$name'"
        printf "Available modules: %s\n" "${MODULES[*]}" >&2
        exit 1
    fi

    printf "${C_BOLD}[ %s ]${C_RESET} %s\n" "$name" "${MODULE_DESCS[$name]}"
    local result_label
    result_label="${action}ed"   # "install" -> "installed", "uninstall" -> "uninstalled"
    if run_module "$action" "$name"; then
        record_result "$name" "$result_label"
    else
        record_result "$name" "failed"
    fi
    print_summary
}

_run_all_modules() {
    local action="$1"   # "install" or "uninstall"
    local verb
    verb="$( [[ "$action" == "uninstall" ]] && echo "Uninstall" || echo "Proceed" )"

    for name in "${MODULES[@]}"; do
        local desc="${MODULE_DESCS[$name]}"

        if ! prompt_proceed "$name" "$desc" "$verb"; then
            record_result "$name" "skipped"
            continue
        fi

        local result_label="${action}ed"
        if run_module "$action" "$name"; then
            record_result "$name" "$result_label"
        else
            record_result "$name" "failed"
        fi
    done

    print_summary
}

main() {
    _parse_args "$@"

    if [[ "$FLAG_TEST" -eq 1 ]]; then
        exec bash "$SCRIPT_DIR/tests/test_install.sh"
    fi

    if [[ "$FLAG_LIST" -eq 1 ]]; then
        printf "${C_BOLD}%-20s  %s${C_RESET}\n" "MODULE" "DESCRIPTION"
        printf '%0.s-' {1..60}; printf '\n'
        for name in "${MODULES[@]}"; do
            printf "%-20s  %s\n" "$name" "${MODULE_DESCS[$name]}"
        done
        exit 0
    fi

    if [[ -n "$FLAG_UNINSTALL_ONLY" ]]; then
        _run_single_module "uninstall" "$FLAG_UNINSTALL_ONLY"
        exit 0
    fi

    if [[ "$FLAG_UNINSTALL_ALL" -eq 1 || "$FLAG_UNINSTALL" -eq 1 ]]; then
        _run_all_modules "uninstall"
        exit 0
    fi

    if [[ -n "$FLAG_ONLY" ]]; then
        _run_single_module "install" "$FLAG_ONLY"
        exit 0
    fi

    # Default: interactive (or --all) install
    _run_all_modules "install"
}

# ---------------------------------------------------------------------------
# Entry-point guard — prevents execution when sourced (e.g. by tests)
# ---------------------------------------------------------------------------

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
